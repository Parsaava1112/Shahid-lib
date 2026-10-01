class NationalCodeValidator {
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'کد ملی را وارد کنید';
    }
    final code = value.trim();
    if (code.length != 10) {
      return 'کد ملی باید ۱۰ رقم باشد';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(code)) {
      return 'کد ملی باید فقط شامل اعداد باشد';
    }
    // بررسی تکراری نبودن همه اعداد
    bool allSame = true;
    for (int i = 1; i < 10; i++) {
      if (code[0] != code[i]) {
        allSame = false;
        break;
      }
    }
    if (allSame) return 'کد ملی معتبر نیست';

    // الگوریتم اعتبارسنجی کد ملی ایران
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(code[i]) * (10 - i);
    }
    final remaining = sum % 11;
    int lastDigit;
    if (remaining < 2) {
      lastDigit = remaining;
    } else {
      lastDigit = 11 - remaining;
    }
    if (int.parse(code[9]) != lastDigit) {
      return 'کد ملی صحیح نیست';
    }
    return null;
  }
}