from datetime import datetime
from flask_sqlalchemy import SQLAlchemy

# ==================== نمونه دیتابیس ====================
db = SQLAlchemy()


# ==================== کاربران ====================
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


# ==================== کتاب‌ها ====================
class Book(db.Model):
    __tablename__ = 'books'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    author = db.Column(db.String(200))
    description = db.Column(db.Text)
    cover_url = db.Column(db.String(500))       # URL کاور
    cover_path = db.Column(db.String(500))      # مسیر فیزیکی کاور
    file_url = db.Column(db.String(500))
    file_path = db.Column(db.String(500))
    file_size = db.Column(db.Integer, default=0)  # حجم فایل به بایت
    type = db.Column(db.String(20), nullable=False)
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
            'file_size': self.file_size,
            'type': self.type,
            'category': self.category,
            'rating': self.rating,
            'rating_count': self.rating_count,
        }


# ==================== امتیازات ====================
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


# ==================== فعالیت‌های کاربر ====================
class UserActivity(db.Model):
    __tablename__ = 'user_activities'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    book_id = db.Column(db.Integer, db.ForeignKey('books.id'))
    action = db.Column(db.String(20))  # read, listen, watch, complete
    minutes_read = db.Column(db.Integer, default=0)
    current_streak = db.Column(db.Integer, default=1)
    last_activity = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'book_id': self.book_id,
            'action': self.action,
            'minutes_read': self.minutes_read,
            'current_streak': self.current_streak,
            'last_activity': self.last_activity.isoformat(),
        }


# ==================== حلقه‌های مطالعه ====================
class ReadingCircle(db.Model):
    __tablename__ = 'reading_circles'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    book_id = db.Column(db.Integer, db.ForeignKey('books.id'))
    created_by = db.Column(db.Integer, db.ForeignKey('users.id'))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    members = db.relationship(
        'CircleMember',
        backref='circle',
        lazy=True,
        cascade='all, delete-orphan',
    )


class CircleMember(db.Model):
    __tablename__ = 'circle_members'
    id = db.Column(db.Integer, primary_key=True)
    circle_id = db.Column(
        db.Integer,
        db.ForeignKey('reading_circles.id'),
        nullable=False,
    )
    user_id = db.Column(
        db.Integer,
        db.ForeignKey('users.id'),
        nullable=False,
    )
    joined_at = db.Column(db.DateTime, default=datetime.utcnow)
    progress = db.Column(db.Float, default=0.0)


# ==================== توکن‌های FCM ====================
class FcmToken(db.Model):
    __tablename__ = 'fcm_tokens'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(
        db.Integer,
        db.ForeignKey('users.id'),
        nullable=False,
    )
    token = db.Column(db.String(500), nullable=False, unique=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)