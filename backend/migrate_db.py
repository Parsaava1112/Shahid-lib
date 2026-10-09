# -*- coding: utf-8 -*-
"""
اسکریپت Migration دیتابیس
اضافه کردن ستون‌های جدید بدون از دست دادن داده‌های قبلی
"""

import os
import sqlite3
import sys
import shutil

BASE_DIR = os.path.abspath(os.path.dirname(__file__))
DB_PATH = os.path.join(BASE_DIR, 'db', 'library.db')

# ستون‌هایی که باید به جدول books اضافه شوند
BOOKS_NEW_COLUMNS = [
    ('cover_path', 'TEXT'),
    ('file_size', 'INTEGER DEFAULT 0'),
    ('language', "TEXT DEFAULT 'fa'"),
    ('level', 'TEXT'),
]


def column_exists(cursor, table, column):
    """بررسی وجود یک ستون در جدول"""
    cursor.execute(f"PRAGMA table_info({table})")
    columns = [row[1] for row in cursor.fetchall()]
    return column in columns


def table_exists(cursor, table):
    """بررسی وجود جدول"""
    cursor.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        (table,)
    )
    return cursor.fetchone() is not None


def migrate():
    print("=" * 60)
    print("  🔧 Migration دیتابیس کتابخانه شهید بهشتی")
    print("  🏫 مدرسه استعداد های درخشان شهید بهشتی")
    print("=" * 60)

    if not os.path.exists(DB_PATH):
        print(f"\n❌ دیتابیس یافت نشد: {DB_PATH}")
        print("دیتابیس به‌طور خودکار در اولین اجرای اپ ساخته می‌شود.")
        return

    print(f"\n💾 دیتابیس: {DB_PATH}")

    # بکاپ گرفتن قبل از تغییر
    backup_path = DB_PATH + '.backup'
    if not os.path.exists(backup_path):
        shutil.copy2(DB_PATH, backup_path)
        print(f"📦 بکاپ ساخته شد: {backup_path}")
    else:
        print(f"📦 بکاپ موجود: {backup_path}")

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    changes = 0

    # ============ جدول books ============
    if table_exists(cursor, 'books'):
        print("\n📚 بررسی جدول books:")
        for col_name, col_type in BOOKS_NEW_COLUMNS:
            if not column_exists(cursor, 'books', col_name):
                try:
                    sql = f"ALTER TABLE books ADD COLUMN {col_name} {col_type}"
                    cursor.execute(sql)
                    print(f"   ✅ ستون {col_name} اضافه شد")
                    changes += 1
                except sqlite3.OperationalError as e:
                    print(f"   ❌ خطا در افزودن {col_name}: {e}")
            else:
                print(f"   ⏭️  ستون {col_name} از قبل وجود دارد")
    else:
        print("\n⚠️  جدول books وجود ندارد (بعداً ساخته می‌شود)")

    # ============ جداول دیگر ============
    other_tables = {
        'reading_progress': '''
            CREATE TABLE IF NOT EXISTS reading_progress (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                book_id INTEGER NOT NULL,
                current_page INTEGER DEFAULT 1,
                total_pages INTEGER DEFAULT 0,
                is_completed INTEGER DEFAULT 0,
                updated_at TEXT NOT NULL,
                UNIQUE(user_id, book_id)
            )
        ''',
        'bookmarks': '''
            CREATE TABLE IF NOT EXISTS bookmarks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                book_id INTEGER NOT NULL,
                page INTEGER NOT NULL,
                note TEXT,
                created_at TEXT NOT NULL
            )
        ''',
        'achievements': '''
            CREATE TABLE IF NOT EXISTS achievements (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                achievement_id TEXT NOT NULL,
                unlocked_at TEXT NOT NULL,
                UNIQUE(user_id, achievement_id)
            )
        ''',
        'sync_queue': '''
            CREATE TABLE IF NOT EXISTS sync_queue (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                operation TEXT NOT NULL,
                payload TEXT NOT NULL,
                created_at TEXT NOT NULL,
                retry_count INTEGER DEFAULT 0
            )
        ''',
    }

    print("\n🔍 بررسی جداول دیگر:")
    for table, create_sql in other_tables.items():
        if not table_exists(cursor, table):
            cursor.execute(create_sql)
            print(f"   ✅ جدول {table} ساخته شد")
            changes += 1
        else:
            print(f"   ⏭️  جدول {table} از قبل وجود دارد")

    conn.commit()
    conn.close()

    print("\n" + "=" * 60)
    if changes > 0:
        print(f"  ✅ Migration کامل شد ({changes} تغییر)")
    else:
        print("  ✅ دیتابیس از قبل به‌روز بود")
    print("=" * 60)


if __name__ == '__main__':
    migrate()