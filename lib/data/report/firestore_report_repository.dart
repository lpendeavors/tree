import '../../models/old/report_entity.dart';

abstract class FirestoreReportRepository {
  Stream<List<ReportEntity>> get();

  Future<void> save(
    String ownerId,
    String ownerEmail,
    String ownerName,
    String ownerImage,
    String token,
    bool byAdmin,
    bool isVerified,
    bool isChurch,
    String postId,
    String message,
  );
}
