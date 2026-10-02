import os

BASE_DIR = os.path.abspath(os.path.dirname(__file__))
UPLOAD_FOLDER = os.path.join(BASE_DIR, 'uploads')
DB_FOLDER = os.path.join(BASE_DIR, 'db')

os.makedirs(DB_FOLDER, exist_ok=True)

DATABASE_URI = f'sqlite:///{os.path.join(DB_FOLDER, "library.db")}'
ALLOWED_EXTENSIONS = {'pdf', 'mp3', 'mp4', 'wav', 'ogg'}
MAX_CONTENT_LENGTH = 500 * 1024 * 1024  # 500 MB