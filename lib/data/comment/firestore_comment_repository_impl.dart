import 'package:cloud_firestore/cloud_firestore.dart';
import './firestore_comment_repository.dart';
import '../../models/old/comment_entity.dart';

class FirestoreCommentRepositoryImpl implements FirestoreCommentRepository {
  final Firestore _firestore;

  const FirestoreCommentRepositoryImpl(this._firestore);

  @override
  Stream<List<CommentEntity>> getByPost(String postId) {
    return _firestore
      .collection('commentsBase')
      .where('postId', isEqualTo: postId)
      .snapshots()
      .map(_toEntities);
  }

  List<CommentEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map((documentSnapshot) {
      return CommentEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }
}