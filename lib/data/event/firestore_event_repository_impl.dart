import 'package:cloud_firestore/cloud_firestore.dart';
import './firestore_event_repository.dart';
import '../../models/old/event_entity.dart';

class FirestoreEventRepositoryImpl implements FirestoreEventRepository {
  final Firestore _firestore;

  const FirestoreEventRepositoryImpl(this._firestore);

  @override
  Stream<List<EventEntity>> get() {
    var now = new DateTime.now();
    var yesterday = new DateTime(now.year, now.month, now.day - 1);

    return _firestore
      .collection('eventBase')
      .where('eventStartDate', isGreaterThanOrEqualTo: yesterday)
      .limit(15)
      .orderBy('eventStartDate')
      .snapshots()
      .map(_toEntities);
  }

  @override
  Stream<EventEntity> getById(String eventId) {
    return _firestore
      .collection('eventBase')
      .document(eventId)
      .snapshots()
      .map((snapshot) => EventEntity.fromDocumentSnapshot(snapshot));
  }

  @override
  Stream<List<EventEntity>> getByOwner(String ownerId) {
    return _firestore
      .collection('eventBase')
      .where('ownerId', isEqualTo: ownerId)
      .orderBy('eventStartDate')
      .snapshots()
      .map(_toEntities);
  }

  @override
  Future<Map<String, String>> save(
    String ownerId,
    String id,
    String title,
    DateTime startDate,
    DateTime startTime,
    DateTime endDate,
    DateTime endTime,
    String image,
    String webAddress,
    double cost,
    String venue,
    double budget
  ) {
    if (ownerId == null) {
      return Future.error('ownerId cannot be null');
    }
    if (title == null) {
      return Future.error('title cannot be null');
    }
    if (startDate == null) {
      return Future.error('startDate cannot be null');
    }

    final TransactionHandler transactionHandler = (transaction) async {
      final event = <String, dynamic>{

      };
    };

    return _firestore.runTransaction(transactionHandler)
      .then((result) => result is Map<String, String>
        ? result
        : result.cast<String, String>());
  }

  List<EventEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map((documentSnapshot) {
      return EventEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }
}