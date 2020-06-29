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
  final String groupId;
  const GroupCreateSuccess(this.groupId);
}

class GroupCreateError implements GroupCreateMessage {
  final Object error;
  const GroupCreateError(this.error);
}

class NotLoggedInError {
  const NotLoggedInError();
}