import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treeapp/pages/create_message/create_message_state.dart';
import 'package:treeapp/user_bloc/user_login_state.dart';
import './firestore_group_repository.dart';
import '../../models/old/group_entity.dart';
import '../../util/model_utils.dart';

class FirestoreGroupRepositoryImpl implements FirestoreGroupRepository {
  final Firestore _firestore;

  const FirestoreGroupRepositoryImpl(this._firestore);

  @override
  Stream<List<GroupEntity>> get() {
    return _firestore.collection('groupBase').snapshots().map(_toEntities);
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
    String groupName,
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

      if (isGroup) {
        group.addAll({
          'searchData': createSearchData(groupName),
        });
      }

      var room =
          await _firestore.collection('groupBase').add(group).then((doc) {
        return <String, dynamic>{
          'roomId': doc.documentID,
          'isRoom': isRoom,
          'isGroup': isGroup,
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

      // members.forEach((member) async {
      //   await _firestore.collection('userBase').document(member.id).updateData({
      //     'myChatsList13': FieldValue.arrayUnion([chat]),
      //   });
      // });

      return room;
    };

    return _firestore.runTransaction(transactionHandler).then((result) =>
        result is Map<String, dynamic>
            ? result
            : result.cast<String, dynamic>());
  }

  @override
  Future<Map<String, dynamic>> launchDM(
      String userID, LoggedInUser loginState) async {
    final TransactionHandler transactionHandler = (transaction) async {
      var otherUser = await _firestore.document('userBase/$userID').get();

      var personalMember = <String, String>{
        'fullName': loginState.fullName,
        'image': loginState.image,
        'uid': loginState.uid,
      };

      var otherMember = <String, String>{
        'fullName': otherUser.data['fullName'],
        'image': otherUser.data['image'],
        'uid': userID,
      };

      var check = await _firestore.collection('groupBase').where('groupMembers',
          isEqualTo: [personalMember, otherMember]).getDocuments();
      if (check.documents.length != 0) {
        return <String, dynamic>{
          'roomId': check.documents[0].documentID,
          'isRoom': false,
          'isGroup': true,
        };
      } else {
        final group = <String, dynamic>{
          'byAdmin': loginState.isAdmin,
          'createdAt': FieldValue.serverTimestamp(),
          'groupMembers': [personalMember, otherMember],
          'isConversation': true,
          'isGroup': true,
          'isGroupPrivate': true,
          'isRoom': false,
          'isVerified': loginState.isVerified,
          'ownerId': loginState.uid,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        var room =
            await _firestore.collection('groupBase').add(group).then((doc) {
          return <String, dynamic>{
            'roomId': doc.documentID,
            'isRoom': false,
            'isGroup': true,
          };
        });

        final chat = <String, dynamic>{
          'chatId': room['roomId'],
          'docId': room['roomId'],
          'fullName': '',
          'churchName': '',
          'image': '',
          'isChurch': false,
          'isConversation': true,
          'isGroup': true,
          'isRoom': false,
          'isTree': false,
          'pushNotificationToken': '',
          'tokenID': '',
          'uid': loginState.uid,
          'userImage': '',
        };

        await _firestore
            .collection('userBase')
            .document(loginState.uid)
            .updateData({
          'myChatsList13': FieldValue.arrayUnion([chat]),
        });

        await _firestore.collection('userBase').document(userID).updateData({
          'myChatsList13': FieldValue.arrayUnion([chat]),
        });

        return room;
      }
    };

    return _firestore.runTransaction(transactionHandler).then((result) =>
        result is Map<String, dynamic>
            ? result
            : result.cast<String, dynamic>());
  }

  @override
  Future<List<GroupEntity>> runSearchQuery(String query) {
    return _firestore
        .collection("groupBase")
        .where("searchData", arrayContains: query.trim())
        .limit(30)
        .getDocuments()
        .then(_toEntities);
  }

  @override
  Stream<List<GroupEntity>> getDefaultRooms() {
    return _firestore
        .collection('groupBase')
        .where('byAdmin', isEqualTo: true)
        .where('isGroupPrivate', isEqualTo: false)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Stream<List<GroupEntity>> getGroupsByUser(String uid) {
    return _firestore
        .collection('groupBase')
        .where('isGroup', isEqualTo: true)
        .where('isRoom', isEqualTo: false)
        .where('parties', arrayContains: uid)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Stream<List<GroupEntity>> getRoomsByUser(String uid) {
    return _firestore
        .collection('groupBase')
        .where('byAdmin', isEqualTo: false)
        .where('parties', arrayContains: uid)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Future<void> joinGroup(String groupId, String uid) async {
    await _firestore.document('groupBase/$groupId').updateData({
      'parties': FieldValue.arrayUnion([uid]),
    });
  }

  @override
  Stream<List<GroupEntity>> getChurchRoom(String churchId) {
    return _firestore
        .collection('groupBase')
        .where('ownerId', isEqualTo: churchId)
        .snapshots()
        .map(_toEntities);
  }
}
