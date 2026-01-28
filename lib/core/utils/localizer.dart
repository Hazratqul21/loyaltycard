import 'package:flutter/material.dart';

class Localizer {
  final Locale locale;

  Localizer(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'welcome': 'Welcome!',
      'app_desc': 'All your cards in one place with LoyaltyCard',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'or': 'Or',
      'google_login': 'Sign in with Google',
      'no_account': 'Don\'t have an account?',
      'have_account': 'Already have an account? Login',
      'full_name': 'Full Name',
      'send': 'Send',
      'reset_desc': 'Enter your email and we will send you a reset link',
      'reset_success': 'Reset link sent to your email',
      'error_invalid_email': 'Invalid email',
      'error_weak_pass': 'At least 6 characters',
      'error_required': 'This field is required',
    },
    'uz': {
      'welcome': 'Xush kelibsiz!',
      'app_desc': 'LoyaltyCard bilan barcha kartalaringiz bir joyda',
      'login': 'Kirish',
      'register': 'Ro\'yxatdan o\'tish',
      'email': 'Email',
      'password': 'Parol',
      'forgot_password': 'Unutdingizmi?',
      'or': 'Yoki',
      'google_login': 'Google bilan kirish',
      'no_account': 'Hali ro\'yxatdan o\'tmaganmisiz?',
      'have_account': 'Akkauntingiz bormi? Kirish',
      'full_name': 'Ism va Familiya',
      'send': 'Yuborish',
      'reset_desc': 'Emailingizni kiriting va biz sizga parolni tiklash havolasini yuboramiz',
      'reset_success': 'Parolni tiklash havolasi emailingizga yuborildi',
      'error_invalid_email': 'Noto\'g\'ri email',
      'error_weak_pass': 'Kamida 6 ta belgi',
      'error_required': 'Maydonni to\'ldiring',
    },
    'ru': {
      'welcome': 'Добро пожаловать!',
      'app_desc': 'Все ваши карты в одном месте с LoyaltyCard',
      'login': 'Войти',
      'register': 'Регистрация',
      'email': 'Email',
      'password': 'Пароль',
      'forgot_password': 'Забыли пароль?',
      'or': 'Или',
      'google_login': 'Войти через Google',
      'no_account': 'Еще не зарегистрированы?',
      'have_account': 'Уже есть аккаунт? Войти',
      'full_name': 'Имя и Фамилия',
      'send': 'Отправить',
      'reset_desc': 'Введите ваш email и мы отправим вам ссылку для сброса пароля',
      'reset_success': 'Ссылка для сброса пароля отправлена на ваш email',
      'error_invalid_email': 'Неверный email',
      'error_weak_pass': 'Минимум 6 символов',
      'error_required': 'Это поле обязательно',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  static Localizer of(BuildContext context) {
    // This is a simplified helper, ideally used with a provider
    return Localizer(Localizations.localeOf(context));
  }
}

extension LocalizerExtension on BuildContext {
  Localizer get l10n => Localizer.of(this);
}
