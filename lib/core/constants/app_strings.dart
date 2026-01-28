/// ==========================================================================
/// app_strings.dart
/// ==========================================================================
/// Ilovadagi barcha matnlar uchun konstantalar.
/// Lokalizatsiya qilish uchun qulay struktura.
/// ==========================================================================

/// Ilova uchun barcha matnli konstantalar
class AppStrings {
  AppStrings._();

  // ==================== Ilova nomi ====================
  static const String appName = 'LoyaltyCard';
  static const String appTagline = 'Barcha bonuslaringiz bir joyda';

  // ==================== Navigation ====================
  static const String home = 'Bosh sahifa';
  static const String wallet = 'QR Hamyon';
  static const String scanner = 'Skaner';
  static const String rewards = 'Sovg\'alar';
  static const String analytics = 'Statistika';

  // ==================== Dashboard ====================
  static const String totalPoints = 'Jami ballar';
  static const String activeCards = 'Faol kartalar';
  static const String recentTransactions = 'Oxirgi tranzaksiyalar';
  static const String viewAll = 'Hammasini ko\'rish';
  static const String noCards = 'Hozircha kartalar yo\'q';
  static const String addFirstCard = 'Birinchi kartangizni qo\'shing!';

  // ==================== QR Wallet ====================
  static const String yourQrCode = 'Sizning QR kodingiz';
  static const String showToScanner = 'Kassirga skanerlash uchun ko\'rsating';
  static const String userId = 'Foydalanuvchi ID';
  static const String refreshCode = 'Yangilash';

  // ==================== Scanner ====================
  static const String scanQrCode = 'QR kodni skanerlang';
  static const String pointCamera = 'Kamerani QR kodga qarating';
  static const String addNewCard = 'Yangi karta qo\'shish';
  static const String scanSuccessful = 'Skanerlash muvaffaqiyatli!';
  static const String scanFailed = 'Skanerlash muvaffaqiyatsiz';

  // ==================== Rewards ====================
  static const String availableRewards = 'Mavjud sovg\'alar';
  static const String redeemPoints = 'Ballarni sarflash';
  static const String pointsRequired = 'Kerakli ball';
  static const String redeem = 'Olish';
  static const String notEnoughPoints = 'Yetarli ball yo\'q';

  // ==================== Analytics ====================
  static const String pointsEarned = 'Yig\'ilgan ballar';
  static const String pointsSpent = 'Sarflangan ballar';
  static const String monthlyStats = 'Oylik statistika';
  static const String topStores = 'Eng ko\'p bonus yig\'ilgan do\'konlar';

  // ==================== Actions ====================
  static const String add = 'Qo\'shish';
  static const String cancel = 'Bekor qilish';
  static const String confirm = 'Tasdiqlash';
  static const String delete = 'O\'chirish';
  static const String edit = 'Tahrirlash';
  static const String save = 'Saqlash';
  static const String search = 'Qidirish';
  static const String retry = 'Qayta urinish';

  // ==================== Errors ====================
  static const String errorGeneral = 'Xatolik yuz berdi';
  static const String errorNetwork = 'Internet aloqasi yo\'q';
  static const String errorCamera = 'Kameraga ruxsat berilmagan';
  static const String errorInvalidQr = 'Noto\'g\'ri QR kod';

  // ==================== Theme ====================
  static const String darkMode = 'Tungi rejim';
  static const String lightMode = 'Kunduzgi rejim';
  static const String systemMode = 'Tizim rejimi';
}
