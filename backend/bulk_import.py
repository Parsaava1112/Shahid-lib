# -*- coding: utf-8 -*-
"""
اسکریپت وارد کردن گروهی کتاب‌ها، پادکست‌ها، ویدیوها و کاورها
به دیتابیس کتابخانه شهید حاج قاسم سلیمانی

نحوه استفاده:
    1. فایل‌های خود را در پوشه assets/ قرار دهید
    2. لیست اطلاعات را در بخش MEDIA_LIST پایین پر کنید
    3. اجرا کنید: python bulk_import.py
"""

import os
import sys
import uuid
import shutil
from datetime import datetime

# ==========================================================
# تنظیمات مسیرها
# ==========================================================

BASE_DIR = os.path.abspath(os.path.dirname(__file__))
ASSETS_DIR = os.path.join(BASE_DIR, 'assets')
UPLOAD_DIR = os.path.join(BASE_DIR, 'uploads')
DB_PATH = os.path.join(BASE_DIR, 'db', 'library.db')

# پوشه‌های مقصد
DEST_BOOKS = os.path.join(UPLOAD_DIR, 'books')
DEST_AUDIO = os.path.join(UPLOAD_DIR, 'audio')
DEST_VIDEO = os.path.join(UPLOAD_DIR, 'video')
DEST_COVERS = os.path.join(UPLOAD_DIR, 'covers')

MEDIA_LIST = [
    # ============ کتاب‌ها (PDF) ============
    {
        'title': 'بینوایان جلد دوم',
        'author': 'ویکتور هوگو',
        'description': 'مجموعه‌ای از داستان دختری در فرانسه.',
        'type': 'pdf',
        'category': 'کتاب',
        'file': 'b.pdf',
        'cover': 'b.jfif',
    },
    {
        'title': 'پیرمرد و دریا',
        'author': 'ارنست همینگوی',
        'description': 'داستانی از مردی در دریا',
        'type': 'pdf',
        'category': 'کتاب',
        'file': 'man.pdf',
        'cover': 'man.jfif',
    },
    {
        'title': 'دراکولا',
        'author': 'برام استوکر',
        'description': 'دراکولا',
        'type': 'pdf',
        'category': 'کتاب',
        'file': 'dar.pdf',
        'cover': 'dar.jfif',
    },
    {
        'title': 'دور دنیا در 80 روز',
        'author': 'ژول ورن',
        'description': 'داستانی زیبا از ژول ورن',
        'type': 'pdf',
        'category': 'کتاب',
        'file': 'dor.pdf',
        'cover': 'dor.jfif',
    },
    {
        'title': 'قلعه حیوانات',
        'author': 'جورج اورول',
        'description': 'داستانی از حیوانات',
        'type': 'pdf',
        'category': 'کتاب',
        'file': 'animal.pdf',
        'cover': 'animal.jfif',
    },
    {
        'title': 'کتابخانه نیمه شب',
        'author': 'مت هیگ',
        'description': 'داستانی از کتابخانه',
        'type': 'pdf',
        'category': 'کتاب',
        'file': 'lib.pdf',
        'cover': 'lib.jfif',
    },
    {
        'title': 'فرانس کافکا',
        'author': 'صادق هدایت',
        'description': 'داستانی از یک مرد',
        'type': 'pdf',
        'category': 'کتاب',
        'file': 'far.pdf',
        'cover': 'fan.jfif',
    },
    {
        'title': 'هری پاتر و حفره اسرار آمیز',
        'author': 'جی.کی.رولینگ',
        'description': 'داستانی های هری پاتر',
        'type': 'pdf',
        'category': 'کتاب',
        'file': 'har1.pdf',
        'cover': 'har1.jfif',
    },
    {
        'title': 'هری پاتر و جام آتش 1',
        'author': 'جی.کی.رولینگ',
        'description': 'داستانی های هری پاتر',
        'type': 'pdf',
        'category': 'کتاب',
        'file': 'har2.pdf',
        'cover': 'har2.jfif',
    },
    {
        'title': 'هری پاتر و جام آتش 2',
        'author': 'جی.کی.رولینگ',
        'description': 'داستانی های هری پاتر',
        'type': 'pdf',
        'category': 'کتاب',
        'file': 'har3.pdf',
        'cover': 'har2.jfif',
    },
    {
        'title': 'هری پاتر و زندانی آزکابان',
        'author': 'جی.کی.رولینگ',
        'description': 'داستانی های هری پاتر',
        'type': 'pdf',
        'category': 'کتاب',
        'file': 'har4.pdf',
        'cover': 'har3.jfif',
    },
    {
        'title': 'هری پاتر و سنگ جادو',
        'author': 'جی.کی.رولینگ',
        'description': 'داستانی های هری پاتر',
        'type': 'pdf',
        'category': 'کتاب',
        'file': 'har5.pdf',
        'cover': 'har4.jfif',
    },
    {
        'title': 'هری پاتر و شاهزاده دورگه',
        'author': 'جی.کی.رولینگ',
        'description': 'داستانی های هری پاتر',
        'type': 'pdf',
        'category': 'کتاب',
        'file': 'har6.pdf',
        'cover': 'har5.jfif',
    },
    {
        'title': 'هری پاتر و فرزند نفرین شده',
        'author': 'جی.کی.رولینگ',
        'description': 'داستانی های هری پاتر',
        'type': 'pdf',
        'category': 'کتاب',
        'file': 'har7.pdf',
        'cover': 'har6.jfif',
    },
    {
        'title': 'هری پاتر و محفل ققنوس 1',
        'author': 'جی.کی.رولینگ',
        'description': 'داستانی های هری پاتر',
        'type': 'pdf',
        'category': 'کتاب',
        'file': 'har8.pdf',
        'cover': 'har7.jfif',
    },
    {
        'title': 'هری پاتر و محفل ققنوس 2',
        'author': 'جی.کی.رولینگ',
        'description': 'داستانی های هری پاتر',
        'type': 'pdf',
        'category': 'کتاب',
        'file': 'har9.pdf',
        'cover': 'har7.jfif',
    },
    {
        'title': 'هری پاتر و محفل ققنوس 3',
        'author': 'جی.کی.رولینگ',
        'description': 'داستانی های هری پاتر',
        'type': 'pdf',
        'category': 'کتاب',
        'file': 'har10.pdf',
        'cover': 'har7.jfif',
    },
    {
        'title': 'هری پاتر و یادگاران مرگ 1',
        'author': 'جی.کی.رولینگ',
        'description': 'داستانی های هری پاتر',
        'type': 'pdf',
        'category': 'کتاب',
        'file': 'har11.pdf',
        'cover': 'har8.jfif',
    },
    {
        'title': 'هری پاتر و یادگاران مرگ 2',
        'author': 'جی.کی.رولینگ',
        'description': 'داستانی های هری پاتر',
        'type': 'pdf',
        'category': 'کتاب',
        'file': 'har12.pdf',
        'cover': 'har8.jfif',
    },
]


# ==========================================================
# توابع کمکی
# ==========================================================

def ensure_folders():
    """ساخت پوشه‌های لازم در صورت نبودن"""
    for path in [DEST_BOOKS, DEST_AUDIO, DEST_VIDEO, DEST_COVERS]:
        os.makedirs(path, exist_ok=True)


def safe_copy(src: str, dst_dir: str) -> tuple[str, int]:
    """
    کپی امن فایل با نام یکتا.
    برمی‌گرداند: (مسیر نهایی, حجم به بایت)
    """
    if not os.path.exists(src):
        raise FileNotFoundError(f"فایل یافت نشد: {src}")

    ext = os.path.splitext(src)[1].lower()
    unique_name = f"{uuid.uuid4().hex}{ext}"
    dst = os.path.join(dst_dir, unique_name)

    shutil.copy2(src, dst)
    size = os.path.getsize(dst)
    return dst, size


def find_asset_file(filename: str, type_: str) -> str:
    """پیدا کردن فایل در پوشه assets بر اساس نوع"""
    if type_ == 'pdf':
        folder = os.path.join(ASSETS_DIR, 'books')
    elif type_ == 'audio':
        folder = os.path.join(ASSETS_DIR, 'audio')
    elif type_ == 'video':
        folder = os.path.join(ASSETS_DIR, 'video')
    else:
        raise ValueError(f"نوع نامعتبر: {type_}")

    path = os.path.join(folder, filename)
    if not os.path.exists(path):
        # جستجوی case-insensitive
        if os.path.isdir(folder):
            for f in os.listdir(folder):
                if f.lower() == filename.lower():
                    return os.path.join(folder, f)
    return path


def find_cover_file(filename: str) -> str:
    """پیدا کردن فایل کاور در پوشه assets/covers"""
    folder = os.path.join(ASSETS_DIR, 'covers')
    path = os.path.join(folder, filename)
    if not os.path.exists(path):
        if os.path.isdir(folder):
            for f in os.listdir(folder):
                if f.lower() == filename.lower():
                    return os.path.join(folder, f)
    return path


# ==========================================================
# وارد کردن به دیتابیس
# ==========================================================

def import_to_database(items):
    """وارد کردن آیتم‌ها به دیتابیس با استفاده از Flask-SQLAlchemy"""

    # اضافه کردن مسیر backend به sys.path
    sys.path.insert(0, BASE_DIR)

    from app import app
    from models import db, Book

    with app.app_context():
        # جداول را بساز (اگر نیست)
        db.create_all()

        added = 0
        skipped = 0
        errors = []

        for i, item in enumerate(items, 1):
            title = item.get('title', '').strip()
            if not title:
                errors.append(f"آیتم {i}: عنوان خالی است")
                continue

            # بررسی تکراری
            existing = Book.query.filter_by(title=title).first()
            if existing:
                skipped += 1
                print(f"  ⏭️  رد شد (قبلاً موجود): {title}")
                continue

            file_name = item.get('file', '').strip()
            cover_name = item.get('cover', '').strip()
            type_ = item.get('type', 'pdf')
            category = item.get('category', '')

            try:
                # ---- کپی فایل اصلی ----
                if not file_name:
                    errors.append(f"«{title}»: نام فایل خالی است")
                    continue

                src_file = find_asset_file(file_name, type_)
                if not os.path.exists(src_file):
                    errors.append(f"«{title}»: فایل {file_name} یافت نشد")
                    continue

                if type_ == 'pdf':
                    dst_dir = DEST_BOOKS
                    subfolder = 'books'
                elif type_ == 'audio':
                    dst_dir = DEST_AUDIO
                    subfolder = 'audio'
                else:
                    dst_dir = DEST_VIDEO
                    subfolder = 'video'

                saved_path, file_size = safe_copy(src_file, dst_dir)
                saved_filename = os.path.basename(saved_path)
                file_url = f"/api/download/{subfolder}/{saved_filename}"

                # ---- کپی کاور (اختیاری) ----
                cover_url = None
                cover_path = None
                if cover_name:
                    src_cover = find_cover_file(cover_name)
                    if os.path.exists(src_cover):
                        cover_dst, _ = safe_copy(src_cover, DEST_COVERS)
                        cover_filename = os.path.basename(cover_dst)
                        cover_url = f"/api/covers/{cover_filename}"
                        cover_path = cover_dst
                    else:
                        print(f"  ⚠️  کاور یافت نشد: {cover_name}")

                # ---- ذخیره در دیتابیس ----
                book = Book(
                    title=title,
                    author=item.get('author', ''),
                    description=item.get('description', ''),
                    cover_url=cover_url,
                    cover_path=cover_path,
                    file_url=file_url,
                    file_path=saved_path,
                    file_size=file_size,
                    type=type_,
                    category=category,
                )
                db.session.add(book)
                db.session.commit()

                added += 1
                size_mb = file_size / (1024 * 1024)
                print(f"  ✅ ثبت شد: {title} ({size_mb:.2f} MB)")

            except Exception as e:
                db.session.rollback()
                errors.append(f"«{title}»: {str(e)}")
                print(f"  ❌ خطا در {title}: {e}")

        return added, skipped, errors


# ==========================================================
# اجرای اصلی
# ==========================================================

def main():
    print("=" * 60)
    print("  📚 کتابخانه شهید حاج قاسم سلیمانی")
    print("  🚀 اسکریپت وارد کردن گروهی محتوا")
    print("=" * 60)

    # بررسی پوشه assets
    if not os.path.exists(ASSETS_DIR):
        print(f"\n❌ پوشه assets یافت نشد: {ASSETS_DIR}")
        print("لطفاً پوشه assets را با زیرپوشه‌های books, audio, video, covers بسازید.")
        sys.exit(1)

    # بررسی دیتابیس
    if not os.path.exists(DB_PATH):
        print(f"\n⚠️  دیتابیس یافت نشد: {DB_PATH}")
        print("دیتابیس به‌طور خودکار ساخته می‌شود...")

    ensure_folders()

    print(f"\n📂 پوشه assets: {ASSETS_DIR}")
    print(f"📂 پوشه uploads: {UPLOAD_DIR}")
    print(f"💾 دیتابیس: {DB_PATH}")
    print(f"\n📝 تعداد آیتم‌ها برای وارد کردن: {len(MEDIA_LIST)}")
    print("-" * 60)

    added, skipped, errors = import_to_database(MEDIA_LIST)

    print("-" * 60)
    print(f"\n📊 نتیجه نهایی:")
    print(f"   ✅ اضافه شده: {added}")
    print(f"   ⏭️  رد شده (تکراری): {skipped}")
    print(f"   ❌ خطاها: {len(errors)}")

    if errors:
        print("\n🔴 لیست خطاها:")
        for err in errors:
            print(f"   • {err}")

    print("\n" + "=" * 60)
    print("  ✅ عملیات به پایان رسید")
    print("=" * 60)


if __name__ == '__main__':
    main()