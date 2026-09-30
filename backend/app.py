"""
═══════════════════════════════════════════════════════════════════════
   بک‌اند کتابخانه شهید حاج قاسم سلیمانی
   Flask + SQLAlchemy + JWT + File Upload (PDF/MP3/MP4)
   نسخه ۲.۰.۰
═══════════════════════════════════════════════════════════════════════
   اجرا:  python app.py
   سرور:  http://localhost:5000
═══════════════════════════════════════════════════════════════════════
"""

import os
import json
import uuid
from datetime import datetime, timedelta
from functools import wraps

from flask import Flask, request, jsonify, send_from_directory, send_file
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import (
    JWTManager, create_access_token, jwt_required,
    get_jwt_identity, verify_jwt_in_request,
)
from flask_bcrypt import Bcrypt
from flask_cors import CORS
from dotenv import load_dotenv
from sqlalchemy import or_
from werkzeug.utils import secure_filename

# ═══════════════════════════════════════════════════════════════════
#  ۱. پیکربندی مسیرها
# ═══════════════════════════════════════════════════════════════════

load_dotenv()

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# 🗄️ پوشه دیتابیس
DB_FOLDER = os.path.join(BASE_DIR, 'db')
os.makedirs(DB_FOLDER, exist_ok=True)
DB_PATH = os.path.join(DB_FOLDER, 'shahid_library.db')

# 📁 پوشه‌های آپلود
UPLOAD_FOLDER = os.path.join(BASE_DIR, 'uploads')
COVER_FOLDER = os.path.join(UPLOAD_FOLDER, 'covers')
PDF_FOLDER = os.path.join(UPLOAD_FOLDER, 'pdfs')
AUDIO_FOLDER = os.path.join(UPLOAD_FOLDER, 'audios')
VIDEO_FOLDER = os.path.join(UPLOAD_FOLDER, 'videos')

for folder in [COVER_FOLDER, PDF_FOLDER, AUDIO_FOLDER, VIDEO_FOLDER]:
    os.makedirs(folder, exist_ok=True)

# ═══════════════════════════════════════════════════════════════════
#  ۲. راه‌اندازی Flask
# ═══════════════════════════════════════════════════════════════════

app = Flask(__name__)

app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret-key-change-me')
app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY', 'jwt-secret-change-me')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(days=30)
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv(
    'DATABASE_URL', f'sqlite:///{DB_PATH}'
)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['MAX_CONTENT_LENGTH'] = 500 * 1024 * 1024  # ۵۰۰ مگابایت
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['BASE_URL'] = os.getenv('BASE_URL', 'http://localhost:5000')

ALLOWED_IMAGES = {'png', 'jpg', 'jpeg', 'webp', 'gif'}
ALLOWED_PDFS = {'pdf'}
ALLOWED_AUDIOS = {'mp3', 'm4a', 'wav', 'ogg', 'aac'}
ALLOWED_VIDEOS = {'mp4', 'webm', 'mkv', 'mov'}

# ── افزونه‌ها ──
db = SQLAlchemy(app)
migrate = Migrate(app, db)
jwt = JWTManager(app)
bcrypt = Bcrypt(app)
CORS(app, resources={r"/api/*": {"origins": "*"}})


# ═══════════════════════════════════════════════════════════════════
#  ۳. مدل‌های دیتابیس
# ═══════════════════════════════════════════════════════════════════

class User(db.Model):
    __tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    dice_bear_seed = db.Column(
        db.String(120),
        default=lambda: f'user-{int(datetime.now().timestamp())}'
    )
    avatar_style = db.Column(db.String(50), default='adventurer')
    theme_color = db.Column(db.Integer, default=0xFF1B5E20)
    is_dark_mode = db.Column(db.Boolean, default=False)
    role = db.Column(db.String(20), default='user')
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    favorites = db.relationship('Favorite', backref='user', lazy='dynamic',
                                 cascade='all, delete-orphan')
    downloads = db.relationship('Download', backref='user', lazy='dynamic',
                                 cascade='all, delete-orphan')

    def set_password(self, password):
        self.password_hash = bcrypt.generate_password_hash(password).decode('utf-8')

    def check_password(self, password):
        return bcrypt.check_password_hash(self.password_hash, password)

    def is_admin(self):
        return self.role == 'admin'

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'diceBearSeed': self.dice_bear_seed,
            'avatarStyle': self.avatar_style,
            'themeColor': self.theme_color,
            'isDarkMode': self.is_dark_mode,
            'role': self.role,
            'favoriteBookIds': [f.book_id for f in self.favorites],
            'createdAt': self.created_at.isoformat(),
        }


class Category(db.Model):
    __tablename__ = 'categories'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), unique=True, nullable=False)
    slug = db.Column(db.String(100), unique=True, index=True)
    icon = db.Column(db.String(50), default='book')
    color = db.Column(db.String(20), default='#1B5E20')
    description = db.Column(db.Text)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    books = db.relationship('Book', backref='category', lazy='dynamic')

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'slug': self.slug,
            'icon': self.icon,
            'color': self.color,
            'description': self.description,
            'bookCount': self.books.count(),
        }


class Book(db.Model):
    __tablename__ = 'books'

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False, index=True)
    author = db.Column(db.String(150), nullable=False)
    description = db.Column(db.Text, nullable=False)
    cover_url = db.Column(db.String(500), nullable=False)
    pdf_url = db.Column(db.String(500), nullable=True)
    audio_url = db.Column(db.String(500), nullable=True)
    video_url = db.Column(db.String(500), nullable=True)  # 🆕 پشتیبانی ویدیو
    category_id = db.Column(db.Integer, db.ForeignKey('categories.id'), nullable=False)

    rating = db.Column(db.Float, default=0.0)
    rating_count = db.Column(db.Integer, default=0)
    download_count = db.Column(db.Integer, default=0)
    page_count = db.Column(db.Integer, default=0)
    duration = db.Column(db.String(20), nullable=True)
    file_size = db.Column(db.String(20), default='0 MB')
    language = db.Column(db.String(50), default='فارسی')
    tags = db.Column(db.Text, default='[]')

    is_featured = db.Column(db.Boolean, default=False)
    is_published = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, index=True)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    favorites = db.relationship('Favorite', backref='book', lazy='dynamic',
                                 cascade='all, delete-orphan')

    def to_dict(self):
        try:
            tags_list = json.loads(self.tags) if self.tags else []
        except (json.JSONDecodeError, TypeError):
            tags_list = []

        return {
            'id': str(self.id),
            'title': self.title,
            'author': self.author,
            'description': self.description,
            'coverUrl': self.cover_url,
            'pdfUrl': self.pdf_url,
            'audioUrl': self.audio_url,
            'videoUrl': self.video_url,
            'category': self.category.name if self.category else 'عمومی',
            'categoryId': self.category_id,
            'rating': float(self.rating),
            'ratingCount': self.rating_count,
            'downloadCount': self.download_count,
            'pageCount': self.page_count,
            'duration': self.duration,
            'fileSize': self.file_size,
            'language': self.language,
            'tags': tags_list,
            'isFeatured': self.is_featured,
            'isPublished': self.is_published,
            'createdAt': self.created_at.isoformat(),
        }


class Favorite(db.Model):
    __tablename__ = 'favorites'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    book_id = db.Column(db.Integer, db.ForeignKey('books.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    __table_args__ = (
        db.UniqueConstraint('user_id', 'book_id', name='unique_user_book'),
    )


class Download(db.Model):
    __tablename__ = 'downloads'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    book_id = db.Column(db.Integer, db.ForeignKey('books.id'), nullable=False)
    download_type = db.Column(db.String(20), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)


# ═══════════════════════════════════════════════════════════════════
#  ۴. ابزارهای کمکی
# ═══════════════════════════════════════════════════════════════════

def allowed_file(filename, allowed_extensions):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in allowed_extensions


def save_file(file, folder, allowed_extensions):
    """ذخیره فایل آپلود شده و برگرداندن URL آن"""
    if not file or not file.filename:
        return None
    if not allowed_file(file.filename, allowed_extensions):
        raise ValueError('فرمت فایل پشتیبانی نمی‌شود')

    ext = file.filename.rsplit('.', 1)[1].lower()
    filename = f"{uuid.uuid4().hex}.{ext}"
    filepath = os.path.join(folder, filename)
    file.save(filepath)

    rel_path = os.path.relpath(filepath, UPLOAD_FOLDER).replace(os.sep, '/')
    return f"{app.config['BASE_URL']}/uploads/{rel_path}"


def delete_file(url):
    """حذف فایل با URL"""
    if not url:
        return
    try:
        rel_path = url.split('/uploads/')[-1]
        filepath = os.path.join(UPLOAD_FOLDER, rel_path)
        if os.path.exists(filepath):
            os.remove(filepath)
    except (IndexError, OSError):
        pass


def admin_required(fn):
    @wraps(fn)
    def wrapper(*args, **kwargs):
        verify_jwt_in_request()
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        if not user or not user.is_admin():
            return jsonify({
                'success': False,
                'message': 'دسترسی فقط برای مدیران مجاز است',
            }), 403
        return fn(*args, **kwargs)
    return wrapper


# ═══════════════════════════════════════════════════════════════════
#  ۵. مدیریت خطاها
# ═══════════════════════════════════════════════════════════════════

@app.errorhandler(404)
def not_found(error):
    return jsonify({'success': False, 'message': 'منبع یافت نشد'}), 404


@app.errorhandler(500)
def server_error(error):
    return jsonify({'success': False, 'message': 'خطای داخلی سرور'}), 500


@app.errorhandler(413)
def file_too_large(error):
    return jsonify({
        'success': False,
        'message': 'حجم فایل بیش از حد مجاز است (حداکثر ۵۰۰ مگابایت)',
    }), 413


@jwt.unauthorized_loader
def unauthorized_response(callback):
    return jsonify({
        'success': False,
        'message': 'دسترسی غیرمجاز: توکن ارائه نشده',
    }), 401


@jwt.invalid_token_loader
def invalid_token_response(callback):
    return jsonify({'success': False, 'message': 'توکن نامعتبر است'}), 401


@jwt.expired_token_loader
def expired_token_response(jwt_header, jwt_payload):
    return jsonify({'success': False, 'message': 'توکن منقضی شده است'}), 401


# ═══════════════════════════════════════════════════════════════════
#  ۶. سرو فایل‌ها (با پشتیبانی از Range برای ویدیو/صوت)
# ═══════════════════════════════════════════════════════════════════

@app.route('/uploads/<path:filename>')
def serve_upload(filename):
    """سرو فایل‌های آپلود شده با پشتیبانی از Range (برای streaming)"""
    filepath = os.path.join(UPLOAD_FOLDER, filename)
    if not os.path.exists(filepath):
        return jsonify({'success': False, 'message': 'فایل یافت نشد'}), 404
    return send_file(filepath, conditional=True)


@app.route('/uploads/pdf/<path:filename>')
def serve_pdf(filename):
    """سرو PDF برای نمایش در مرورگر"""
    return send_from_directory(PDF_FOLDER, filename)


# ═══════════════════════════════════════════════════════════════════
#  ۷. صفحه اصلی
# ═══════════════════════════════════════════════════════════════════

@app.route('/')
def index():
    return jsonify({
        'success': True,
        'message': '✅ API کتابخانه شهید حاج قاسم سلیمانی فعال است',
        'version': '2.0.0',
        'db_path': DB_PATH,
        'endpoints': {
            'auth': '/api/auth',
            'books': '/api/books',
            'categories': '/api/categories',
            'users': '/api/users',
            'uploads': '/uploads',
        },
    })


# ═══════════════════════════════════════════════════════════════════
#  ۸. احراز هویت
# ═══════════════════════════════════════════════════════════════════

@app.route('/api/auth/register', methods=['POST'])
def register():
    data = request.get_json() or {}
    name = data.get('name', '').strip()
    email = data.get('email', '').strip().lower()
    password = data.get('password', '')

    if not name or not email or not password:
        return jsonify({'success': False, 'message': 'همه فیلدها الزامی هستند'}), 400

    if len(password) < 6:
        return jsonify({
            'success': False,
            'message': 'رمز عبور باید حداقل ۶ کاراکتر باشد',
        }), 400

    if User.query.filter_by(email=email).first():
        return jsonify({
            'success': False,
            'message': 'این ایمیل قبلاً ثبت شده است',
        }), 400

    user = User(name=name, email=email)
    user.set_password(password)
    db.session.add(user)
    db.session.commit()

    token = create_access_token(identity=user.id)
    return jsonify({
        'success': True,
        'message': 'ثبت‌نام با موفقیت انجام شد',
        'token': token,
        'user': user.to_dict(),
    }), 201


@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.get_json() or {}
    email = data.get('email', '').strip().lower()
    password = data.get('password', '')

    if not email or not password:
        return jsonify({
            'success': False,
            'message': 'ایمیل و رمز عبور الزامی هستند',
        }), 400

    user = User.query.filter_by(email=email).first()
    if not user or not user.check_password(password):
        return jsonify({
            'success': False,
            'message': 'ایمیل یا رمز عبور اشتباه است',
        }), 401

    if not user.is_active:
        return jsonify({
            'success': False,
            'message': 'حساب کاربری غیرفعال است',
        }), 403

    token = create_access_token(identity=user.id)
    return jsonify({
        'success': True,
        'message': 'ورود موفقیت‌آمیز بود',
        'token': token,
        'user': user.to_dict(),
    })


@app.route('/api/auth/me', methods=['GET'])
@jwt_required()
def get_me():
    user = User.query.get(get_jwt_identity())
    if not user:
        return jsonify({'success': False, 'message': 'کاربر یافت نشد'}), 404
    return jsonify({'success': True, 'user': user.to_dict()})


# ═══════════════════════════════════════════════════════════════════
#  ۹. کتاب‌ها
# ═══════════════════════════════════════════════════════════════════

@app.route('/api/books', methods=['GET'])
def get_books():
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 20, type=int)
    category_id = request.args.get('category', type=int)
    featured = request.args.get('isFeatured', type=lambda x: x.lower() == 'true')

    query = Book.query.filter_by(is_published=True)
    if category_id:
        query = query.filter_by(category_id=category_id)
    if featured is not None:
        query = query.filter_by(is_featured=featured)

    pagination = query.order_by(Book.created_at.desc()).paginate(
        page=page, per_page=limit, error_out=False
    )

    return jsonify({
        'success': True,
        'count': len(pagination.items),
        'page': page,
        'pages': pagination.pages,
        'total': pagination.total,
        'books': [b.to_dict() for b in pagination.items],
    })


@app.route('/api/books/<int:book_id>', methods=['GET'])
def get_book(book_id):
    book = Book.query.get(book_id)
    if not book:
        return jsonify({'success': False, 'message': 'کتاب یافت نشد'}), 404
    return jsonify({'success': True, 'book': book.to_dict()})


@app.route('/api/books/search', methods=['GET'])
def search_books():
    q = request.args.get('q', '').strip()
    if not q:
        return jsonify({'success': True, 'count': 0, 'books': []})

    pattern = f'%{q}%'
    books = Book.query.filter(
        Book.is_published == True,
        or_(
            Book.title.ilike(pattern),
            Book.author.ilike(pattern),
            Book.description.ilike(pattern),
        )
    ).limit(30).all()

    return jsonify({
        'success': True,
        'count': len(books),
        'books': [b.to_dict() for b in books],
    })


@app.route('/api/books/audio', methods=['GET'])
def get_audio_books():
    books = Book.query.filter(
        Book.audio_url.isnot(None), Book.is_published == True,
    ).order_by(Book.created_at.desc()).all()

    return jsonify({
        'success': True,
        'count': len(books),
        'books': [b.to_dict() for b in books],
    })


@app.route('/api/books/video', methods=['GET'])
def get_video_books():
    books = Book.query.filter(
        Book.video_url.isnot(None), Book.is_published == True,
    ).order_by(Book.created_at.desc()).all()

    return jsonify({
        'success': True,
        'count': len(books),
        'books': [b.to_dict() for b in books],
    })


@app.route('/api/books', methods=['POST'])
@admin_required
def create_book():
    data = request.form.to_dict() if request.form else (request.get_json() or {})

    required = ['title', 'author', 'description', 'categoryId']
    for field in required:
        if not data.get(field):
            return jsonify({
                'success': False,
                'message': f'فیلد {field} الزامی است',
            }), 400

    if not Category.query.get(int(data['categoryId'])):
        return jsonify({
            'success': False,
            'message': 'دسته‌بندی یافت نشد',
        }), 404

    try:
        cover_url = None
        if 'cover' in request.files:
            cover_url = save_file(request.files['cover'], COVER_FOLDER, ALLOWED_IMAGES)

        pdf_url = None
        if 'pdf' in request.files:
            pdf_url = save_file(request.files['pdf'], PDF_FOLDER, ALLOWED_PDFS)

        audio_url = None
        if 'audio' in request.files:
            audio_url = save_file(request.files['audio'], AUDIO_FOLDER, ALLOWED_AUDIOS)

        video_url = None
        if 'video' in request.files:
            video_url = save_file(request.files['video'], VIDEO_FOLDER, ALLOWED_VIDEOS)
    except ValueError as e:
        return jsonify({'success': False, 'message': str(e)}), 400

    if not cover_url and not data.get('coverUrl'):
        return jsonify({
            'success': False,
            'message': 'تصویر جلد الزامی است',
        }), 400

    is_featured_val = data.get('isFeatured', False)
    if isinstance(is_featured_val, str):
        is_featured_val = is_featured_val.lower() == 'true'

    book = Book(
        title=data['title'],
        author=data['author'],
        description=data['description'],
        cover_url=cover_url or data.get('coverUrl'),
        pdf_url=pdf_url or data.get('pdfUrl'),
        audio_url=audio_url or data.get('audioUrl'),
        video_url=video_url or data.get('videoUrl'),
        category_id=int(data['categoryId']),
        page_count=int(data.get('pageCount', 0)),
        duration=data.get('duration'),
        language=data.get('language', 'فارسی'),
        tags=data.get('tags', '[]'),
        is_featured=bool(is_featured_val),
    )

    db.session.add(book)
    db.session.commit()

    return jsonify({
        'success': True,
        'message': 'کتاب با موفقیت اضافه شد',
        'book': book.to_dict(),
    }), 201


@app.route('/api/books/<int:book_id>', methods=['PUT'])
@admin_required
def update_book(book_id):
    book = Book.query.get(book_id)
    if not book:
        return jsonify({'success': False, 'message': 'کتاب یافت نشد'}), 404

    data = request.form.to_dict() if request.form else (request.get_json() or {})

    if 'title' in data:
        book.title = data['title']
    if 'author' in data:
        book.author = data['author']
    if 'description' in data:
        book.description = data['description']
    if 'categoryId' in data:
        book.category_id = int(data['categoryId'])
    if 'pageCount' in data:
        book.page_count = int(data['pageCount'])
    if 'duration' in data:
        book.duration = data['duration']

    try:
        if 'cover' in request.files:
            delete_file(book.cover_url)
            book.cover_url = save_file(request.files['cover'], COVER_FOLDER, ALLOWED_IMAGES)
        if 'pdf' in request.files:
            delete_file(book.pdf_url)
            book.pdf_url = save_file(request.files['pdf'], PDF_FOLDER, ALLOWED_PDFS)
        if 'audio' in request.files:
            delete_file(book.audio_url)
            book.audio_url = save_file(request.files['audio'], AUDIO_FOLDER, ALLOWED_AUDIOS)
        if 'video' in request.files:
            delete_file(book.video_url)
            book.video_url = save_file(request.files['video'], VIDEO_FOLDER, ALLOWED_VIDEOS)
    except ValueError as e:
        return jsonify({'success': False, 'message': str(e)}), 400

    db.session.commit()
    return jsonify({
        'success': True,
        'message': 'کتاب با موفقیت ویرایش شد',
        'book': book.to_dict(),
    })


@app.route('/api/books/<int:book_id>', methods=['DELETE'])
@admin_required
def delete_book(book_id):
    book = Book.query.get(book_id)
    if not book:
        return jsonify({'success': False, 'message': 'کتاب یافت نشد'}), 404

    delete_file(book.cover_url)
    delete_file(book.pdf_url)
    delete_file(book.audio_url)
    delete_file(book.video_url)

    db.session.delete(book)
    db.session.commit()
    return jsonify({'success': True, 'message': 'کتاب حذف شد'})


@app.route('/api/books/<int:book_id>/download', methods=['POST'])
@jwt_required()
def track_download(book_id):
    user_id = get_jwt_identity()
    data = request.get_json() or {}
    download_type = data.get('type', 'pdf')

    book = Book.query.get(book_id)
    if not book:
        return jsonify({'success': False, 'message': 'کتاب یافت نشد'}), 404

    download = Download(user_id=user_id, book_id=book_id, download_type=download_type)
    book.download_count += 1
    db.session.add(download)
    db.session.commit()

    return jsonify({'success': True, 'message': 'دانلود ثبت شد'})


# ═══════════════════════════════════════════════════════════════════
#  ۱۰. دسته‌بندی‌ها
# ═══════════════════════════════════════════════════════════════════

@app.route('/api/categories', methods=['GET'])
def get_categories():
    categories = Category.query.filter_by(is_active=True).all()
    return jsonify({
        'success': True,
        'count': len(categories),
        'categories': [c.to_dict() for c in categories],
    })


@app.route('/api/categories/<int:category_id>', methods=['GET'])
def get_category(category_id):
    category = Category.query.get(category_id)
    if not category:
        return jsonify({'success': False, 'message': 'دسته‌بندی یافت نشد'}), 404
    return jsonify({'success': True, 'category': category.to_dict()})


@app.route('/api/categories', methods=['POST'])
@admin_required
def create_category():
    data = request.get_json() or {}
    if not data.get('name'):
        return jsonify({'success': False, 'message': 'نام الزامی است'}), 400

    if Category.query.filter_by(name=data['name']).first():
        return jsonify({
            'success': False,
            'message': 'این دسته‌بندی قبلاً وجود دارد',
        }), 400

    category = Category(
        name=data['name'],
        slug=data['name'].lower().replace(' ', '-'),
        icon=data.get('icon', 'book'),
        color=data.get('color', '#1B5E20'),
        description=data.get('description'),
    )
    db.session.add(category)
    db.session.commit()

    return jsonify({
        'success': True,
        'message': 'دسته‌بندی ایجاد شد',
        'category': category.to_dict(),
    }), 201


@app.route('/api/categories/<int:category_id>', methods=['PUT'])
@admin_required
def update_category(category_id):
    category = Category.query.get(category_id)
    if not category:
        return jsonify({'success': False, 'message': 'دسته‌بندی یافت نشد'}), 404

    data = request.get_json() or {}
    if 'name' in data:
        category.name = data['name']
        category.slug = data['name'].lower().replace(' ', '-')
    if 'icon' in data:
        category.icon = data['icon']
    if 'color' in data:
        category.color = data['color']
    if 'description' in data:
        category.description = data['description']

    db.session.commit()
    return jsonify({'success': True, 'category': category.to_dict()})


@app.route('/api/categories/<int:category_id>', methods=['DELETE'])
@admin_required
def delete_category(category_id):
    category = Category.query.get(category_id)
    if not category:
        return jsonify({'success': False, 'message': 'دسته‌بندی یافت نشد'}), 404

    db.session.delete(category)
    db.session.commit()
    return jsonify({'success': True, 'message': 'دسته‌بندی حذف شد'})


# ═══════════════════════════════════════════════════════════════════
#  ۱۱. کاربران
# ═══════════════════════════════════════════════════════════════════

@app.route('/api/users/profile', methods=['GET'])
@jwt_required()
def get_profile():
    user = User.query.get(get_jwt_identity())
    if not user:
        return jsonify({'success': False, 'message': 'کاربر یافت نشد'}), 404
    return jsonify({'success': True, 'user': user.to_dict()})


@app.route('/api/users/profile', methods=['PUT'])
@jwt_required()
def update_profile():
    user = User.query.get(get_jwt_identity())
    if not user:
        return jsonify({'success': False, 'message': 'کاربر یافت نشد'}), 404

    data = request.get_json() or {}
    if 'name' in data:
        user.name = data['name']
    if 'diceBearSeed' in data:
        user.dice_bear_seed = data['diceBearSeed']
    if 'avatarStyle' in data:
        user.avatar_style = data['avatarStyle']
    if 'themeColor' in data:
        user.theme_color = data['themeColor']
    if 'isDarkMode' in data:
        user.is_dark_mode = data['isDarkMode']

    db.session.commit()
    return jsonify({
        'success': True,
        'message': 'پروفایل به‌روزرسانی شد',
        'user': user.to_dict(),
    })


@app.route('/api/users/favorites', methods=['GET'])
@jwt_required()
def get_favorites():
    user_id = get_jwt_identity()
    favorites = Favorite.query.filter_by(user_id=user_id).all()
    books = [Book.query.get(f.book_id) for f in favorites]
    books = [b for b in books if b is not None]

    return jsonify({
        'success': True,
        'count': len(books),
        'books': [b.to_dict() for b in books],
    })


@app.route('/api/users/favorites/<int:book_id>', methods=['POST'])
@jwt_required()
def toggle_favorite(book_id):
    user_id = get_jwt_identity()
    book = Book.query.get(book_id)
    if not book:
        return jsonify({'success': False, 'message': 'کتاب یافت نشد'}), 404

    existing = Favorite.query.filter_by(user_id=user_id, book_id=book_id).first()
    if existing:
        db.session.delete(existing)
        db.session.commit()
        return jsonify({
            'success': True,
            'isFavorite': False,
            'message': 'از علاقه‌مندی‌ها حذف شد',
        })
    else:
        favorite = Favorite(user_id=user_id, book_id=book_id)
        db.session.add(favorite)
        db.session.commit()
        return jsonify({
            'success': True,
            'isFavorite': True,
            'message': 'به علاقه‌مندی‌ها اضافه شد',
        })


# ═══════════════════════════════════════════════════════════════════
#  ۱۲. اجرا
# ═══════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
        print('═' * 60)
        print('✅ دیتابیس ایجاد/بررسی شد')
        print(f'🗄️  مسیر دیتابیس: {DB_PATH}')
        print(f'📁 پوشه آپلود: {UPLOAD_FOLDER}')
        print('🚀 سرور روی پورت 5000 در حال اجراست')
        print('📍 آدرس: http://localhost:5000')
        print('═' * 60)
        print('💡 برای پر کردن دیتابیس با داده‌های نمونه، اجرا کن:')
        print('   python seed.py')
        print('═' * 60)

    app.run(host='0.0.0.0', port=5000, debug=True)