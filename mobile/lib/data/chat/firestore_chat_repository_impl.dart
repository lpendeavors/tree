import 'dart:async';

import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/old/chat_entity.dart';
import '../../data/chat/firestore_chat_repository.dart';

class FirestoreChatRepositoryImpl implements FirestoreChatRepository {
  final FirebaseFirestore _firestore;

  const FirestoreChatRepositoryImpl(
    this._firestore,
  );

  @override
  Stream<List<ChatEntity>> get() {
    return _firestore.collection('chatBase').snapshots().map(_toEntities);
  }

  @override
  Stream<ChatEntity> getById({String chatId}) {
    return _firestore
        .collection('chatBase')
        .doc(chatId)
        .snapshots()
        .map((snapshot) => ChatEntity.fromDocumentSnapshot(snapshot));
  }

  @override
  Stream<List<ChatEntity>> getByOwner(String ownerId) {
    return _firestore
        .collection('chatBase')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Stream<List<ChatEntity>> getByUser({
    @required String uid,
  }) {
    return _firestore
        .collection('chatBase')
        .where('parties', arrayContains: uid)
        .snapshots()
        .map(_toEntities);
    ;
  }

  List<ChatEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((documentSnapshot) {
      return ChatEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }

  @override
  Stream<List<ChatEntity>> getByGroup(String roomId) {
    return _firestore
        .collection('chatBase')
        .where('chatId', isEqualTo: roomId)
        .orderBy('time', descending: true)
        .limit(30)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Future<Map<String, String>> send(
    String message,
    int messageType,
    bool byAdmin,
    String chatId,
    String ownerId,
    String ownerName,
    String ownerEmail,
    String ownerImage,
    bool isVerified,
    bool isChurch,
    bool isRoom,
    String token,
    bool showDate,
    List<String> members,
    bool isGif,
    String gif,
  ) async {
    var newMessage = <String, dynamic>{
      'byAdmin': byAdmin,
      'chatId': chatId,
      'churchName': isChurch ? ownerName : '',
      'country': '',
      'email': ownerEmail,
      'fullName': ownerName,
      'image': ownerImage,
      'isChurch': isChurch,
      'isRoom': isRoom,
      'isVerified': isVerified,
      'message': message,
      'ownerId': ownerId,
      'parties': members,
      'pushNotificationToken': token,
      'readBy': [ownerId],
      'showDate': showDate,
      'timeUpdated': DateTime.now().millisecondsSinceEpoch,
      'tokenID': token,
      'type': gif.isNotEmpty ? 2 : 0,
      'uid': ownerId,
      'updatedAt': FieldValue.serverTimestamp(),
      'userImage': '',
      'username': '',
      'visibility': 0,
      'time': DateTime.now().millisecondsSinceEpoch,
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (gif.isNotEmpty) {
      newMessage.addAll({
        'imagePath': gif,
      });
    }

    await _firestore.collection('chatBase').add(newMessage);
  }

  @override
  Future<void> markRead(List<String> messageIds, String uid) async {
    var batch = _firestore.batch();

    messageIds.forEach((id) {
      return batch.update(_firestore.doc('chatBase/$id'), {
        'readBy': FieldValue.arrayUnion([uid]),
      });
    });

    await batch.commit();
  }

  @override
  Future<void> delete(String messageId) async {
    await _firestore.doc('chatBase/$messageId').delete();
  }
}
