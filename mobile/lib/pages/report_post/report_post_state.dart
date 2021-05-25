import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// ReportPostMessage
///
@immutable
class ReportPostMessage {}

class ReportPostSuccess implements ReportPostMessage {
  const ReportPostSuccess();
}

class ReportPostError implements ReportPostMessage {
  final Object error;
  const ReportPostError(this.error);
}

@immutable
abstract class ReportError {}

class ReportMessageError implements ReportError {
  const ReportMessageError();
}

class NotLoggedInError {
  const NotLoggedInError();
}
