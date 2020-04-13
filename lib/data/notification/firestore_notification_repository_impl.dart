import 'package:cloud_firestore/cloud_firestore.dart';
import './firestore_notification_repository.dart';
import '../../models/notification_entity.dart';

class FirestoreNotificationRepositoryImpl implements FirestoreNotificationRepository {
  final Firestore _firestore;

  const FirestoreNotificationRepositoryImpl(this._firestore);

  @override
  Stream<List<NotificationEntity>> get() {
    return _firestore
        .collection('notificationBase')
        .orderBy('time', descending: true)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Stream<NotificationEntity> getById({String notificationId}) {
    return _firestore
        .collection('notificationBase')
        .document(notificationId)
        .snapshots()
        .map((snapshot) => NotificationEntity.fromDocumentSnapshot(snapshot));
  }

  @override
  Future<Map<String, String>> save(NotificationEntity notification) {
    return null;
  }

  List<NotificationEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map((documentSnapshot) {
      return NotificationEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }

}