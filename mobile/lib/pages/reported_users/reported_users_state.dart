import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:treeapp/pages/chat/chat_tabs_state.dart';
import 'package:treeapp/pages/comments/comments_state.dart';
import 'package:treeapp/pages/feed/feed_state.dart';

///
/// Message
///
abstract class ReportedUsersMessage {
  const ReportedUsersMessage();
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
@immutable
class ReportedUsersState extends Equatable {
  final bool isLoading;
  final Object error;
  final List<ReportItem> reports;

  const ReportedUsersState({
    @required this.isLoading,
    @required this.error,
    @required this.reports,
  });

  ReportedUsersState copyWith({isLoading, error, reports}) {
    return ReportedUsersState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      reports: reports ?? this.reports,
    );
  }

  @override
  List get props => [
        isLoading,
        error,
        reports,
      ];

  @override
  bool get stringify => true;
}

@immutable
class ReportItem extends Equatable {
  final String id;
  final String group;
  final String post;
  final String comment;
  final String userImage;
  final String userId;
  final String message;
  final String userName;
  final String user;

  const ReportItem({
    @required this.id,
    @required this.group,
    @required this.post,
    @required this.userImage,
    @required this.userId,
    @required this.userName,
    @required this.message,
    @required this.comment,
    @required this.user,
  });

  @override
  List get props => [
        id,
        group,
        post,
        userImage,
        userId,
        userName,
        message,
        comment,
        user,
      ];
}

@immutable
class ReportedGroup extends Equatable {
  final String id;

  const ReportedGroup({
    @required this.id,
  });

  @override
  List get props => [
        id,
      ];
}

@immutable
class ReportedPost extends Equatable {
  final String id;

  const ReportedPost({
    @required this.id,
  });

  @override
  List get props => [
        id,
      ];
}
