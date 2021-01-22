import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// ReportUserMessage
///
@immutable
class ReportUserMessage {}

class ReportUserSuccess implements ReportUserMessage {
  const ReportUserSuccess();
}

class ReportUserError implements ReportUserMessage {
  final Object error;
  const ReportUserError(this.error);
}

@immutable
abstract class ReportError {}

class ReportMessageError implements ReportError {
  const ReportMessageError();
}

class NotLoggedInError {
  const NotLoggedInError();
}
