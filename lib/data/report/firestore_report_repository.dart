import '../../models/old/report_entity.dart';

abstract class FirestoreReportRepository {
  Stream<List<ReportEntity>> get();

  Stream<List<ReportEntity>> getPosts();

  Stream<List<ReportEntity>> getGroups();

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
    String userId,
    int reportType,
    String groupId,
  );

  Future<void> saveUserReport(
    String ownerId,
    String ownerEmail,
    String ownerName,
    String ownerImage,
    String token,
    bool byAdmin,
    bool isVerified,
    bool isChurch,
    String message,
    String userId,
    int reportType,
    String groupId,
  );
}
