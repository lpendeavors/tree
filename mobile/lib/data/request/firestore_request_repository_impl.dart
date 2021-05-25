import 'package:cloud_firestore/cloud_firestore.dart';
import '../../notification_util.dart';
import './firestore_request_repository.dart';
import '../../models/old/request_entity.dart';
import '../../models/old/user_entity.dart';

class FirestoreRequestRepositoryImpl implements FirestoreRequestRepository {
  final FirebaseFirestore _firestore;

  const FirestoreRequestRepositoryImpl(
    this._firestore,
  );

  @override
  Stream<RequestEntity> requestById({
    String requestId,
  }) {
    return _firestore
        .collection('requestBase')
        .doc(requestId)
        .snapshots()
        .map((snapshot) => RequestEntity.fromDocumentSnapshot(snapshot));
  }

  @override
  Stream<List<UserEntity>> requestsByOwner({
    String uid,
  }) {
    return _firestore
        .collection('requestBase')
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Stream<List<UserEntity>> requestsByUser({
    List<String> uids,
  }) async* {
    List<UserEntity> users = List();
    for (var u in uids) {
      var request =
          await _firestore.collection('userBase').doc(u).snapshots().first;

      users.add(UserEntity.fromDocumentSnapshot(request));
    }

    yield* Stream.value(users);
  }

  List<UserEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((documentSnapshot) {
      return UserEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }

  @override
  Future<void> acceptRequest({
    String toName,
    String toId,
    String fromName,
    String fromId,
    String image,
    String token,
  }) {
    final TransactionHandler transactionHandler = (transaction) async {
      final notification = <String, dynamic>{
        'title': 'Request accepted',
        'fullName': toName,
        'body': 'accepted your friend request',
        'image': image,
        'ownerId': toId,
        'message': '$fromName accepted your friend request'
      };

      var user = await _firestore.doc('userBase/$toId').snapshots().first;
      var userEntity = UserEntity.fromDocumentSnapshot(user);

      // NotificationService.sendPlainPush(
      //   title: 'Request accepted',
      //   body: '$fromName accepted your friend request',
      //   token: userEntity.pushNotificationToken,
      //   image: image,
      // );

      // _firestore.collection('notificationBase').add(notification);

      _firestore.collection('userBase').doc(toId).update({
        'connections': FieldValue.arrayUnion([fromId]),
      });

      _firestore.collection('userBase').doc(fromId).update({
        'connections': FieldValue.arrayUnion([toId]),
      });

      _firestore.collection('userBase').doc(fromId).update({
        'receivedRequests': FieldValue.arrayRemove([toId]),
      });

      _firestore.collection('userBase').doc(toId).update({
        'sentRequests': FieldValue.arrayRemove([fromId]),
      });
    };

    return _firestore.runTransaction(transactionHandler).then((_) {
      print('done');
    });
  }

  @override
  Future<void> addRequest({
    String toName,
    String toId,
    String fromName,
    String fromId,
    String image,
    String token,
  }) async {
    var toUser = await _firestore.doc('userBase/$toId').snapshots().first;
    var toEntity = UserEntity.fromDocumentSnapshot(toUser);

    var fromUser = await _firestore.doc('userBase/$fromId').snapshots().first;
    var fromEntity = UserEntity.fromDocumentSnapshot(fromUser);
    var fromName =
        fromEntity.isChurch ? fromEntity.churchName : fromEntity.fullName;

    final TransactionHandler transactionHandler = (transaction) async {
      final request = <String, dynamic>{
        'ownerId': toId,
        'personId': fromId,
        'image': image,
        'pushNotificationToken': token,
        'createdAt': FieldValue.serverTimestamp(),
        'modifiedAt': FieldValue.serverTimestamp(),
      };

      final notification = <String, dynamic>{
        'title': 'Friend Request',
        'fullName': fromName,
        'body': 'sent you a friend request',
        'image': image,
        'ownerId': toId,
        'message': '$fromName sent you a friend request',
        'tokenId': token,
      };

      _firestore.collection('requestBase').add(request);

      // _firestore.collection('notificationBase').add(notification);

      _firestore.collection('userBase').doc(toId).update({
        'receivedRequests': FieldValue.arrayUnion([fromId]),
      });

      _firestore.collection('userBase').doc(fromId).update({
        'sentRequests': FieldValue.arrayUnion([toId]),
      });
    };

    await _firestore.runTransaction(transactionHandler);

    // NotificationService.sendPlainPush(
    //   title: 'New request',
    //   body: '$fromName sent you a friend request',
    //   token: toEntity.pushNotificationToken,
    //   image: fromEntity.image,
    // );
  }

  @override
  Future<void> declineRequest({
    String toName,
    String toId,
    String fromName,
    String fromId,
    String image,
    String token,
  }) async {
    final TransactionHandler transactionHandler = (transaction) async {
      final notification = <String, dynamic>{
        'title': 'Request declined',
        'fullName': fromName,
        'body': 'declined your friend request',
        'image': image,
        'ownerId': toId,
        'message': '$fromName declined your friend request',
        'tokenId': token,
      };

      // _firestore.collection('notificationBase').add(notification);

      _firestore.collection('userBase').doc(toId).update({
        'sentRequests': FieldValue.arrayRemove([fromId]),
      });

      _firestore.collection('userBase').doc(fromId).update({
        'receivedRequests': FieldValue.arrayRemove([toId]),
      });

      var request = await _firestore
          .collection('requestBase')
          .where('ownerId', isEqualTo: toId)
          .where('personId', isEqualTo: fromId)
          .snapshots()
          .map(_toEntities)
          .first;

      if (request.isNotEmpty) {
        var requestId = request[0].documentId;
        await _firestore.collection('requestBase').doc(requestId).delete();
      }
    };

    await _firestore.runTransaction(transactionHandler);
  }
}
