import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// Message
///
abstract class AdminMessage {
  const AdminMessage();
}

///
/// Error
///
class NotLoggedInError {
  const NotLoggedInError();
}

///
/// State
///
// @immutable
// class AdminState  extends Equatable {

// }
