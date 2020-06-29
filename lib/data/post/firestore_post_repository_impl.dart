import 'package:cloud_firestore/cloud_firestore.dart';
import './firestore_post_repository.dart';
import '../../models/old/post_entity.dart';

class FirestorePostRepositoryImpl implements FirestorePostRepository {
  final Firestore _firestore;

  const FirestorePostRepositoryImpl(this._firestore);

  @override
  Future<Map<String, String>> savePost(PostEntity post) {
    return null;
  }

  @override
  Stream<PostEntity> postById({String postId}) {
    return _firestore
      .collection('postBase')
      .document(postId)
      .snapshots()
      .map((snapshot) => PostEntity.fromDocumentSnapshot(snapshot));
  }

  @override
  Stream<List<PostEntity>> postsByUser({
    String uid,
  }) {
    return _firestore
      .collection('postBase')
      .where('parties', arrayContains: uid)
      .snapshots()
      .map(_toEntities);
  }

  @override
  Stream<List<PostEntity>> postsByOwner({
    String uid,
  }) {
    return _firestore
      .collection('postBase')
      .where('ownerId', isEqualTo: uid)
      .snapshots()
      .map(_toEntities);
  }

  @override
  Stream<List<PostEntity>> getByAdmin() {
    return _firestore
      .collection('postBase')
      .where('byAdmin', isEqualTo: true)
      .snapshots()
      .map(_toEntities);
  }

  @override
  Stream<List<PostEntity>> postsForCollage() {
    return _firestore
      .collection('postBase')
      .where('isVerified', isEqualTo: true)
      //.where('postData', isNull: false)
      .snapshots()
      .map(_toEntities);
  }

  @override
  Stream<List<PostEntity>> getByGroup(String postId) {
    return _firestore
      .collection('postBase')
      .where('postId', isEqualTo: postId)
      .snapshots()
      .map(_toEntities);
  }

  List<PostEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map((documentSnapshot) {
      return PostEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }

  @override
  Future<void> likeOrUnlikePost({
    bool shouldLike, 
    String postId, 
    String userId
  }) {
    if (shouldLike) {
      return _firestore
        .document('postBase/$postId')
        .updateData({'likes': FieldValue.arrayUnion([userId])});
    } else {
      return _firestore
        .document('postBase/$postId')
        .updateData({'likes': FieldValue.arrayRemove([userId])});
    }
  }
}