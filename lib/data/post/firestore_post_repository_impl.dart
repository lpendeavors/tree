import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import './firestore_post_repository.dart';
import '../../models/old/post_entity.dart';

class FirestorePostRepositoryImpl implements FirestorePostRepository {
  final Firestore _firestore;
  final FirebaseStorage _storage;

  const FirestorePostRepositoryImpl(
    this._firestore,
    this._storage,
  );

  @override
  Future<Map<String, String>> savePost(
    String postId,
    bool byAdmin,
    String ownerName,
    String ownerImage,
    bool ownerIsAdmin,
    bool ownerIsChurch,
    bool ownerIsGroup,
    bool isHidden,
    int isPrivate,
    bool isReported,
    bool isVerified,
    String ownerId,
    List<String> parties,
    List<String> media,
    int mediaType,
    String message,
    String ownerNotificationToken,
    int type,
    String groupId,
    List<String> tagged,
  ) async {
    final post = <String, dynamic>{
      'byAdmin': byAdmin,
      'churchName': ownerIsChurch ? ownerName : '',
      'createdAt': FieldValue.serverTimestamp(),
      'fullName': ownerIsChurch ? '' : ownerName,
      'image': ownerImage,
      'isAdmin': ownerIsAdmin,
      'isChurch': ownerIsChurch,
      'isGroup': groupId == null ? false : true,
      'postId': groupId == null ? '' : groupId,
      'isHidden': false,
      'isPostPrivate': isPrivate,
      'isReported': false,
      'isVerified': isVerified,
      'likes': [],
      'ownerId': ownerId,
      'parties': parties,
      'postData': [],
      'postMessage': message,
      'pushNotificationToken': ownerNotificationToken,
      'tags': tagged,
      'time': DateTime.now().millisecondsSinceEpoch,
      'timeUpdated': DateTime.now().millisecondsSinceEpoch,
      'tokenID': ownerNotificationToken,
      'type': 0,
      'uid': ownerId,
      'updatedAt': FieldValue.serverTimestamp(),
      'visiblity': 0,
    };

    if (postId != null) {
      await _firestore
          .collection('postBase')
          .document(postId)
          .setData(post, merge: true);
    } else {
      List<String> imageUrls = await Future.wait(
        media.map((image) async {
          String id = Uuid().v1();
          StorageReference storageRef = _storage.ref().child(id);
          StorageUploadTask upload = storageRef.putFile(File(image));
          StorageTaskSnapshot task = await upload.onComplete;
          String url = await task.ref.getDownloadURL();

          return url;
        }).toList(),
      );

      if (media.isNotEmpty) {
        post.addAll({
          'postData': imageUrls.map((media) {
            return {
              'imageUrl': media,
              'type': 2,
            };
          }).toList(),
        });
      }

      await _firestore.collection('postBase').add(post);
    }
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
  Future<void> likeOrUnlikePost(
      {bool shouldLike, String postId, String userId}) async {
    if (shouldLike) {
      return _firestore.document('postBase/$postId').updateData({
        'likes': FieldValue.arrayUnion([userId])
      });
    } else {
      return _firestore.document('postBase/$postId').updateData({
        'likes': FieldValue.arrayRemove([userId])
      });
    }
  }
}
