import os
import uuid
from datetime import datetime, timedelta

from flask import Flask, request, jsonify, send_file, abort
from flask_cors import CORS
from werkzeug.utils import secure_filename

from config import (
    UPLOAD_FOLDER,
    DATABASE_URI,
    ALLOWED_EXTENSIONS,
    MAX_CONTENT_LENGTH,
)
from models import (
    db,
    User,
    Book,
    Rating,
    UserActivity,
    ReadingCircle,
    CircleMember,
    FcmToken,
)
from ai_engine import RuleBasedAIEngine


# ==================== اپلیکیشن ====================
app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URI
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['MAX_CONTENT_LENGTH'] = MAX_CONTENT_LENGTH

CORS(app, resources={r"/api/*": {"origins": "*"}})

db.init_app(app)

with app.app_context():
    try:
        db.create_all()
    except Exception as e:
        if 'already exists' not in str(e).lower():
            raise

ai_engine = RuleBasedAIEngine()


# ==================== پوشه‌های آپلود ====================
for folder in ['books', 'audio', 'video', 'covers']:
    os.makedirs(os.path.join(UPLOAD_FOLDER, folder), exist_ok=True)


# ==================== توابع کمکی ====================
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def allowed_image(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in {'jpg', 'jpeg', 'png', 'webp'}


# ==================== ۱. سلامت سرور ====================
@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'ok',
        'time': datetime.utcnow().isoformat(),
        'service': 'Shahid Suleimani Library API',
    }), 200


# ==================== ۲. احراز هویت ====================
@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json(silent=True) or {}
    name = data.get('name')
    national_code = data.get('national_code')

    if not name or not national_code:
        return jsonify({'error': 'نام و کد ملی الزامی است'}), 400

    user = User.query.filter_by(national_code=national_code).first()

    if user:
        if user.name != name:
            user.name = name
            db.session.commit()
        return jsonify({
            'message': 'ورود موفق',
            'user': user.to_dict(),
        }), 200
    else:
        user = User(
            name=name,
            national_code=national_code,
            avatar_seed=national_code,
            avatar_style='adventurer',
        )
        db.session.add(user)
        db.session.commit()
        return jsonify({
            'message': 'ثبت‌نام موفق',
            'user': user.to_dict(),
        }), 201


# ==================== ۳. پروفایل کاربر ====================
@app.route('/api/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    user = User.query.get_or_404(user_id)
    return jsonify({'user': user.to_dict()}), 200


@app.route('/api/users/<int:user_id>', methods=['PUT'])
def update_user(user_id):
    user = User.query.get_or_404(user_id)
    data = request.get_json(silent=True) or {}

    if 'name' in data:
        user.name = data['name']
    if 'bio' in data:
        user.bio = data['bio']
    if 'avatar_seed' in data:
        user.avatar_seed = data['avatar_seed']
    if 'avatar_style' in data:
        user.avatar_style = data['avatar_style']
    if 'theme_preference' in data:
        user.theme_preference = data['theme_preference']

    db.session.commit()
    return jsonify({
        'message': 'پروفایل بروزرسانی شد',
        'user': user.to_dict(),
    }), 200


# ==================== ۴. FCM Token ====================
@app.route('/api/users/<int:user_id>/fcm-token', methods=['POST'])
def register_fcm_token(user_id):
    User.query.get_or_404(user_id)
    data = request.get_json(silent=True) or {}
    token = data.get('fcm_token')

    if not token:
        return jsonify({'error': 'توکن الزامی است'}), 400

    existing = FcmToken.query.filter_by(token=token).first()
    if existing:
        existing.user_id = user_id
    else:
        fcm = FcmToken(user_id=user_id, token=token)
        db.session.add(fcm)

    db.session.commit()
    return jsonify({'message': 'توکن ثبت شد'}), 201


# ==================== ۵. کتاب‌ها ====================
@app.route('/api/books', methods=['GET'])
def get_books():
    book_type = request.args.get('type')
    category = request.args.get('category')

    query = Book.query
    if book_type:
        query = query.filter_by(type=book_type)
    if category:
        query = query.filter_by(category=category)

    books = query.order_by(Book.created_at.desc()).all()
    return jsonify([b.to_dict() for b in books]), 200


@app.route('/api/books/<int:book_id>', methods=['GET'])
def get_book(book_id):
    book = Book.query.get_or_404(book_id)
    return jsonify(book.to_dict()), 200


# ==================== ۶. آپلود کتاب + کاور ====================
@app.route('/api/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'error': 'فایلی ارسال نشده است'}), 400

    file = request.files['file']
    cover = request.files.get('cover')  # اختیاری

    book_type = request.form.get('type', 'pdf')
    title = request.form.get('title')
    author = request.form.get('author', '')
    description = request.form.get('description', '')
    category = request.form.get('category', '')

    if not title:
        return jsonify({'error': 'عنوان کتاب الزامی است'}), 400

    if file.filename == '':
        return jsonify({'error': 'نام فایل خالی است'}), 400

    if not allowed_file(file.filename):
        return jsonify({'error': 'فرمت فایل مجاز نیست'}), 400

    # ذخیره فایل اصلی
    original_name = secure_filename(file.filename)
    unique_name = f"{uuid.uuid4().hex}_{original_name}"

    subfolder = (
        'books' if book_type == 'pdf'
        else 'audio' if book_type == 'audio'
        else 'video'
    )

    file_path = os.path.join(UPLOAD_FOLDER, subfolder, unique_name)
    file.save(file_path)
    file_size = os.path.getsize(file_path)
    file_url = f"/api/download/{subfolder}/{unique_name}"

    # ذخیره کاور (اختیاری)
    cover_url = None
    cover_path = None
    if cover and cover.filename and allowed_image(cover.filename):
        ext = cover.filename.rsplit('.', 1)[-1].lower()
        cover_name = f"{uuid.uuid4().hex}.{ext}"
        cover_path = os.path.join(UPLOAD_FOLDER, 'covers', cover_name)
        cover.save(cover_path)
        cover_url = f"/api/covers/{cover_name}"

    book = Book(
        title=title,
        author=author,
        description=description,
        cover_url=cover_url,
        cover_path=cover_path,
        file_url=file_url,
        file_path=file_path,
        file_size=file_size,
        type=book_type,
        category=category,
    )
    db.session.add(book)
    db.session.commit()

    return jsonify({
        'message': 'فایل با موفقیت آپلود شد',
        'book': book.to_dict(),
    }), 201


# ==================== ۷. آپلود کاور جداگانه ====================
@app.route('/api/upload-cover', methods=['POST'])
def upload_cover():
    if 'cover' not in request.files:
        return jsonify({'error': 'کاور ارسال نشده'}), 400

    file = request.files['cover']
    book_id = request.form.get('book_id')

    if file.filename == '':
        return jsonify({'error': 'نام فایل خالی'}), 400

    if not allowed_image(file.filename):
        return jsonify({'error': 'فرمت تصویر مجاز نیست'}), 400

    ext = file.filename.rsplit('.', 1)[-1].lower()
    unique_name = f"{uuid.uuid4().hex}.{ext}"
    cover_path = os.path.join(UPLOAD_FOLDER, 'covers', unique_name)
    file.save(cover_path)

    cover_url = f"/api/covers/{unique_name}"

    if book_id:
        book = Book.query.get(book_id)
        if book:
            book.cover_url = cover_url
            book.cover_path = cover_path
            db.session.commit()

    return jsonify({
        'message': 'کاور آپلود شد',
        'cover_url': cover_url,
    }), 201


# ==================== ۸. دانلود فایل ====================
@app.route('/api/download/<folder>/<filename>', methods=['GET'])
def download_file(folder, filename):
    safe_folder = os.path.basename(folder)
    safe_filename = os.path.basename(filename)
    file_path = os.path.join(UPLOAD_FOLDER, safe_folder, safe_filename)

    if not os.path.exists(file_path):
        abort(404)

    return send_file(file_path, as_attachment=True)


# ==================== ۹. سرو کردن کاور ====================
@app.route('/api/covers/<filename>', methods=['GET'])
def serve_cover(filename):
    safe_name = os.path.basename(filename)
    path = os.path.join(UPLOAD_FOLDER, 'covers', safe_name)

    if not os.path.exists(path):
        abort(404)

    # تشخیص mimetype بر اساس پسوند
    ext = safe_name.rsplit('.', 1)[-1].lower()
    mimetype = 'image/jpeg'
    if ext == 'png':
        mimetype = 'image/png'
    elif ext == 'webp':
        mimetype = 'image/webp'

    return send_file(path, mimetype=mimetype)


# ==================== ۱۰. امتیازات ====================
@app.route('/api/ratings', methods=['POST'])
def add_rating():
    data = request.get_json(silent=True) or {}
    book_id = data.get('book_id')
    user_name = data.get('user_name')
    rating_value = data.get('rating')
    comment = data.get('comment', '')

    if not all([book_id, user_name, rating_value]):
        return jsonify({'error': 'اطلاعات ناقص است'}), 400

    try:
        rating_value = float(rating_value)
        if rating_value < 0 or rating_value > 5:
            return jsonify({'error': 'امتیاز باید بین ۰ و ۵ باشد'}), 400
    except (ValueError, TypeError):
        return jsonify({'error': 'امتیاز نامعتبر است'}), 400

    rating = Rating(
        book_id=book_id,
        user_name=user_name,
        rating=rating_value,
        comment=comment,
    )
    db.session.add(rating)
    db.session.commit()

    book = Book.query.get(book_id)
    if book:
        ratings = Rating.query.filter_by(book_id=book_id).all()
        book.rating = sum(r.rating for r in ratings) / len(ratings)
        book.rating_count = len(ratings)
        db.session.commit()

    return jsonify({
        'message': 'امتیاز ثبت شد',
        'rating': rating.to_dict(),
    }), 201


@app.route('/api/ratings/<int:book_id>', methods=['GET'])
def get_ratings(book_id):
    ratings = (
        Rating.query
        .filter_by(book_id=book_id)
        .order_by(Rating.created_at.desc())
        .all()
    )
    return jsonify([r.to_dict() for r in ratings]), 200


# ==================== ۱۱. حلقه‌های مطالعه ====================
@app.route('/api/circles', methods=['GET'])
def get_circles():
    circles = ReadingCircle.query.all()
    result = []

    for c in circles:
        book_data = None
        if c.book_id:
            book = Book.query.get(c.book_id)
            if book:
                book_data = book.to_dict()

        result.append({
            'id': c.id,
            'name': c.name,
            'description': c.description,
            'book': book_data,
            'member_count': len(c.members),
            'created_at': c.created_at.isoformat(),
        })

    return jsonify(result), 200


@app.route('/api/circles', methods=['POST'])
def create_circle():
    data = request.get_json(silent=True) or {}

    if not data.get('name') or not data.get('user_id'):
        return jsonify({'error': 'نام و کاربر الزامی است'}), 400

    circle = ReadingCircle(
        name=data['name'],
        description=data.get('description', ''),
        book_id=data.get('book_id'),
        created_by=data['user_id'],
    )
    db.session.add(circle)
    db.session.commit()

    member = CircleMember(
        circle_id=circle.id,
        user_id=data['user_id'],
    )
    db.session.add(member)
    db.session.commit()

    return jsonify({
        'message': 'حلقه مطالعه ایجاد شد',
        'circle_id': circle.id,
    }), 201


@app.route('/api/circles/<int:circle_id>/join', methods=['POST'])
def join_circle(circle_id):
    data = request.get_json(silent=True) or {}
    user_id = data.get('user_id')

    if not user_id:
        return jsonify({'error': 'کاربر الزامی است'}), 400

    ReadingCircle.query.get_or_404(circle_id)

    existing = CircleMember.query.filter_by(
        circle_id=circle_id,
        user_id=user_id,
    ).first()

    if existing:
        return jsonify({'error': 'قبلاً عضو شده‌اید'}), 400

    member = CircleMember(circle_id=circle_id, user_id=user_id)
    db.session.add(member)
    db.session.commit()

    return jsonify({'message': 'عضو شدید'}), 201


# ==================== ۱۲. جدول امتیازات ====================
@app.route('/api/leaderboard', methods=['GET'])
def get_leaderboard():
    period = request.args.get('period', 'weekly')

    if period == 'weekly':
        start = datetime.utcnow() - timedelta(days=7)
    elif period == 'monthly':
        start = datetime.utcnow() - timedelta(days=30)
    else:
        start = datetime(2000, 1, 1)

    results = (
        db.session.query(
            User.id,
            User.name,
            User.avatar_seed,
            db.func.sum(UserActivity.minutes_read).label('total_minutes'),
            db.func.count(UserActivity.id).label('books_count'),
        )
        .join(UserActivity, User.id == UserActivity.user_id)
        .filter(UserActivity.last_activity >= start)
        .group_by(User.id)
        .order_by(db.desc('total_minutes'))
        .limit(20)
        .all()
    )

    leaderboard = [
        {
            'rank': i + 1,
            'user_id': r.id,
            'name': r.name,
            'avatar_seed': r.avatar_seed,
            'total_minutes': r.total_minutes or 0,
            'books_count': r.books_count,
        }
        for i, r in enumerate(results)
    ]

    return jsonify(leaderboard), 200


# ==================== ۱۳. هوش مصنوعی ====================
@app.route('/api/ai/recommendations/<int:user_id>', methods=['GET'])
def get_recommendations(user_id):
    user = User.query.get_or_404(user_id)
    limit = request.args.get('limit', 5, type=int)
    books = ai_engine.get_book_recommendations(user, limit)
    return jsonify([b.to_dict() for b in books]), 200


@app.route('/api/ai/message/<int:user_id>', methods=['GET'])
def get_motivational_message(user_id):
    user = User.query.get_or_404(user_id)

    activity = (
        UserActivity.query
        .filter_by(user_id=user_id)
        .order_by(UserActivity.last_activity.desc())
        .first()
    )

    message = ai_engine.get_motivational_message(user, activity)
    return jsonify({'message': message}), 200


@app.route('/api/ai/stats/<int:user_id>', methods=['GET'])
def get_user_stats(user_id):
    user = User.query.get_or_404(user_id)
    stats = ai_engine.get_user_stats(user)
    return jsonify(stats), 200


@app.route('/api/ai/activity', methods=['POST'])
def record_activity():
    data = request.get_json(silent=True) or {}
    user_id = data.get('user_id')
    book_id = data.get('book_id')
    action = data.get('action', 'read')
    minutes = data.get('minutes', 0)

    if not user_id:
        return jsonify({'error': 'کاربر الزامی است'}), 400

    today = datetime.utcnow().date()

    activity = (
        UserActivity.query
        .filter_by(user_id=user_id, book_id=book_id)
        .order_by(UserActivity.last_activity.desc())
        .first()
    )

    if activity and activity.last_activity.date() == today:
        activity.minutes_read = (activity.minutes_read or 0) + minutes
        activity.last_activity = datetime.utcnow()
    else:
        streak = 1
        if activity and activity.last_activity.date() == (today - timedelta(days=1)):
            streak = (activity.current_streak or 1) + 1

        activity = UserActivity(
            user_id=user_id,
            book_id=book_id,
            action=action,
            minutes_read=minutes,
            current_streak=streak,
            last_activity=datetime.utcnow(),
        )
        db.session.add(activity)

    db.session.commit()

    return jsonify({
        'message': 'فعالیت ثبت شد',
        'streak': activity.current_streak,
    }), 201


# ==================== اجرا ====================
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)