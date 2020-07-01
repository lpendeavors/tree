import 'package:cloud_firestore/cloud_firestore.dart';
import './firestore_request_repository.dart';
import '../../models/old/request_entity.dart';
import '../../models/old/user_entity.dart';

class FirestoreRequestRepositoryImpl implements FirestoreRequestRepository {
  final Firestore _firestore;

  const FirestoreRequestRepositoryImpl(
    this._firestore,
  );

  @override
  Stream<RequestEntity> requestById({String requestId}) {
    return _firestore
      .collection('requestBase')
      .document(requestId)
      .snapshots()
      .map((snapshot) => RequestEntity.fromDocumentSnapshot(snapshot));
  }

  @override
  Stream<List<UserEntity>> requestsByOwner({String uid}) {
    return _firestore
      .collection('requestBase')
      .where('ownerId', isEqualTo: uid)
      .snapshots()
      .map(_toEntities);
  }

  @override
  Stream<List<UserEntity>> requestsByUser({String uid}) async* {
    List<String> userIds = await _firestore
      .collection('requestBase')
      .where('personId', isEqualTo: uid)
      .getDocuments()
      .then((requests) {
        return requests.documents
          .map((doc) => doc['ownerId'] as String)
          .toList();
      });

    if (userIds.isEmpty) {
      yield* Stream.value([]);
    } else {
      yield* _firestore
        .collection('userBase')
        .where('uid', whereIn: userIds)
        .snapshots()
        .map(_toEntities);
    }
  }

  @override
  Future<void> saveRequest({
    String to,
    String toUser,
    String from,
    String fromUser,
    String image,
    String token,
  }) {
    final TransactionHandler transactionHandler = (transaction) async {
      final request = <String, dynamic> {
        'ownerId': from,
        'personId': to,
        'image': image,
        'pushNotificationToken': token,
        'createdAt': FieldValue.serverTimestamp(),
        'modifiedAt': FieldValue.serverTimestamp(),
      };

      final notification = <String, dynamic> {
        'title': 'Request accepted',
        'fullName': from,
        'body': 'accepted your friend request',
        'image': image,
        'ownerId': toUser,
        'message': '$from accepted your friend request',
        'tokenId': token,
      };

      _firestore
        .collection('requestBase')
        .add(request);
      
      _firestore
        .collection('notificationBase')
        .add(notification);

      _firestore
        .collection('userBase')
        .document(to)
        .updateData({
          'receivedRequests': FieldValue.arrayRemove([from]),
        });
      
      _firestore
        .collection('userBase')
        .document(from)
        .updateData({
          'sentRequests': FieldValue.arrayRemove([to]),
        });
    };

    return _firestore.runTransaction(transactionHandler)
      .then((_) {
        // Send push notification
      });
  }

  List<UserEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map((documentSnapshot) {
      return UserEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }
}