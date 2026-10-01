import random
from datetime import datetime, timedelta
from models import db, User, Book, Rating, UserActivity

class RuleBasedAIEngine:
    """
    موتور هوش مصنوعی شرطی برای کتابخانه شهید سلیمانی
    - توصیه کتاب بر اساس سابقه مطالعه و علاقه‌مندی‌ها
    - تولید پیام‌های انگیزشی بر اساس وضعیت کاربر
    """

    def __init__(self):
        # قوانین انگیزشی
        self.motivational_messages = {
            'welcome_back': [
                "سلام {name} عزیز! خوش آمدی. امروز چه کتابی رو شروع می‌کنی؟",
                "برگشتی! {name} جان، کتابخانه منتظرته. بیا یه کتاب خوب انتخاب کنیم.",
            ],
            'streak_3': [
                "{name} عزیز، ۳ روز متوالی مطالعه! عالیه، همینطور ادامه بده.",
                "آفرین {name} جان! استمرار کلید موفقیتت. ۳ روز پشت سر هم مطالعه کردی.",
            ],
            'streak_7': [
                "یک هفته کامل مطالعه! {name}، تو یه قهرمان واقعی هستی.",
                "{name} عزیز، ۷ روز متوالی! این یعنی تعهد. بهت افتخار می‌کنیم.",
            ],
            'streak_30': [
                "یک ماه کامل! {name}، تو الگوی دیگرانی. شهید سلیمانی بهت افتخار می‌کنه.",
                "{name} جان، ۳۰ روز متوالی مطالعه! این یعنی عشق به دانش.",
            ],
            'inactive_3': [
                "{name} عزیز، دلمون برات تنگ شده. یه سر به کتابخانه بزن.",
                "چند روزی نیستی {name} جان. یه کتاب کوتاه شروع کن، دوباره گرم می‌شی.",
            ],
            'completed_book': [
                "تبریک {name}! کتاب «{book_title}» رو تموم کردی. کتاب بعدی چیه؟",
                "آفرین {name} جان! «{book_title}» رو تموم کردی. امتیازت رو ثبت کن.",
            ],
            'new_book': [
                "{name} عزیز، کتاب جدید «{book_title}» اضافه شد. حتماً ببین.",
                "یه کتاب تازه {name} جان! «{book_title}» منتظرته.",
            ],
            'general': [
                "{name} عزیز، امروز یه کتاب خوب بخون. حتی ۱۰ دقیقه.",
                "کتاب بهترین دوسته {name} جان. امروز با یه کتاب دوست شو.",
                "شهید سلیمانی می‌گفت: «هرچه داریم از کتاب و مطالعه است.» {name} جان.",
            ]
        }

        # قوانین توصیه کتاب بر اساس دسته‌بندی
        self.category_rules = {
            'pdf': 'کتاب', 'audio': 'کتاب صوتی', 'video': 'پادکست تصویری'
        }

        # دسته‌بندی‌های مورد علاقه بر اساس سابقه
        self.preference_weights = {
            'pdf': 1.0, 'audio': 1.2, 'video': 1.1
        }

    def get_motivational_message(self, user, activity=None):
        """تولید پیام انگیزشی بر اساس وضعیت کاربر"""
        # بررسی استریک
        if activity:
            streak = activity.current_streak
            if streak >= 30:
                template = random.choice(self.motivational_messages['streak_30'])
            elif streak >= 7:
                template = random.choice(self.motivational_messages['streak_7'])
            elif streak >= 3:
                template = random.choice(self.motivational_messages['streak_3'])
            else:
                template = random.choice(self.motivational_messages['general'])
        else:
            template = random.choice(self.motivational_messages['general'])

        return template.format(name=user.name, book_title='')

    def get_book_recommendations(self, user, limit=5):
        """
        توصیه کتاب بر اساس قوانین شرطی:
        1. کتاب‌هایی که کاربر نخوانده
        2. کتاب‌های با امتیاز بالا
        3. کتاب‌های مشابه کتاب‌های خوانده شده
        4. کتاب‌های جدید
        """
        # کتاب‌های خوانده شده کاربر
        read_books = UserActivity.query.filter_by(
            user_id=user.id, action='read'
        ).all()
        read_book_ids = [a.book_id for a in read_books]

        # کتاب‌های با امتیاز بالا که خوانده نشده‌اند
        high_rated = Book.query.filter(
            Book.id.notin_(read_book_ids),
            Book.rating >= 4.0
        ).order_by(Book.rating.desc()).limit(3).all()

        # کتاب‌های جدید
        recent_books = Book.query.filter(
            Book.id.notin_(read_book_ids),
            Book.created_at >= datetime.utcnow() - timedelta(days=30)
        ).order_by(Book.created_at.desc()).limit(2).all()

        # ترکیب و حذف تکراری‌ها
        recommendations = []
        seen_ids = set()
        for book in high_rated + recent_books:
            if book.id not in seen_ids:
                recommendations.append(book)
                seen_ids.add(book.id)

        # اگر تعداد کمتر از limit بود، کتاب‌های تصادفی اضافه کن
        if len(recommendations) < limit:
            remaining = Book.query.filter(
                Book.id.notin_(read_book_ids + list(seen_ids))
            ).limit(limit - len(recommendations)).all()
            recommendations.extend(remaining)

        return recommendations[:limit]

    def get_user_stats(self, user):
        """آمار کاربر برای نمایش در پروفایل"""
        activities = UserActivity.query.filter_by(user_id=user.id).all()
        total_read = len([a for a in activities if a.action == 'read'])
        total_minutes = sum(a.minutes_read or 0 for a in activities)
        streak = max([a.current_streak for a in activities], default=0)

        return {
            'total_books_read': total_read,
            'total_minutes_read': total_minutes,
            'current_streak': streak,
            'badges': self.get_badges(user, total_read, streak)
        }

    def get_badges(self, user, total_read, streak):
        """محاسبه نشان‌های کسب شده بر اساس قوانین"""
        badges = []
        if total_read >= 1:
            badges.append({'name': 'شروع‌کننده', 'icon': '📖'})
        if total_read >= 5:
            badges.append({'name': 'کتاب‌خوان', 'icon': '📚'})
        if total_read >= 20:
            badges.append({'name': 'کتاب‌خوار', 'icon': '🍽️'})
        if streak >= 3:
            badges.append({'name': 'مستمر', 'icon': '🔥'})
        if streak >= 7:
            badges.append({'name': 'قهرمان هفته', 'icon': '🏆'})
        if streak >= 30:
            badges.append({'name': 'افسانه', 'icon': '👑'})
        return badges