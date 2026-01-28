// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'LoyaltyCard';

  @override
  String get home => 'Главная';

  @override
  String get wallet => 'Кошелек';

  @override
  String get scanner => 'Сканер';

  @override
  String get rewards => 'Награды';

  @override
  String get analytics => 'Статистика';

  @override
  String get settings => 'Настройки';

  @override
  String get totalPoints => 'Всего баллов';

  @override
  String get activeCards => 'Активные карты';

  @override
  String get recentTransactions => 'Последние транзакции';

  @override
  String get viewAll => 'Посмотреть все';

  @override
  String get merchantMode => 'Режим продавца';
}
