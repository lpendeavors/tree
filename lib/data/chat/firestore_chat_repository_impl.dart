import 'dart:async';

import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/old/chat_entity.dart';
import '../../data/chat/firestore_chat_repository.dart';

class FirestoreChatRepositoryImpl implements FirestoreChatRepository{
  final Firestore _firestore;

  const FirestoreChatRepositoryImpl(
      this._firestore,
  );

  @override
  Stream<List<ChatEntity>> get() {
    return _firestore
      .collection('chatBase')
      .snapshots()
      .map(_toEntities);
  }

  @override
  Stream<ChatEntity> getById({String chatId}) {
    return _firestore
      .collection('chatBase')
      .document(chatId)
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
    @required List<String> chatIds,
  }) {
    return _firestore
      .collection('chatBase')
      .where('parties', arrayContains: uid)
      .snapshots()
      .map(_toEntities);
  }

  List<ChatEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map((documentSnapshot) {
      return ChatEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }

  @override
  Stream<List<ChatEntity>> getByGroup(String groupId) {
    return _firestore
      .collection('chatBase')
      .where('chatId', isEqualTo: groupId)
      .snapshots()
      .map(_toEntities);
  }
}