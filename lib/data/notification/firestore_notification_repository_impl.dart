import 'package:cloud_firestore/cloud_firestore.dart';
import './firestore_notification_repository.dart';
import '../../models/old/notification_entity.dart';

class FirestoreNotificationRepositoryImpl
    implements FirestoreNotificationRepository {
  final FirebaseFirestore _firestore;

  const FirestoreNotificationRepositoryImpl(this._firestore);

  @override
  Stream<List<NotificationEntity>> get() {
    return _firestore
        .collection('notificationBase')
        .orderBy('date', descending: true)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Stream<NotificationEntity> getById({String notificationId}) {
    return _firestore
        .collection('notificationBase')
        .doc(notificationId)
        .snapshots()
        .map((snapshot) => NotificationEntity.fromDocumentSnapshot(snapshot));
  }

  @override
  Future<Map<String, String>> save(NotificationEntity notification) {
    // TODO: implement save
    return null;
  }

  List<NotificationEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((documentSnapshot) {
      return NotificationEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }

  @override
  Stream<List<NotificationEntity>> getByOwner(String ownerId) {
    return _firestore
        .collection('notificationBase')
        .where('ownerId', isEqualTo: ownerId)
        .limit(15)
        .orderBy('time', descending: true)
        .snapshots()
        .map(_toEntities);
  }

  @override
  void markRead(List<String> notificationIds, String uid) async {
    var batch = _firestore.batch();

    notificationIds.forEach((id) {
      batch.update(_firestore.doc('notificationBase/$id'), {
        'readBy': FieldValue.arrayUnion([uid]),
      });
    });

    await batch.commit();
  }
}
