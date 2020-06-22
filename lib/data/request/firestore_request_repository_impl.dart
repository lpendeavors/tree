import 'package:cloud_firestore/cloud_firestore.dart';
import './firestore_request_repository.dart';
import '../../models/old/request_entity.dart';
import '../../models/old/user_entity.dart';

class FirestoreRequestRepositoryImpl implements FirestoreRequestRepository {
  final Firestore _firestore;

  const FirestoreRequestRepositoryImpl(this._firestore);

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
          .map((doc) => doc['personId'] as String)
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
  Future<void> saveRequest({RequestEntity request}) {
    // TODO: implement saveRequest
    throw UnimplementedError();
  }

  List<UserEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map((documentSnapshot) {
      return UserEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }
}