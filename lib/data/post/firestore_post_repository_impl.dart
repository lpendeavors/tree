import 'package:cloud_firestore/cloud_firestore.dart';
import './firestore_post_repository.dart';
import '../../models/post_entity.dart';

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
  Stream<List<PostEntity>> posts({
    String uid,
    bool isAdmin,
  }) {
    return _firestore
      .collection('postBase')
      .where('parties', arrayContains: uid)
      .where('isAdmin', isEqualTo: isAdmin)
      .orderBy('time', descending: true)
      .snapshots()
      .map(_toEntities);
  }

  List<PostEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map((documentSnapshot) {
      return PostEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }
}