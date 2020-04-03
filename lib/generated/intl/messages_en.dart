// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "already_have_an_account" : MessageLookupByLibrary.simpleMessage("Already have an account?"),
    "app_title" : MessageLookupByLibrary.simpleMessage("Tree"),
    "error_occurred" : MessageLookupByLibrary.simpleMessage("An unknown error has occurred"),
    "exit" : MessageLookupByLibrary.simpleMessage("Exit"),
    "exit_login" : MessageLookupByLibrary.simpleMessage("Cancel?"),
    "exit_login_message" : MessageLookupByLibrary.simpleMessage("Are you sure you want to exit?"),
    "getting_started_button" : MessageLookupByLibrary.simpleMessage("Get Started"),
    "getting_started_title" : MessageLookupByLibrary.simpleMessage("Life is Better Together"),
    "invalid_email_error" : MessageLookupByLibrary.simpleMessage("Invalid email address"),
    "login" : MessageLookupByLibrary.simpleMessage("Login"),
    "login_here" : MessageLookupByLibrary.simpleMessage("Login Here"),
    "login_success" : MessageLookupByLibrary.simpleMessage("Login successful!"),
    "logout_error" : MessageLookupByLibrary.simpleMessage("An error occurred logging out"),
    "logout_success" : MessageLookupByLibrary.simpleMessage("Logout successful!"),
    "network_error" : MessageLookupByLibrary.simpleMessage("A network error occurred"),
    "no" : MessageLookupByLibrary.simpleMessage("No"),
    "too_many_requests_error" : MessageLookupByLibrary.simpleMessage("An error occurred. Too many requests"),
    "user_not_found_error" : MessageLookupByLibrary.simpleMessage("User not found"),
    "weak_password_error" : MessageLookupByLibrary.simpleMessage("Password is too weak"),
    "wrong_password_error" : MessageLookupByLibrary.simpleMessage("Incorrect password")
  };
}
