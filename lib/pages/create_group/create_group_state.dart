import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

/// 
/// Enums
/// 

/// 
/// GroupCreateMessage
/// 
@immutable
abstract class GroupCreateMessage {}

class GroupCreateSuccess implements GroupCreateMessage {
  const GroupCreateSuccess();
}

class GroupCreateError implements GroupCreateMessage {
  final Object error;
  const GroupCreateError(this.error);
}

class NotLoggedInError {
  const NotLoggedInError();
}