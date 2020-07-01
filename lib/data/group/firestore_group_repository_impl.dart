import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treeapp/models/old/chat_entity.dart';
import 'package:treeapp/pages/create_message/create_message_state.dart';
import './firestore_group_repository.dart';
import '../../models/old/group_entity.dart';

class FirestoreGroupRepositoryImpl implements FirestoreGroupRepository {
  final Firestore _firestore;

  const FirestoreGroupRepositoryImpl(this._firestore);
  
  @override
  Stream<List<GroupEntity>> get() {
    return _firestore
      .collection('groupBase')
      .snapshots()
      .map(_toEntities);
  }

  @override
  Stream<GroupEntity> getById({String groupId}) {
    return _firestore
      .collection('groupBase')
      .document(groupId)
      .snapshots()
      .map((snapshot) => GroupEntity.fromDocumentSnapshot(snapshot));
  }

  List<GroupEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map((documentSnapshot) {
      return GroupEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> save(
    String groupId, 
    List<MemberItem> members, 
    bool isPrivate, 
    bool isGroup, 
    bool isRoom, 
    bool isConversation,
    String ownerId,
    bool byAdmin,
    bool isVerified,
  ) async {
    final TransactionHandler transactionHandler = (transaction) async {
      final group = <String, dynamic>{
        'byAdmin': byAdmin,
        'createdAt': FieldValue.serverTimestamp(),
        'groupMembers': members.map((member) {
          return <String, String>{
            'fullName': member.name,
            'image': member.image,
            'uid': member.id,
          };
        }).toList(),
        'isConversation': isConversation,
        'isGroup': isGroup,
        'isGroupPrivate': isPrivate,
        'isRoom': isRoom,
        'isVerified': isVerified,
        'ownerId': ownerId,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      var room = await _firestore
        .collection('groupBase')
        .add(group)
        .then((doc) {
          return <String, dynamic>{
            'roomId': doc.documentID,
            'isRoom': isRoom,
          };
        });

      final chat = <String, dynamic>{
        'chatId': room['roomId'],
        'docId': room['roomId'],
        'fullName': '',
        'churchName': '',
        'image': '',
        'isChurch': false,
        'isConversation': isConversation,
        'isGroup': isGroup,
        'isRoom': isRoom,
        'isTree': false,
        'pushNotificationToken': '',
        'token': '',
        'uid': ownerId,
        'userImage': '',
      };
      
      members.forEach((member) async {
        await _firestore
          .collection('userBase')
          .document(member.id)
          .updateData({
            'myChatsList13': FieldValue.arrayUnion([chat]),
          });
      });

      return room;
    };
    
    return _firestore.runTransaction(transactionHandler).then(
      (result) => result is Map<String, dynamic> ? result : result.cast<String, dynamic>()
    );
  }
}