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
      'Sign In',
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

  String login_method(Object method) {
    return Intl.message(
      'Use your $method to login',
      name: 'login_method',
      desc: '',
      args: [method],
    );
  }

  String get email_address {
    return Intl.message(
      'EMAIL ADDRESS',
      name: 'email_address',
      desc: '',
      args: [],
    );
  }

  String get email_hint {
    return Intl.message(
      'Enter Email Address',
      name: 'email_hint',
      desc: '',
      args: [],
    );
  }

  String get password {
    return Intl.message(
      'PASSWORD',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  String get password_hint {
    return Intl.message(
      'Enter Password',
      name: 'password_hint',
      desc: '',
      args: [],
    );
  }

  String get phone_login_success {
    return Intl.message(
      'Verification sent',
      name: 'phone_login_success',
      desc: '',
      args: [],
    );
  }

  String get sign_up {
    return Intl.message(
      'Sign Up',
      name: 'sign_up',
      desc: '',
      args: [],
    );
  }

  String get sign_up_continue {
    return Intl.message(
      'Continue',
      name: 'sign_up_continue',
      desc: '',
      args: [],
    );
  }

  String sign_up_as(Object entity) {
    return Intl.message(
      'Sign Up as a $entity',
      name: 'sign_up_as',
      desc: '',
      args: [entity],
    );
  }

  String get enter_phone_number {
    return Intl.message(
      'Enter your mobile number',
      name: 'enter_phone_number',
      desc: '',
      args: [],
    );
  }

  String get phone_number_hint {
    return Intl.message(
      '(678) 324-4041',
      name: 'phone_number_hint',
      desc: '',
      args: [],
    );
  }

  String get phone_number_mask {
    return Intl.message(
      '(000) 000-0000',
      name: 'phone_number_mask',
      desc: '',
      args: [],
    );
  }

  String get verification {
    return Intl.message(
      'Verification',
      name: 'verification',
      desc: '',
      args: [],
    );
  }

  String get verification_message {
    return Intl.message(
      'Enter the 6 digit number sent to you',
      name: 'verification_message',
      desc: '',
      args: [],
    );
  }

  String get verification_resend {
    return Intl.message(
      'Resend code',
      name: 'verification_resend',
      desc: '',
      args: [],
    );
  }

  String get verification_hint {
    return Intl.message(
      'We\'ll send you a text verification code',
      name: 'verification_hint',
      desc: '',
      args: [],
    );
  }

  String get forgot_password {
    return Intl.message(
      'Forget your password?',
      name: 'forgot_password',
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

  String get email {
    return Intl.message(
      'email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  String get phone {
    return Intl.message(
      'phone number',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  String get verify {
    return Intl.message(
      'Verify',
      name: 'verify',
      desc: '',
      args: [],
    );
  }

  String get or {
    return Intl.message(
      'OR',
      name: 'or',
      desc: '',
      args: [],
    );
  }

  String get church {
    return Intl.message(
      'church',
      name: 'church',
      desc: '',
      args: [],
    );
  }

  String get person {
    return Intl.message(
      'person',
      name: 'person',
      desc: '',
      args: [],
    );
  }

  String get events {
    return Intl.message(
      'Events',
      name: 'events',
      desc: '',
      args: [],
    );
  }

  String get home_tab_title {
    return Intl.message(
      'Home',
      name: 'home_tab_title',
      desc: '',
      args: [],
    );
  }

  String get explore_tab_title {
    return Intl.message(
      'Explore',
      name: 'explore_tab_title',
      desc: '',
      args: [],
    );
  }

  String get chat_tab_title {
    return Intl.message(
      'Chat',
      name: 'chat_tab_title',
      desc: '',
      args: [],
    );
  }

  String get profile_tab_title {
    return Intl.message(
      'Profile',
      name: 'profile_tab_title',
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