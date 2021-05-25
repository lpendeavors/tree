import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// ReportPostMessage
///
@immutable
class ReportGroupMessage {}

class ReportGroupSuccess implements ReportGroupMessage {
  const ReportGroupSuccess();
}

class ReportGroupError implements ReportGroupMessage {
  final Object error;
  const ReportGroupError(this.error);
}

@immutable
abstract class ReportError {}

class ReportMessageError implements ReportError {
  const ReportMessageError();
}

class NotLoggedInError {
  const NotLoggedInError();
}
