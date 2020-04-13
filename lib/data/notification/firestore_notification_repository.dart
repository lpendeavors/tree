import 'package:meta/meta.dart';
import '../../models/notification_entity.dart';

abstract class FirestoreNotificationRepository {
  Stream<NotificationEntity> getById({
    @required String notificationId,
  });

  Stream<List<NotificationEntity>> get();

  Future<Map<String, String>> save(NotificationEntity notification);
}