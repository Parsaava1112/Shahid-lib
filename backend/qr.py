import os
import qrcode
from PIL import Image, ImageDraw, ImageFont


# ====== تنظیمات ======
# ساخت لیست از BOOK-1 تا BOOK-250
IDS = [f"BOOK-{i}" for i in range(1, 251)]

OUTPUT_DIR = "qr_output"      # پوشه خروجی
QR_SIZE = 400                 # اندازه QR Code به پیکسل
PADDING = 40                  # فاصله اطراف
TEXT_AREA_HEIGHT = 90         # ارتفاع ناحیه متن
FONT_PATH = None              # مسیر فونت (None = فونت پیش‌فرض)
FONT_SIZE = 40                # اندازه فونت
BG_COLOR = "white"            # رنگ پس‌زمینه
TEXT_COLOR = "black"          # رنگ متن
# ======================


def get_font(size):
    """تلاش برای بارگذاری فونت مناسب"""
    candidates = [
        FONT_PATH,
        "arial.ttf",
        "DejaVuSans-Bold.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "C:/Windows/Fonts/arialbd.ttf",
    ]
    for path in candidates:
        if path:
            try:
                return ImageFont.truetype(path, size)
            except (OSError, IOError):
                continue
    return ImageFont.load_default()


def create_qr_image(identifier, output_dir):
    # 1) ساخت QR Code
    qr = qrcode.QRCode(
        version=None,
        error_correction=qrcode.constants.ERROR_CORRECT_H,
        box_size=10,
        border=2,
    )
    qr.add_data(identifier)
    qr.make(fit=True)
    qr_img = qr.make_image(fill_color="black", back_color="white").convert("RGB")

    # 2) تغییر اندازه QR
    qr_img = qr_img.resize((QR_SIZE, QR_SIZE), Image.LANCZOS)

    # 3) ساخت بوم نهایی
    canvas_w = QR_SIZE + PADDING * 2
    canvas_h = QR_SIZE + PADDING * 2 + TEXT_AREA_HEIGHT
    canvas = Image.new("RGB", (canvas_w, canvas_h), BG_COLOR)

    # 4) جای‌گذاری QR در مرکز افقی
    qr_x = (canvas_w - QR_SIZE) // 2
    qr_y = PADDING
    canvas.paste(qr_img, (qr_x, qr_y))

    # 5) نوشتن متن زیر QR
    draw = ImageDraw.Draw(canvas)
    font = get_font(FONT_SIZE)

    bbox = draw.textbbox((0, 0), identifier, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]

    text_x = (canvas_w - text_w) // 2 - bbox[0]
    text_y = qr_y + QR_SIZE + (TEXT_AREA_HEIGHT - text_h) // 2 - bbox[1]

    draw.text((text_x, text_y), identifier, fill=TEXT_COLOR, font=font)

    # 6) ذخیره فایل
    safe_name = identifier.replace("/", "_").replace("\\", "_")
    out_path = os.path.join(output_dir, f"{safe_name}.png")
    canvas.save(out_path)
    return out_path


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    total = len(IDS)
    print(f"در حال ساخت {total} تصویر...\n")

    for i, identifier in enumerate(IDS, 1):
        try:
            path = create_qr_image(identifier, OUTPUT_DIR)
            print(f"[{i:>3}/{total}] ✅ {path}")
        except Exception as e:
            print(f"[{i:>3}/{total}] ❌ خطا در {identifier}: {e}")

    print(f"\n🎉 تمام شد! {total} تصویر در پوشه «{OUTPUT_DIR}» ذخیره شدند.")


if __name__ == "__main__":
    main()