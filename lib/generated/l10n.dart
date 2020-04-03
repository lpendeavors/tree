// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

class S {
  S();
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final String name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return S();
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  String get app_title {
    return Intl.message(
      'Tree',
      name: 'app_title',
      desc: '',
      args: [],
    );
  }

  String get getting_started_title {
    return Intl.message(
      'Life is Better Together',
      name: 'getting_started_title',
      desc: '',
      args: [],
    );
  }

  String get getting_started_button {
    return Intl.message(
      'Get Started',
      name: 'getting_started_button',
      desc: '',
      args: [],
    );
  }

  String get already_have_an_account {
    return Intl.message(
      'Already have an account?',
      name: 'already_have_an_account',
      desc: '',
      args: [],
    );
  }

  String get login_here {
    return Intl.message(
      'Login Here',
      name: 'login_here',
      desc: '',
      args: [],
    );
  }

  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  String get exit_login {
    return Intl.message(
      'Cancel?',
      name: 'exit_login',
      desc: '',
      args: [],
    );
  }

  String get exit_login_message {
    return Intl.message(
      'Are you sure you want to exit?',
      name: 'exit_login_message',
      desc: '',
      args: [],
    );
  }

  String get login_success {
    return Intl.message(
      'Login successful!',
      name: 'login_success',
      desc: '',
      args: [],
    );
  }

  String get logout_success {
    return Intl.message(
      'Logout successful!',
      name: 'logout_success',
      desc: '',
      args: [],
    );
  }

  String get logout_error {
    return Intl.message(
      'An error occurred logging out',
      name: 'logout_error',
      desc: '',
      args: [],
    );
  }

  String get network_error {
    return Intl.message(
      'A network error occurred',
      name: 'network_error',
      desc: '',
      args: [],
    );
  }

  String get too_many_requests_error {
    return Intl.message(
      'An error occurred. Too many requests',
      name: 'too_many_requests_error',
      desc: '',
      args: [],
    );
  }

  String get user_not_found_error {
    return Intl.message(
      'User not found',
      name: 'user_not_found_error',
      desc: '',
      args: [],
    );
  }

  String get wrong_password_error {
    return Intl.message(
      'Incorrect password',
      name: 'wrong_password_error',
      desc: '',
      args: [],
    );
  }

  String get invalid_email_error {
    return Intl.message(
      'Invalid email address',
      name: 'invalid_email_error',
      desc: '',
      args: [],
    );
  }

  String get weak_password_error {
    return Intl.message(
      'Password is too weak',
      name: 'weak_password_error',
      desc: '',
      args: [],
    );
  }

  String get error_occurred {
    return Intl.message(
      'An unknown error has occurred',
      name: 'error_occurred',
      desc: '',
      args: [],
    );
  }

  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  String get exit {
    return Intl.message(
      'Exit',
      name: 'exit',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (Locale supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}