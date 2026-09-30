"""
═══════════════════════════════════════════════════════════════════════
   فایل Seed - پر کردن دیتابیس با داده‌های اولیه
   کتابخانه شهید حاج قاسم سلیمانی
═══════════════════════════════════════════════════════════════════════
   نحوه استفاده:
   ۱. فایل‌های PDF/MP3/MP4/تصاویر را در پوشه‌های uploads/ قرار بده
   ۲. لیست زیر (BOOKS_DATA) را ویرایش کن
   ۳. اجرا کن:  python seed.py
═══════════════════════════════════════════════════════════════════════
"""

import os
from app import app, db, User, Category, Book

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
BASE_URL = os.getenv('BASE_URL', 'http://localhost:5000')

# ═══════════════════════════════════════════════════════════════════
#  📝 داده‌های کتاب‌ها
#  ─────────────────────────────────────────────────────────────────
#  نکته: فایل‌ها را در پوشه‌های زیر قرار بده:
#    - تصاویر جلد:  uploads/covers/
#    - فایل PDF:    uploads/pdfs/
#    - فایل صوتی:   uploads/audios/
#    - فایل ویدیو:  uploads/videos/
#
#  فقط نام فایل را در فیلد مربوطه بنویس (بدون مسیر پوشه)
# ═══════════════════════════════════════════════════════════════════

BOOKS_DATA = [
    # ────────────────────────────────────────────
    #  📚 کتاب ۱: با PDF و MP3
    # ────────────────────────────────────────────
    {
        'title': 'زندگینامه شهید حاج قاسم سلیمانی',
        'author': 'مجتبی پورمحسن',
        'description': 'کتابی جامع درباره زندگی، مبارزات و خاطرات شهید سپهبد حاج قاسم سلیمانی، از دوران کودکی در روستای قنات ملک تا شهادت در بغداد. این کتاب روایتی مستند و خواندنی از زندگی مردی است که به «سردار دلها» معروف شد.',
        'category_slug': 'دفاع-مقدس',
        'cover_file': 'soleimani-cover.jpg',      # uploads/covers/soleimani-cover.jpg
        'pdf_file': 'soleimani.pdf',              # uploads/pdfs/soleimani.pdf
        'audio_file': None,                       # بدون کتاب صوتی
        'video_file': None,                       # بدون ویدیو
        'rating': 4.9,
        'page_count': 320,
        'language': 'فارسی',
        'tags': ['شهید سلیمانی', 'زندگینامه', 'دفاع مقدس'],
        'is_featured': True,
    },

    # ────────────────────────────────────────────
    #  🎧 کتاب ۲: کتاب صوتی (فقط MP3)
    # ────────────────────────────────────────────
    {
        'title': 'از چیزی نمی‌ترسم',
        'author': 'به روایت احمد یوسف‌زاده',
        'description': 'کتابی درباره زندگی پر فراز و نشیب احمد یوسف‌زاده، آزاده سرافراز دفاع مقدس که ۸ سال در اسارت رژیم بعث بود. این کتاب صوتی روایتی شنیدنی از صبر و مقاومت است.',
        'category_slug': 'دفاع-مقدس',
        'cover_file': 'az-chizi-nemitarsam.jpg',
        'pdf_file': None,
        'audio_file': 'az-chizi-nemitarsam.mp3',  # uploads/audios/...
        'video_file': None,
        'rating': 4.8,
        'page_count': 0,
        'duration': '5:32:18',
        'language': 'فارسی',
        'tags': ['کتاب صوتی', 'اسارت', 'دفاع مقدس'],
        'is_featured': True,
    },

    # ────────────────────────────────────────────
    #  🎬 کتاب ۳: با ویدیو (MP4)
    # ────────────────────────────────────────────
    {
        'title': 'مستند سردار دلها',
        'author': 'گروه رسانه‌ای مکتب حاج قاسم',
        'description': 'مستند تصویری کامل از سفرهای شهید سلیمانی به مناطق جنگی، جلسات، و سخنرانی‌های ایشان. این ویدیو شامل تصاویر کمتر دیده شده از سردار دلهاست.',
        'category_slug': 'دفاع-مقدس',
        'cover_file': 'documentary-cover.jpg',
        'pdf_file': None,
        'audio_file': None,
        'video_file': 'soleimani-documentary.mp4', # uploads/videos/...
        'rating': 5.0,
        'page_count': 0,
        'duration': '1:45:00',
        'language': 'فارسی',
        'tags': ['مستند', 'ویدیو', 'شهید سلیمانی'],
        'is_featured': True,
    },

    # ────────────────────────────────────────────
    #  📚 کتاب ۴: PDF کامل
    # ────────────────────────────────────────────
    {
        'title': 'هفته دفاع مقدس',
        'author': 'مرتضی سرهنگی',
        'description': 'مروری بر هشت سال دفاع مقدس، عملیات‌های بزرگ، و خاطرات رزمندگان. این کتاب برای آشنایی نسل جدید با تاریخ جنگ تحمیلی نوشته شده است.',
        'category_slug': 'تاریخی',
        'cover_file': 'defa-moghadas.jpg',
        'pdf_file': 'defa-moghadas.pdf',
        'audio_file': None,
        'video_file': None,
        'rating': 4.6,
        'page_count': 450,
        'language': 'فارسی',
        'tags': ['تاریخ', 'جنگ', 'دفاع مقدس'],
        'is_featured': False,
    },

    # ────────────────────────────────────────────
    #  📚 کتاب ۵: PDF + صوتی
    # ────────────────────────────────────────────
    {
        'title': 'قصه‌های قرآنی برای کودکان',
        'author': 'مهدی الهی قمشه‌ای',
        'description': 'مجموعه‌ای از داستان‌های قرآنی به زبان ساده برای کودکان. این کتاب با تصاویر زیبا و روایت دلنشین، مفاهیم قرآنی را به کودکان آموزش می‌دهد.',
        'category_slug': 'کودک',
        'cover_file': 'quran-kids.jpg',
        'pdf_file': 'quran-kids.pdf',
        'audio_file': 'quran-kids.mp3',
        'video_file': None,
        'rating': 4.7,
        'page_count': 120,
        'duration': '2:15:30',
        'language': 'فارسی',
        'tags': ['کودک', 'قرآن', 'آموزشی'],
        'is_featured': True,
    },

    # ────────────────────────────────────────────
    #  📚 کتاب ۶: رمان
    # ────────────────────────────────────────────
    {
        'title': 'دا',
        'author': 'زهرا حسینی',
        'description': 'خاطرات زهرا حسینی از روزهای آغاز جنگ تحمیلی در خرمشهر. کتاب «دا» یکی از پرفروش‌ترین کتاب‌های خاطرات جنگ در ایران است.',
        'category_slug': 'تاریخی',
        'cover_file': 'da.jpg',
        'pdf_file': 'da.pdf',
        'audio_file': 'da.mp3',
        'video_file': None,
        'rating': 4.9,
        'page_count': 812,
        'duration': '18:20:45',
        'language': 'فارسی',
        'tags': ['خاطرات', 'جنگ', 'خرمشهر'],
        'is_featured': True,
    },

    # ═══════════════════════════════════════════════════════════════
    #  👇 کتاب‌های بیشتری اینجا اضافه کن
    # ═══════════════════════════════════════════════════════════════
]


# ═══════════════════════════════════════════════════════════════════
#  📂 دسته‌بندی‌های پیش‌فرض
# ═══════════════════════════════════════════════════════════════════

CATEGORIES_DATA = [
    {'name': 'رمان',         'icon': 'auto_stories',  'color': '#E91E63'},
    {'name': 'تاریخی',       'icon': 'history_edu',   'color': '#795548'},
    {'name': 'علمی',         'icon': 'science',       'color': '#2196F3'},
    {'name': 'کودک',         'icon': 'child_care',    'color': '#FF9800'},
    {'name': 'مذهبی',        'icon': 'mosque',        'color': '#1B5E20'},
    {'name': 'دفاع مقدس',    'icon': 'military_tech', 'color': '#B71C1C'},
    {'name': 'شعر و ادب',    'icon': 'menu_book',     'color': '#9C27B0'},
    {'name': 'فلسفه',        'icon': 'psychology',    'color': '#607D8B'},
]


# ═══════════════════════════════════════════════════════════════════
#  🛠️ توابع کمکی
# ═══════════════════════════════════════════════════════════════════

def file_exists(folder, filename):
    """بررسی وجود فایل در پوشه"""
    if not filename:
        return False
    filepath = os.path.join(BASE_DIR, 'uploads', folder, filename)
    return os.path.exists(filepath)


def build_url(folder, filename):
    """ساخت URL کامل فایل"""
    if not filename:
        return None
    return f'{BASE_URL}/uploads/{folder}/{filename}'


def get_file_size_mb(folder, filename):
    """محاسبه حجم فایل به مگابایت"""
    if not filename:
        return '0 MB'
    filepath = os.path.join(BASE_DIR, 'uploads', folder, filename)
    if not os.path.exists(filepath):
        return '0 MB'
    size_bytes = os.path.getsize(filepath)
    size_mb = size_bytes / (1024 * 1024)
    if size_mb < 1:
        return f'{size_bytes / 1024:.0f} KB'
    return f'{size_mb:.1f} MB'


# ═══════════════════════════════════════════════════════════════════
#  🌱 تابع اصلی Seed
# ═══════════════════════════════════════════════════════════════════

def seed():
    with app.app_context():
        print('═' * 70)
        print('🌱 شروع پر کردن دیتابیس کتابخانه شهید حاج قاسم سلیمانی')
        print('═' * 70)

        # ── ۱. ایجاد جداول ──
        db.create_all()
        print('✅ جداول دیتابیس ایجاد شدند')

        # ── ۲. ایجاد ادمین ──
        admin_email = 'admin@shahid-library.ir'
        if not User.query.filter_by(email=admin_email).first():
            admin = User(
                name='مدیر کتابخانه',
                email=admin_email,
                role='admin',
            )
            admin.set_password('admin123456')
            db.session.add(admin)
            db.session.commit()
            print(f'✅ ادمین ایجاد شد: {admin_email} / admin123456')
        else:
            print(f'ℹ️  ادمین از قبل وجود دارد: {admin_email}')

        # ── ۳. ایجاد کاربر نمونه ──
        user_email = 'user@shahid-library.ir'
        if not User.query.filter_by(email=user_email).first():
            user = User(name='کاربر نمونه', email=user_email)
            user.set_password('user123456')
            db.session.add(user)
            db.session.commit()
            print(f'✅ کاربر نمونه ایجاد شد: {user_email} / user123456')

        # ── ۴. ایجاد دسته‌بندی‌ها ──
        categories_map = {}
        for cat_data in CATEGORIES_DATA:
            existing = Category.query.filter_by(name=cat_data['name']).first()
            if not existing:
                category = Category(
                    name=cat_data['name'],
                    slug=cat_data['name'].lower().replace(' ', '-'),
                    icon=cat_data['icon'],
                    color=cat_data['color'],
                )
                db.session.add(category)
                db.session.flush()
                categories_map[category.slug] = category
                print(f'   ➕ دسته‌بندی: {cat_data["name"]}')
            else:
                categories_map[existing.slug] = existing
                print(f'   ℹ️  دسته‌بندی موجود: {cat_data["name"]}')

        db.session.commit()
        print(f'✅ {len(categories_map)} دسته‌بندی آماده شد')

        # ── ۵. ایجاد کتاب‌ها ──
        print()
        print('📚 در حال افزودن کتاب‌ها...')
        print('─' * 70)

        added_count = 0
        skipped_count = 0
        missing_files = []

        for book_data in BOOKS_DATA:
            # بررسی تکراری نبودن
            if Book.query.filter_by(title=book_data['title']).first():
                print(f'   ⏭️  رد شد (تکراری): {book_data["title"]}')
                skipped_count += 1
                continue

            # پیدا کردن دسته‌بندی
            category = categories_map.get(book_data['category_slug'])
            if not category:
                print(f'   ❌ دسته‌بندی یافت نشد: {book_data["category_slug"]}')
                continue

            # بررسی وجود فایل‌ها و ساخت URL
            cover_url = None
            if book_data.get('cover_file'):
                if file_exists('covers', book_data['cover_file']):
                    cover_url = build_url('covers', book_data['cover_file'])
                else:
                    missing_files.append(f'covers/{book_data["cover_file"]}')

            pdf_url = None
            if book_data.get('pdf_file'):
                if file_exists('pdfs', book_data['pdf_file']):
                    pdf_url = build_url('pdfs', book_data['pdf_file'])
                else:
                    missing_files.append(f'pdfs/{book_data["pdf_file"]}')

            audio_url = None
            if book_data.get('audio_file'):
                if file_exists('audios', book_data['audio_file']):
                    audio_url = build_url('audios', book_data['audio_file'])
                else:
                    missing_files.append(f'audios/{book_data["audio_file"]}')

            video_url = None
            if book_data.get('video_file'):
                if file_exists('videos', book_data['video_file']):
                    video_url = build_url('videos', book_data['video_file'])
                else:
                    missing_files.append(f'videos/{book_data["video_file"]}')

            # اگر جلد وجود نداشت، از یک تصویر placeholder استفاده کن
            if not cover_url:
                cover_url = f'{BASE_URL}/uploads/covers/placeholder.jpg'
                print(f'   ⚠️  جلد یافت نشد، placeholder استفاده شد: {book_data["title"]}')

            # ساخت کتاب
            book = Book(
                title=book_data['title'],
                author=book_data['author'],
                description=book_data['description'],
                cover_url=cover_url,
                pdf_url=pdf_url,
                audio_url=audio_url,
                video_url=video_url,
                category_id=category.id,
                rating=book_data.get('rating', 0.0),
                page_count=book_data.get('page_count', 0),
                duration=book_data.get('duration'),
                language=book_data.get('language', 'فارسی'),
                tags=json.dumps(book_data.get('tags', []), ensure_ascii=False),
                is_featured=book_data.get('is_featured', False),
                file_size=get_file_size_mb('pdfs', book_data.get('pdf_file')),
            )

            db.session.add(book)
            added_count += 1

            # نمایش اطلاعات
            types = []
            if pdf_url: types.append('PDF')
            if audio_url: types.append('MP3')
            if video_url: types.append('MP4')
            types_str = ' + '.join(types) if types else 'بدون فایل'

            print(f'   ✅ {book_data["title"]} [{types_str}]')

        db.session.commit()

        # ── ۶. نمایش خلاصه ──
        print()
        print('═' * 70)
        print('📊 خلاصه Seed:')
        print(f'   ✅ کتاب‌های اضافه شده: {added_count}')
        print(f'   ⏭️  کتاب‌های رد شده (تکراری): {skipped_count}')
        print(f'   📚 کل کتاب‌ها در دیتابیس: {Book.query.count()}')
        print(f'   👥 کل کاربران: {User.query.count()}')
        print(f'   🏷️  کل دسته‌بندی‌ها: {Category.query.count()}')

        if missing_files:
            print()
            print('⚠️  فایل‌های یافت نشده (لطفاً در پوشه مربوطه قرار بده):')
            for f in missing_files:
                print(f'   ❌ uploads/{f}')
            print()
            print('💡 پس از افزودن فایل‌ها، دوباره seed.py را اجرا کن.')

        print('═' * 70)
        print('🎉 Seed با موفقیت کامل شد!')
        print('═' * 70)


# ═══════════════════════════════════════════════════════════════════
#  🚀 اجرا
# ═══════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    import json  # اضافه شده در بالای فایل هم می‌تواند باشد
    seed()