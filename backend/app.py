import os
import uuid
from datetime import datetime
from flask import Flask, request, jsonify, send_file, abort
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from werkzeug.utils import secure_filename
from config import UPLOAD_FOLDER, DATABASE_URI, ALLOWED_EXTENSIONS, MAX_CONTENT_LENGTH
from ai_engine import RuleBasedAIEngine

ai_engine = RuleBasedAIEngine()

# --- اپلیکیشن ---
app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URI
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['MAX_CONTENT_LENGTH'] = MAX_CONTENT_LENGTH

CORS(app, resources={r"/api/*": {"origins": "*"}})

db = SQLAlchemy(app)

# --- پوشه‌ها ---
for folder in [
    os.path.join(UPLOAD_FOLDER, 'books'),
    os.path.join(UPLOAD_FOLDER, 'audio'),
    os.path.join(UPLOAD_FOLDER, 'video'),
]:
    os.makedirs(folder, exist_ok=True)

# --- مدل‌ها ---
class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    national_code = db.Column(db.String(10), unique=True, nullable=False)
    avatar_seed = db.Column(db.String(100))
    avatar_style = db.Column(db.String(50))
    bio = db.Column(db.Text)
    theme_preference = db.Column(db.String(20))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'national_code': self.national_code,
            'avatar_seed': self.avatar_seed,
            'avatar_style': self.avatar_style,
            'bio': self.bio,
            'theme_preference': self.theme_preference,
        }


class Book(db.Model):
    __tablename__ = 'books'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    author = db.Column(db.String(200))
    description = db.Column(db.Text)
    cover_url = db.Column(db.String(500))
    file_url = db.Column(db.String(500))
    file_path = db.Column(db.String(500))
    type = db.Column(db.String(20), nullable=False)  # pdf, audio, video
    category = db.Column(db.String(100))
    rating = db.Column(db.Float, default=0.0)
    rating_count = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'author': self.author,
            'description': self.description,
            'cover_url': self.cover_url,
            'file_url': self.file_url,
            'file_path': self.file_path,
            'type': self.type,
            'category': self.category,
            'rating': self.rating,
            'rating_count': self.rating_count,
        }


class Rating(db.Model):
    __tablename__ = 'ratings'
    id = db.Column(db.Integer, primary_key=True)
    book_id = db.Column(db.Integer, db.ForeignKey('books.id'), nullable=False)
    user_name = db.Column(db.String(100), nullable=False)
    rating = db.Column(db.Float, nullable=False)
    comment = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'book_id': self.book_id,
            'user_name': self.user_name,
            'rating': self.rating,
            'comment': self.comment,
            'created_at': self.created_at.isoformat(),
        }

class UserActivity(db.Model):
    __tablename__ = 'user_activities'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    book_id = db.Column(db.Integer, db.ForeignKey('books.id'), nullable=False)
    action = db.Column(db.String(20))  # read, listen, watch, complete
    minutes_read = db.Column(db.Integer, default=0)
    current_streak = db.Column(db.Integer, default=1)
    last_activity = db.Column(db.DateTime, default=datetime.utcnow)

class ReadingCircle(db.Model):
    __tablename__ = 'reading_circles'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    book_id = db.Column(db.Integer, db.ForeignKey('books.id'))
    created_by = db.Column(db.Integer, db.ForeignKey('users.id'))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    members = db.relationship('CircleMember', backref='circle', lazy=True)

class CircleMember(db.Model):
    __tablename__ = 'circle_members'
    id = db.Column(db.Integer, primary_key=True)
    circle_id = db.Column(db.Integer, db.ForeignKey('reading_circles.id'))
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    joined_at = db.Column(db.DateTime, default=datetime.utcnow)
    progress = db.Column(db.Float, default=0.0)

# --- ساخت دیتابیس ---
with app.app_context():
    db.create_all()

# --- توابع کمکی ---
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/api/circles', methods=['GET'])
def get_circles():
    circles = ReadingCircle.query.all()
    result = []
    for c in circles:
        data = {
            'id': c.id, 'name': c.name, 'description': c.description,
            'book': Book.query.get(c.book_id).to_dict() if c.book_id else None,
            'member_count': len(c.members),
            'created_at': c.created_at.isoformat()
        }
        result.append(data)
    return jsonify(result), 200

@app.route('/api/circles', methods=['POST'])
def create_circle():
    data = request.get_json()
    circle = ReadingCircle(
        name=data['name'], description=data.get('description', ''),
        book_id=data.get('book_id'), created_by=data['user_id']
    )
    db.session.add(circle)
    db.session.commit()
    # سازنده به عنوان عضو اضافه شود
    member = CircleMember(circle_id=circle.id, user_id=data['user_id'])
    db.session.add(member)
    db.session.commit()
    return jsonify({'message': 'حلقه مطالعه ایجاد شد', 'circle_id': circle.id}), 201

@app.route('/api/circles/<int:circle_id>/join', methods=['POST'])
def join_circle(circle_id):
    data = request.get_json()
    existing = CircleMember.query.filter_by(
        circle_id=circle_id, user_id=data['user_id']
    ).first()
    if existing:
        return jsonify({'error': 'قبلاً عضو شده‌اید'}), 400
    member = CircleMember(circle_id=circle_id, user_id=data['user_id'])
    db.session.add(member)
    db.session.commit()
    return jsonify({'message': 'عضو شدید'}), 201

@app.route('/api/leaderboard', methods=['GET'])
def get_leaderboard():
    period = request.args.get('period', 'weekly')
    if period == 'weekly':
        start = datetime.utcnow() - timedelta(days=7)
    elif period == 'monthly':
        start = datetime.utcnow() - timedelta(days=30)
    else:
        start = datetime(2000, 1, 1)

    # بر اساس مجموع دقایق مطالعه
    results = db.session.query(
        User.id, User.name, User.avatar_seed,
        db.func.sum(UserActivity.minutes_read).label('total_minutes'),
        db.func.count(UserActivity.id).label('books_count')
    ).join(UserActivity, User.id == UserActivity.user_id)\
     .filter(UserActivity.last_activity >= start)\
     .group_by(User.id)\
     .order_by(db.desc('total_minutes'))\
     .limit(20).all()

    leaderboard = [{
        'rank': i + 1, 'user_id': r.id, 'name': r.name,
        'avatar_seed': r.avatar_seed,
        'total_minutes': r.total_minutes or 0,
        'books_count': r.books_count
    } for i, r in enumerate(results)]

    return jsonify(leaderboard), 200

@app.route('/api/ai/recommendations/<int:user_id>', methods=['GET'])
def get_recommendations(user_id):
    user = User.query.get_or_404(user_id)
    limit = request.args.get('limit', 5, type=int)
    books = ai_engine.get_book_recommendations(user, limit)
    return jsonify([b.to_dict() for b in books]), 200

@app.route('/api/ai/message/<int:user_id>', methods=['GET'])
def get_motivational_message(user_id):
    user = User.query.get_or_404(user_id)
    activity = UserActivity.query.filter_by(user_id=user_id).order_by(
        UserActivity.last_activity.desc()
    ).first()
    message = ai_engine.get_motivational_message(user, activity)
    return jsonify({'message': message}), 200

@app.route('/api/ai/stats/<int:user_id>', methods=['GET'])
def get_user_stats(user_id):
    user = User.query.get_or_404(user_id)
    stats = ai_engine.get_user_stats(user)
    return jsonify(stats), 200

@app.route('/api/ai/activity', methods=['POST'])
def record_activity():
    """ثبت فعالیت کاربر برای محاسبه استریک و آمار"""
    data = request.get_json()
    user_id = data.get('user_id')
    book_id = data.get('book_id')
    action = data.get('action')  # 'read', 'listen', 'watch', 'complete'
    minutes = data.get('minutes', 0)

    today = datetime.utcnow().date()
    activity = UserActivity.query.filter_by(
        user_id=user_id, book_id=book_id
    ).order_by(UserActivity.last_activity.desc()).first()

    if activity and activity.last_activity.date() == today:
        # فعالیت امروز قبلاً ثبت شده
        activity.minutes_read = (activity.minutes_read or 0) + minutes
        activity.last_activity = datetime.utcnow()
    else:
        # بررسی استریک
        streak = 1
        if activity and activity.last_activity.date() == today - timedelta(days=1):
            streak = activity.current_streak + 1

        activity = UserActivity(
            user_id=user_id, book_id=book_id, action=action,
            minutes_read=minutes, current_streak=streak,
            last_activity=datetime.utcnow()
        )
        db.session.add(activity)

    db.session.commit()
    return jsonify({'message': 'فعالیت ثبت شد', 'streak': activity.current_streak}), 201

# --- API: ورود / ثبت‌نام ---
@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    name = data.get('name')
    national_code = data.get('national_code')

    if not name or not national_code:
        return jsonify({'error': 'نام و کد ملی الزامی است'}), 400

    user = User.query.filter_by(national_code=national_code).first()
    if user:
        return jsonify({'message': 'ورود موفق', 'user': user.to_dict()}), 200
    else:
        user = User(
            name=name,
            national_code=national_code,
            avatar_seed=national_code,
            avatar_style='adventurer',
        )
        db.session.add(user)
        db.session.commit()
        return jsonify({'message': 'ثبت‌نام موفق', 'user': user.to_dict()}), 201


# --- API: دریافت لیست کتاب‌ها ---
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


# --- API: دریافت جزئیات یک کتاب ---
@app.route('/api/books/<int:book_id>', methods=['GET'])
def get_book(book_id):
    book = Book.query.get_or_404(book_id)
    return jsonify(book.to_dict()), 200


# --- API: آپلود فایل کتاب/صوت/ویدیو ---
@app.route('/api/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'error': 'فایلی ارسال نشده است'}), 400

    file = request.files['file']
    book_type = request.form.get('type', 'pdf')
    title = request.form.get('title')
    author = request.form.get('author', '')
    description = request.form.get('description', '')
    category = request.form.get('category', '')

    if file.filename == '':
        return jsonify({'error': 'نام فایل خالی است'}), 400

    if not allowed_file(file.filename):
        return jsonify({'error': 'فرمت فایل مجاز نیست'}), 400

    # ذخیره فایل با نام امن
    original_name = secure_filename(file.filename)
    unique_name = f"{uuid.uuid4().hex}_{original_name}"
    subfolder = 'books' if book_type == 'pdf' else 'audio' if book_type == 'audio' else 'video'
    file_path = os.path.join(UPLOAD_FOLDER, subfolder, unique_name)
    file.save(file_path)

    # ساخت URL
    file_url = f"/api/download/{subfolder}/{unique_name}"

    # ذخیره در دیتابیس
    book = Book(
        title=title,
        author=author,
        description=description,
        file_url=file_url,
        file_path=file_path,
        type=book_type,
        category=category,
    )
    db.session.add(book)
    db.session.commit()

    return jsonify({'message': 'فایل با موفقیت آپلود شد', 'book': book.to_dict()}), 201


# --- API: دانلود فایل ---
@app.route('/api/download/<folder>/<filename>', methods=['GET'])
def download_file(folder, filename):
    file_path = os.path.join(UPLOAD_FOLDER, folder, filename)
    if not os.path.exists(file_path):
        abort(404)
    return send_file(file_path, as_attachment=True)


# --- API: ثبت امتیاز ---
@app.route('/api/ratings', methods=['POST'])
def add_rating():
    data = request.get_json()
    book_id = data.get('book_id')
    user_name = data.get('user_name')
    rating_value = data.get('rating')
    comment = data.get('comment', '')

    if not all([book_id, user_name, rating_value]):
        return jsonify({'error': 'اطلاعات ناقص است'}), 400

    rating = Rating(
        book_id=book_id,
        user_name=user_name,
        rating=rating_value,
        comment=comment,
    )
    db.session.add(rating)
    db.session.commit()

    # به‌روزرسانی میانگین امتیاز کتاب
    book = Book.query.get(book_id)
    if book:
        ratings = Rating.query.filter_by(book_id=book_id).all()
        book.rating = sum(r.rating for r in ratings) / len(ratings)
        book.rating_count = len(ratings)
        db.session.commit()

    return jsonify({'message': 'امتیاز ثبت شد', 'rating': rating.to_dict()}), 201


# --- API: دریافت امتیازات یک کتاب ---
@app.route('/api/ratings/<int:book_id>', methods=['GET'])
def get_ratings(book_id):
    ratings = Rating.query.filter_by(book_id=book_id).order_by(Rating.created_at.desc()).all()
    return jsonify([r.to_dict() for r in ratings]), 200


# --- اجرا ---
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)