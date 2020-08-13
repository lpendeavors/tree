// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `TREE`
  String get app_title {
    return Intl.message(
      'TREE',
      name: 'app_title',
      desc: '',
      args: [],
    );
  }

  /// `Life is Better Together`
  String get getting_started_title {
    return Intl.message(
      'Life is Better Together',
      name: 'getting_started_title',
      desc: '',
      args: [],
    );
  }

  /// `Get Started`
  String get getting_started_button {
    return Intl.message(
      'Get Started',
      name: 'getting_started_button',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account?`
  String get already_have_an_account {
    return Intl.message(
      'Already have an account?',
      name: 'already_have_an_account',
      desc: '',
      args: [],
    );
  }

  /// `Login Here`
  String get login_here {
    return Intl.message(
      'Login Here',
      name: 'login_here',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get login {
    return Intl.message(
      'Sign In',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Cancel?`
  String get exit_login {
    return Intl.message(
      'Cancel?',
      name: 'exit_login',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to exit?`
  String get exit_login_message {
    return Intl.message(
      'Are you sure you want to exit?',
      name: 'exit_login_message',
      desc: '',
      args: [],
    );
  }

  /// `Login successful!`
  String get login_success {
    return Intl.message(
      'Login successful!',
      name: 'login_success',
      desc: '',
      args: [],
    );
  }

  /// `Logout successful!`
  String get logout_success {
    return Intl.message(
      'Logout successful!',
      name: 'logout_success',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred logging out`
  String get logout_error {
    return Intl.message(
      'An error occurred logging out',
      name: 'logout_error',
      desc: '',
      args: [],
    );
  }

  /// `Use your {method} to login`
  String login_method(Object method) {
    return Intl.message(
      'Use your $method to login',
      name: 'login_method',
      desc: '',
      args: [method],
    );
  }

  /// `EMAIL ADDRESS`
  String get email_address {
    return Intl.message(
      'EMAIL ADDRESS',
      name: 'email_address',
      desc: '',
      args: [],
    );
  }

  /// `Enter Email Address`
  String get email_hint {
    return Intl.message(
      'Enter Email Address',
      name: 'email_hint',
      desc: '',
      args: [],
    );
  }

  /// `PASSWORD`
  String get password {
    return Intl.message(
      'PASSWORD',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Enter Password`
  String get password_hint {
    return Intl.message(
      'Enter Password',
      name: 'password_hint',
      desc: '',
      args: [],
    );
  }

  /// `Verification sent`
  String get phone_login_success {
    return Intl.message(
      'Verification sent',
      name: 'phone_login_success',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get sign_up {
    return Intl.message(
      'Sign Up',
      name: 'sign_up',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get sign_up_continue {
    return Intl.message(
      'Continue',
      name: 'sign_up_continue',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up as a {entity}?`
  String sign_up_as(Object entity) {
    return Intl.message(
      'Sign Up as a $entity?',
      name: 'sign_up_as',
      desc: '',
      args: [entity],
    );
  }

  /// `Enter your mobile number`
  String get enter_phone_number {
    return Intl.message(
      'Enter your mobile number',
      name: 'enter_phone_number',
      desc: '',
      args: [],
    );
  }

  /// `(678) 324-4041`
  String get phone_number_hint {
    return Intl.message(
      '(678) 324-4041',
      name: 'phone_number_hint',
      desc: '',
      args: [],
    );
  }

  /// `(000) 000-0000`
  String get phone_number_mask {
    return Intl.message(
      '(000) 000-0000',
      name: 'phone_number_mask',
      desc: '',
      args: [],
    );
  }

  /// `Verification sent`
  String get phone_register_success {
    return Intl.message(
      'Verification sent',
      name: 'phone_register_success',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up Completed`
  String get register_success {
    return Intl.message(
      'Sign Up Completed',
      name: 'register_success',
      desc: '',
      args: [],
    );
  }

  /// `Enter Church Name`
  String get church_name_hint {
    return Intl.message(
      'Enter Church Name',
      name: 'church_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Enter First Name`
  String get f_name_hint {
    return Intl.message(
      'Enter First Name',
      name: 'f_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Enter Last Name`
  String get l_name_hint {
    return Intl.message(
      'Enter Last Name',
      name: 'l_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Retype Password`
  String get retype_hint {
    return Intl.message(
      'Retype Password',
      name: 'retype_hint',
      desc: '',
      args: [],
    );
  }

  /// `Verification`
  String get verification {
    return Intl.message(
      'Verification',
      name: 'verification',
      desc: '',
      args: [],
    );
  }

  /// `Phone Verification`
  String get verification_title {
    return Intl.message(
      'Phone Verification',
      name: 'verification_title',
      desc: '',
      args: [],
    );
  }

  /// `Enter the 6 digit number sent to you`
  String get verification_message {
    return Intl.message(
      'Enter the 6 digit number sent to you',
      name: 'verification_message',
      desc: '',
      args: [],
    );
  }

  /// `Resend code`
  String get verification_resend {
    return Intl.message(
      'Resend code',
      name: 'verification_resend',
      desc: '',
      args: [],
    );
  }

  /// `We'll send you a text verification code`
  String get verification_hint {
    return Intl.message(
      'We\'ll send you a text verification code',
      name: 'verification_hint',
      desc: '',
      args: [],
    );
  }

  /// `Forgot your password?`
  String get forgot_password {
    return Intl.message(
      'Forgot your password?',
      name: 'forgot_password',
      desc: '',
      args: [],
    );
  }

  /// `We'll email you instructions to reset your password`
  String get password_reset_tip {
    return Intl.message(
      'We\'ll email you instructions to reset your password',
      name: 'password_reset_tip',
      desc: '',
      args: [],
    );
  }

  /// `Password reset email sent!`
  String get password_reset_success {
    return Intl.message(
      'Password reset email sent!',
      name: 'password_reset_success',
      desc: '',
      args: [],
    );
  }

  /// `Send Email`
  String get password_reset_confirm {
    return Intl.message(
      'Send Email',
      name: 'password_reset_confirm',
      desc: '',
      args: [],
    );
  }

  /// `A network error occurred`
  String get network_error {
    return Intl.message(
      'A network error occurred',
      name: 'network_error',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred. Too many requests`
  String get too_many_requests_error {
    return Intl.message(
      'An error occurred. Too many requests',
      name: 'too_many_requests_error',
      desc: '',
      args: [],
    );
  }

  /// `User not found`
  String get user_not_found_error {
    return Intl.message(
      'User not found',
      name: 'user_not_found_error',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect password`
  String get wrong_password_error {
    return Intl.message(
      'Incorrect password',
      name: 'wrong_password_error',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email address`
  String get invalid_email_error {
    return Intl.message(
      'Invalid email address',
      name: 'invalid_email_error',
      desc: '',
      args: [],
    );
  }

  /// `Password is too weak`
  String get weak_password_error {
    return Intl.message(
      'Password is too weak',
      name: 'weak_password_error',
      desc: '',
      args: [],
    );
  }

  /// `An unknown error has occurred`
  String get error_occurred {
    return Intl.message(
      'An unknown error has occurred',
      name: 'error_occurred',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications_title {
    return Intl.message(
      'Notifications',
      name: 'notifications_title',
      desc: '',
      args: [],
    );
  }

  /// `No Notifications`
  String get notifications_empty_title {
    return Intl.message(
      'No Notifications',
      name: 'notifications_empty_title',
      desc: '',
      args: [],
    );
  }

  /// `~You have no notifications yet~`
  String get notifications_empty_desc {
    return Intl.message(
      '~You have no notifications yet~',
      name: 'notifications_empty_desc',
      desc: '',
      args: [],
    );
  }

  /// `Search Events`
  String get events_search_hint {
    return Intl.message(
      'Search Events',
      name: 'events_search_hint',
      desc: '',
      args: [],
    );
  }

  /// `EXPLORE`
  String get events_tab_explore {
    return Intl.message(
      'EXPLORE',
      name: 'events_tab_explore',
      desc: '',
      args: [],
    );
  }

  /// `MAP`
  String get events_tab_map {
    return Intl.message(
      'MAP',
      name: 'events_tab_map',
      desc: '',
      args: [],
    );
  }

  /// `MY EVENTS`
  String get events_tab_mine {
    return Intl.message(
      'MY EVENTS',
      name: 'events_tab_mine',
      desc: '',
      args: [],
    );
  }

  /// `No Events`
  String get events_empty_title {
    return Intl.message(
      'No Events',
      name: 'events_empty_title',
      desc: '',
      args: [],
    );
  }

  /// `~You have no events yet~`
  String get events_empty_desc {
    return Intl.message(
      '~You have no events yet~',
      name: 'events_empty_desc',
      desc: '',
      args: [],
    );
  }

  /// `🔥 Sponsored Event`
  String get event_sponsored_title {
    return Intl.message(
      '🔥 Sponsored Event',
      name: 'event_sponsored_title',
      desc: '',
      args: [],
    );
  }

  /// `Create Event`
  String get create_event_title {
    return Intl.message(
      'Create Event',
      name: 'create_event_title',
      desc: '',
      args: [],
    );
  }

  /// `Choose your objective`
  String get event_objective_title {
    return Intl.message(
      'Choose your objective',
      name: 'event_objective_title',
      desc: '',
      args: [],
    );
  }

  /// `Event Details`
  String get event_details_title {
    return Intl.message(
      'Event Details',
      name: 'event_details_title',
      desc: '',
      args: [],
    );
  }

  /// `ATTENDEES`
  String get event_attendees_title {
    return Intl.message(
      'ATTENDEES',
      name: 'event_attendees_title',
      desc: '',
      args: [],
    );
  }

  /// `Declined Reason`
  String get event_rejected_reason_title {
    return Intl.message(
      'Declined Reason',
      name: 'event_rejected_reason_title',
      desc: '',
      args: [],
    );
  }

  /// `DESCRIPTION`
  String get event_description_title {
    return Intl.message(
      'DESCRIPTION',
      name: 'event_description_title',
      desc: '',
      args: [],
    );
  }

  /// `ATTEND`
  String get event_attend_title {
    return Intl.message(
      'ATTEND',
      name: 'event_attend_title',
      desc: '',
      args: [],
    );
  }

  /// `CREATE`
  String get event_create_title {
    return Intl.message(
      'CREATE',
      name: 'event_create_title',
      desc: '',
      args: [],
    );
  }

  /// `Add photos`
  String get event_add_photos {
    return Intl.message(
      'Add photos',
      name: 'event_add_photos',
      desc: '',
      args: [],
    );
  }

  /// `SAVE`
  String get event_save_title {
    return Intl.message(
      'SAVE',
      name: 'event_save_title',
      desc: '',
      args: [],
    );
  }

  /// `Event title`
  String get event_title {
    return Intl.message(
      'Event title',
      name: 'event_title',
      desc: '',
      args: [],
    );
  }

  /// `Select event start and end date`
  String get event_start_end_date {
    return Intl.message(
      'Select event start and end date',
      name: 'event_start_end_date',
      desc: '',
      args: [],
    );
  }

  /// `Briefly describe this event`
  String get describe_event {
    return Intl.message(
      'Briefly describe this event',
      name: 'describe_event',
      desc: '',
      args: [],
    );
  }

  /// `Please include all necessary information`
  String get event_details_hint {
    return Intl.message(
      'Please include all necessary information',
      name: 'event_details_hint',
      desc: '',
      args: [],
    );
  }

  /// `Destination Link (If Any)`
  String get event_destination_link {
    return Intl.message(
      'Destination Link (If Any)',
      name: 'event_destination_link',
      desc: '',
      args: [],
    );
  }

  /// `Web address`
  String get event_web_address {
    return Intl.message(
      'Web address',
      name: 'event_web_address',
      desc: '',
      args: [],
    );
  }

  /// `Cost of the event (Optional)`
  String get event_cost_label {
    return Intl.message(
      'Cost of the event (Optional)',
      name: 'event_cost_label',
      desc: '',
      args: [],
    );
  }

  /// `Venue of event`
  String get event_venue_label {
    return Intl.message(
      'Venue of event',
      name: 'event_venue_label',
      desc: '',
      args: [],
    );
  }

  /// `Where will this event be held?`
  String get event_venue_hint {
    return Intl.message(
      'Where will this event be held?',
      name: 'event_venue_hint',
      desc: '',
      args: [],
    );
  }

  /// `Request for this event to be a Sponsored Event(Special advertising benefits included)`
  String get event_sponsored_hint {
    return Intl.message(
      'Request for this event to be a Sponsored Event(Special advertising benefits included)',
      name: 'event_sponsored_hint',
      desc: '',
      args: [],
    );
  }

  /// `What is your budget?`
  String get event_budget_label {
    return Intl.message(
      'What is your budget?',
      name: 'event_budget_label',
      desc: '',
      args: [],
    );
  }

  /// `Estimated number of people that will see your event`
  String get event_estimate_label {
    return Intl.message(
      'Estimated number of people that will see your event',
      name: 'event_estimate_label',
      desc: '',
      args: [],
    );
  }

  /// `Search and discover`
  String get explore_search_hint {
    return Intl.message(
      'Search and discover',
      name: 'explore_search_hint',
      desc: '',
      args: [],
    );
  }

  /// `FIND CONNECTIONS`
  String get explore_find_connections {
    return Intl.message(
      'FIND CONNECTIONS',
      name: 'explore_find_connections',
      desc: '',
      args: [],
    );
  }

  /// `EXPLORE`
  String get explore_posts {
    return Intl.message(
      'EXPLORE',
      name: 'explore_posts',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get explore_posts_empty {
    return Intl.message(
      '',
      name: 'explore_posts_empty',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get explore_post_empty_desc {
    return Intl.message(
      '',
      name: 'explore_post_empty_desc',
      desc: '',
      args: [],
    );
  }

  /// `No Request Found`
  String get connections_empty_title {
    return Intl.message(
      'No Request Found',
      name: 'connections_empty_title',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get connections_empty_desc {
    return Intl.message(
      '',
      name: 'connections_empty_desc',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get exit {
    return Intl.message(
      'Exit',
      name: 'exit',
      desc: '',
      args: [],
    );
  }

  /// `email`
  String get email {
    return Intl.message(
      'email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `phone number`
  String get phone {
    return Intl.message(
      'phone number',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get verify {
    return Intl.message(
      'Verify',
      name: 'verify',
      desc: '',
      args: [],
    );
  }

  /// `OR`
  String get or {
    return Intl.message(
      'OR',
      name: 'or',
      desc: '',
      args: [],
    );
  }

  /// `Church`
  String get church {
    return Intl.message(
      'Church',
      name: 'church',
      desc: '',
      args: [],
    );
  }

  /// `Person`
  String get person {
    return Intl.message(
      'Person',
      name: 'person',
      desc: '',
      args: [],
    );
  }

  /// `Events`
  String get events {
    return Intl.message(
      'Events',
      name: 'events',
      desc: '',
      args: [],
    );
  }

  /// `View on map`
  String get view_map {
    return Intl.message(
      'View on map',
      name: 'view_map',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home_tab_title {
    return Intl.message(
      'Home',
      name: 'home_tab_title',
      desc: '',
      args: [],
    );
  }

  /// `Explore`
  String get explore_tab_title {
    return Intl.message(
      'Explore',
      name: 'explore_tab_title',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chat_tab_title {
    return Intl.message(
      'Chat',
      name: 'chat_tab_title',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile_tab_title {
    return Intl.message(
      'Profile',
      name: 'profile_tab_title',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get create_account {
    return Intl.message(
      'Create Account',
      name: 'create_account',
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
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}