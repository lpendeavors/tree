import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<String> save(
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
    final group = <String, dynamic>{
      'byAdmin': byAdmin,
      'createdAt': FieldValue.serverTimestamp(),
      'groupMembers': members,
      'isConversation': isConversation,
      'isGroup': isGroup,
      'isGroupPrivate': isPrivate,
      'isRoom': isRoom,
      'isVerified': isVerified,
      'ownerId': ownerId,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore
      .collection('groupBase')
      .document(groupId)
      .setData(group, merge: true)
      .then((doc) => print('done'))
      .catchError((e) => print(e.toString()));

    return groupId;
  }

}