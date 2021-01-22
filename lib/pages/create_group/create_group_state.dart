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
  final Map<String, dynamic> details;
  const GroupCreateSuccess(this.details);
}

class GroupCreateError implements GroupCreateMessage {
  final Object error;
  const GroupCreateError(this.error);
}

class NotLoggedInError {
  const NotLoggedInError();
}

@immutable
class GroupCreateState extends Equatable {
  final GroupItem groupItem;
  final bool isLoading;
  final Object error;

  const GroupCreateState({
    @required this.groupItem,
    @required this.isLoading,
    @required this.error,
  });

  GroupCreateState copyWith({groupItem, isLoading, error}) {
    return GroupCreateState(
      groupItem: groupItem ?? this.groupItem,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [
        groupItem,
        isLoading,
        error,
      ];

  @override
  bool get stringify => true;
}

class GroupItem extends Equatable {
  final String id;
  final String name;
  final String image;
  final String description;
  final bool isPublic;

  GroupItem({
    @required this.id,
    @required this.name,
    @required this.image,
    @required this.description,
    @required this.isPublic,
  });

  @override
  List get props => [
        id,
        name,
        image,
        description,
        isPublic,
      ];

  @override
  bool get stringify => true;
}
