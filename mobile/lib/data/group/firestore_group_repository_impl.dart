import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:treeapp/models/old/group_member.dart';
import 'package:treeapp/pages/create_message/create_message_state.dart';
import 'package:treeapp/user_bloc/user_login_state.dart';
import 'package:uuid/uuid.dart';
import './firestore_group_repository.dart';
import '../../models/old/group_entity.dart';
import '../../util/model_utils.dart';

class FirestoreGroupRepositoryImpl implements FirestoreGroupRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  const FirestoreGroupRepositoryImpl(
    this._firestore,
    this._storage,
  );

  @override
  Stream<List<GroupEntity>> get() {
    return _firestore.collection('groupBase').snapshots().map(_toEntities);
  }

  @override
  Stream<GroupEntity> getById({String groupId}) {
    return _firestore
        .collection('groupBase')
        .doc(groupId)
        .snapshots()
        .map((snapshot) => GroupEntity.fromDocumentSnapshot(snapshot));
  }

  List<GroupEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((documentSnapshot) {
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
    String groupImage,
    String groupDescription,
    bool mediaChanged,
  ) async {
    final TransactionHandler transactionHandler = (transaction) async {
      final group = <String, dynamic>{
        'byAdmin': byAdmin,
        'createdAt': FieldValue.serverTimestamp(),
        'groupMembers': members.map((member) {
          return <String, dynamic>{
            'fullName': member.name,
            'image': member.image,
            'uid': member.id,
            'groupAdmin': member.groupAdmin,
            'tokenID': member.token,
          };
        }).toList(),
        'isConversation': isConversation,
        'isGroup': isGroup,
        'isGroupPrivate': isPrivate,
        'isRoom': isRoom,
        'isVerified': isVerified,
        'ownerId': ownerId,
        'updatedAt': FieldValue.serverTimestamp(),
        'parties': members.map((m) => m.id).toList(),
      };

      if (groupName != null) {
        group.addAll({
          'groupName': groupName,
        });
      }

      if (groupDescription != null) {
        group.addAll({
          'groupDescription': groupDescription,
        });
      }

      if (isGroup) {
        if (groupName != null) {
          group.addAll({
            'searchData': createSearchData(groupName),
          });
        }

        if (groupImage != null && groupImage.isNotEmpty && mediaChanged) {
          var refId = new Uuid().v1();
          Reference storageReference = _storage.ref().child(refId);
          UploadTask uploadTask = storageReference.putFile(File(groupImage));
          await uploadTask
              .then((value) => value.ref.getDownloadURL())
              .then((url) {
            group.addAll({
              'groupImage': url,
            });
          });
        }
      }

      var room = groupId == null
          ? await _firestore.collection('groupBase').add(group).then((doc) {
              return <String, dynamic>{
                'roomId': doc.id,
                'isRoom': isRoom,
                'isGroup': isGroup,
              };
            })
          : await _firestore
              .doc('groupBase/$groupId')
              .update(group)
              .then((doc) {
              return <String, dynamic>{
                'roomId': groupId,
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
      var otherUser = await _firestore.doc('userBase/$userID').get();

      var personalMember = <String, String>{
        'fullName': loginState.fullName,
        'image': loginState.image,
        'uid': loginState.uid,
      };

      var otherMember = <String, String>{
        'fullName': otherUser.data()['fullName'],
        'image': otherUser.data()['image'],
        'uid': userID,
      };

      var check = await _firestore.collection('groupBase').where('groupMembers',
          isEqualTo: [personalMember, otherMember]).get();
      if (check.docs.length != 0) {
        return <String, dynamic>{
          'roomId': check.docs[0].id,
          'isRoom': false,
          'isGroup': false,
        };
      } else {
        final group = <String, dynamic>{
          'byAdmin': loginState.isAdmin,
          'createdAt': FieldValue.serverTimestamp(),
          'groupMembers': [personalMember, otherMember],
          'isConversation': true,
          'isGroup': false,
          'isGroupPrivate': true,
          'isRoom': false,
          'isVerified': loginState.isVerified,
          'ownerId': loginState.uid,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        var room =
            await _firestore.collection('groupBase').add(group).then((doc) {
          return <String, dynamic>{
            'roomId': doc.id,
            'isRoom': false,
            'isGroup': false,
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
          'isGroup': false,
          'isRoom': false,
          'isTree': false,
          'pushNotificationToken': '',
          'tokenID': '',
          'uid': loginState.uid,
          'userImage': '',
        };

        // await _firestore.collection('userBase').doc(loginState.uid).update({
        //   'myChatsList13': FieldValue.arrayUnion([chat]),
        // });

        // await _firestore.collection('userBase').doc(userID).update({
        //   'myChatsList13': FieldValue.arrayUnion([chat]),
        // });

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
        .get()
        .then(_toEntities);
  }

  @override
  Stream<List<GroupEntity>> getDefaultRooms() {
    return _firestore
        .collection('groupBase')
        .where('byAdmin', isEqualTo: true)
        .where('isRoom', isEqualTo: true)
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
        .where('isRoom', isEqualTo: true)
        .where('parties', arrayContains: uid)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Future<void> joinGroup(
    String groupId,
    String uid,
    String image,
    String name,
  ) async {
    final TransactionHandler transactionHandler = (transaction) async {
      Map<String, String> memberDetails = {
        'uid': uid,
        'fullName': name,
        'image': image,
      };

      await _firestore.doc('groupBase/$groupId').update({
        'parties': FieldValue.arrayUnion([uid]),
        'groupMembers': FieldValue.arrayUnion([memberDetails]),
      });
    };

    await _firestore.runTransaction(transactionHandler);
  }

  @override
  Stream<List<GroupEntity>> getChurchRoom(String churchId) {
    return _firestore
        .collection('groupBase')
        .where('ownerId', isEqualTo: churchId)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Future<void> delete(
    String groupId,
    bool permanent,
  ) async {
    if (permanent) {
      await _firestore.doc('groupBase/$groupId').delete();
    } else {
      await _firestore.doc('groupBase/$groupId').update({
        'isSuspended': true,
      });
    }
  }

  @override
  Future<void> leave(String groupId, String userId) async {
    var groupDoc = _firestore.doc('groupBase/$groupId');
    var groupSnaps = groupDoc.snapshots();
    var groupSnap = await groupSnaps.first;
    GroupEntity group = GroupEntity.fromDocumentSnapshot(groupSnap);
    var me = group.groupMembers.where((m) => m.uid == userId).toList();
    if (me.isNotEmpty) {
      group.groupMembers.remove(me[0]);
      await groupDoc.update(group.toJson());
      await groupDoc.update({
        'parties': FieldValue.arrayRemove([userId]),
      });

      var chatsSnap = _firestore
          .collection('chatBase')
          .where('chatId', isEqualTo: groupId)
          .where('parties', arrayContains: userId)
          .snapshots();

      if (chatsSnap != null) {
        var chats = await chatsSnap.first;
        for (var doc in chats.docs) {
          await _firestore.doc('chatBase/${doc.id}').update({
            'parties': FieldValue.arrayRemove([userId]),
          });
        }
      }
    }
  }

  @override
  Future<void> makeAdmin(String groupId, String userId) async {
    var groupDoc = _firestore.doc('groupBase/$groupId');
    var groupSnap = await groupDoc.snapshots().first;
    GroupEntity group = GroupEntity.fromDocumentSnapshot(groupSnap);
    var me = group.groupMembers.where((m) => m.uid == userId).first;
    group.groupMembers.remove(me);

    var newMe = GroupMember(
      uid: me.uid,
      groupAdmin: true,
      image: me.image,
      fullName: me.fullName,
      tokenID: me.tokenID,
    );

    group.groupMembers.add(newMe);

    await groupDoc.update(group.toJson());
  }
}
