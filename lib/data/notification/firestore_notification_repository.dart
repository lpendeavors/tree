import 'package:meta/meta.dart';
import '../../models/old/notification_entity.dart';

abstract class FirestoreNotificationRepository {
  Stream<NotificationEntity> getById({
    @required String notificationId,
  });

  Stream<List<NotificationEntity>> get();

  Stream<List<NotificationEntity>> getByOwner(String ownerId);

  Future<Map<String, String>> save(NotificationEntity notification);

  Future<void> markRead(
    List<String> notificationIds,
    String uid,
  );
}
