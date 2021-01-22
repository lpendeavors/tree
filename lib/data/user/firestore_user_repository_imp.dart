import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treeapp/pages/perform_search/perform_search_page.dart';
import 'package:treeapp/util/asset_utils.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../models/old/user_entity.dart';
import '../../models/old/user_preview_entity.dart';
import '../../notification_util.dart';
import '../../util/model_utils.dart';

class FirestoreUserRepositoryImpl implements FirestoreUserRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  const FirestoreUserRepositoryImpl(
    this._firebaseAuth,
    this._firestore,
  );

  @override
  Stream<UserEntity> getUserById({String uid}) => _getUserByUid$(uid);

  @override
  Stream<List<UserEntity>> get() {
    return _firestore
        .collection('userBase')
        .where('isChurch', isEqualTo: false)
        //.orderBy('time', descending: true)
        .limit(50)
        .snapshots()
        .map(_toEntities);
  }

  List<UserEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((documentSnapshot) {
      return UserEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }

  @override
  Future<void> registerWithEmail(
      {String fullName, String email, String password}) async {
    if (fullName == null) return Future.error('fullName must not be null');
    if (email == null) return Future.error('email must not be null');
    if (password == null) return Future.error('password must not be null');
    print(
        '[USER_REPO] registerWithEmail fullName=$fullName, email=$email, password=$password');

    var result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    var firebaseUser = result.user;

    await updateUserData(
      firebaseUser.uid,
      <String, dynamic>{
        'joined': FieldValue.serverTimestamp(),
        'firstName': firebaseUser.displayName.split(' ')[0],
        'lastName': firebaseUser.displayName.split(' ').length > 1
            ? firebaseUser.displayName.split(' ')[1]
            : '',
        'email': email
      },
    );

    print('[USER_REPO] registerWithEmail firebaseUser=$firebaseUser');
  }

  @override
  Future<void> registerWithPhone({
    User user,
    String email,
    String churchName,
    String firstName,
    String lastName,
    String password,
  }) async {
    print('[USER_REPO] registerWithPhone phone=${user.phoneNumber}');
    AuthCredential emailCredential =
        EmailAuthProvider.credential(email: email, password: password);
    user.linkWithCredential(emailCredential);

    var userData = UserEntity.createWith({
      'joined': FieldValue.serverTimestamp(),
      'phoneNo': user.phoneNumber,
      'email': email,
      'churchName': churchName == '' ? null : churchName,
      'isChurch': churchName == '' ? false : true,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      'fullName': "$firstName $lastName",
      'uid': user.uid,
      'searchData': createSearchData(
          churchName == '' ? '$firstName $lastName' : churchName),
    });

    if (churchName != null && churchName.isNotEmpty) {
      userData.addAll({
        'status': 0,
      });
    }

    await updateUserData(
      user.uid,
      userData,
    );

    if (!(churchName == '')) {
      var churchRoom = <String, dynamic>{
        'groupName': churchName,
        'byAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
        'groupMembers': [
          <String, dynamic>{
            'fullName': churchName,
            'uid': user.uid,
            'image': '',
            'groupAdmin': true,
          }
        ],
        'parties': [user.uid],
        'isConversation': true,
        'isGroup': true,
        'isGroupPrivate': true,
        'isRoom': true,
        'isVerified': false,
        'ownerId': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
        'searchData': createSearchData(churchName),
      };

      await _firestore
          .collection('groupBase')
          .doc('${user.uid}')
          .set(churchRoom);
    }

    print('[USER_REPO] registerWithPhone firebaseUser=$user');
  }

  @override
  Future<void> updateUserData(String uid, [Map<String, dynamic> addition]) {
    return _firestore
        .doc('userBase/$uid')
        .set(addition, SetOptions(merge: true));
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    if (email == null) return Future.error('Email must not be null');
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signInWithEmailAndPassword({String email, String password}) {
    return _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Stream<UserEntity> user() {
    return _firebaseAuth
        .authStateChanges()
        .switchMap((user) => _getUserByUid$(user?.uid));
  }

  Stream<UserEntity> _getUserByUid$(String uid) {
    if (uid == null) {
      return null;
    }
    return _firestore.collection('userBase').doc(uid).snapshots().map(
        (snapshot) =>
            snapshot.exists ? UserEntity.fromDocumentSnapshot(snapshot) : null);
  }

  @override
  Future<Tuple2<String, bool>> phoneSignIn(String phone) async {
    var completer = Completer<Tuple2<String, bool>>();

    await _firebaseAuth
        .verifyPhoneNumber(
          phoneNumber: phone,
          timeout: Duration(seconds: 60),
          verificationCompleted: (phoneAuthCredential) =>
              completer.complete(Tuple2(null, true)),
          verificationFailed: (authException) =>
              completer.completeError(authException.message),
          codeSent: (s, [x]) => completer.complete(Tuple2(s, false)),
          codeAutoRetrievalTimeout: (timeout) => print(timeout),
        )
        .catchError((error) => Future.error(error));

    return completer.future;
  }

  @override
  Future<Tuple2<String, bool>> phoneRegister(String phone) async {
    var completer = Completer<Tuple2<String, bool>>();

    var exists = await _firestore
        .collection('userBase')
        .where('phoneNo',
            isEqualTo: phone
                .replaceAll(" ", "")
                .replaceAll("-", "")
                .replaceAll("(", "")
                .replaceAll(")", ""))
        .limit(1)
        .get()
        .then((value) => value.docs.length > 0);

    if (exists) {
      Timer(Duration(milliseconds: 100), () {
        completer.completeError("already_in_use");
      });
      return completer.future;
    }

    await _firebaseAuth
        .verifyPhoneNumber(
          phoneNumber: phone,
          timeout: Duration(seconds: 60),
          verificationCompleted: (phoneAuthCredential) =>
              completer.complete(Tuple2(null, true)),
          verificationFailed: (authException) =>
              completer.completeError(authException.message),
          codeSent: (s, [x]) => completer.complete(Tuple2(s, false)),
          codeAutoRetrievalTimeout: (timeout) => print(timeout),
        )
        .catchError((error) => Future.error(error));

    return completer.future;
  }

  @override
  Future<UserCredential> verifyPhoneCode(
      String smsCode, String verificationId) async {
    AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);

    return _firebaseAuth
        .signInWithCredential(credential)
        .catchError((error) => Future.error(error));
  }

  @override
  Stream<List<UserEntity>> getSuggestionsByCity({
    String city,
  }) {
    return _firestore
        .collection('userBase')
        .where('isChurch', isEqualTo: false)
        .where('city', isEqualTo: city)
        .limit(50)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Stream<List<UserEntity>> getSuggestionsByChurch({
    String church,
  }) {
    return _firestore
        .collection('userBase')
        .where('churchInfo.churchName', isEqualTo: church)
        .limit(50)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Future<void> saveNotifications({
    String user,
    bool messages,
    bool chat,
    bool group,
    bool online,
  }) {
    var addition = <String, dynamic>{
      'messageNotification': messages,
      'chatNotification': chat,
      'groupNotification': group,
      'chatOnlineStatus': online,
    };

    return _firestore
        .doc('userBase/$user')
        .set(addition, SetOptions(merge: true));
  }

  @override
  Future<void> sendConnectionRequest(String from, String to) async {
    var toUser = await _firestore.doc('userBase/$to').snapshots().first;
    var toEntity = UserEntity.fromDocumentSnapshot(toUser);

    var fromUser = await _firestore.doc('userBase/$from').snapshots().first;
    var fromEntity = UserEntity.fromDocumentSnapshot(fromUser);
    var fromName =
        fromEntity.isChurch ? fromEntity.churchName : fromEntity.fullName;

    final TransactionHandler transactionHandler = (transaction) async {
      final notification = <String, dynamic>{
        'title': 'New Request',
        'fullName': fromName,
        'body': 'accepted your friend request',
        'image': toEntity.image,
        'ownerId': toEntity.id,
        'message': '$fromName accepted your friend request'
      };

      // NotificationService.sendPlainPush(
      //   title: 'New request',
      //   body: '$fromName sent you a friend request',
      //   token: toEntity.pushNotificationToken,
      //   image: fromEntity.image,
      // );

      // _firestore.collection('notificationBase').add(notification);

      _firestore.doc('userBase/$from').update({
        'sentRequests': FieldValue.arrayUnion([to])
      });

      _firestore.doc('userBase/$to').update({
        'receivedRequests': FieldValue.arrayUnion([from])
      });
    };

    return _firestore.runTransaction(transactionHandler).then((_) {
      print('done');
    });
  }

  @override
  Future<void> cancelConnectionRequest(String from, String to) {
    return _firestore.doc('userBase/$from').update({
      'sentRequests': FieldValue.arrayRemove([to])
    }).then((value) {
      return _firestore.doc('userBase/$to').update({
        'receivedRequests': FieldValue.arrayRemove([from])
      });
    });
  }

  @override
  Future<void> acceptConnectionRequest(String from, String to) async {
    var toUser = await _firestore.doc('userBase/$to').snapshots().first;
    var toEntity = UserEntity.fromDocumentSnapshot(toUser);

    var fromUser = await _firestore.doc('userBase/$from').snapshots().first;
    var fromEntity = UserEntity.fromDocumentSnapshot(fromUser);
    var fromName =
        fromEntity.isChurch ? fromEntity.churchName : fromEntity.fullName;

    final TransactionHandler transactionHandler = (transaction) async {
      final notification = <String, dynamic>{
        'title': 'Friend Request',
        'fullName': fromName,
        'body': 'sent you a friend request',
        'image': fromEntity.image,
        'ownerId': toEntity.id,
        'message': '$fromName sent you a friend request',
        'tokenId': toEntity.id,
      };

      // NotificationService.sendPlainPush(
      //   title: 'New request',
      //   body: '$fromName sent you a friend request',
      //   token: toEntity.pushNotificationToken,
      //   image: fromEntity.image,
      // );

      // _firestore.collection('notificationBase').add(notification);

      _firestore.doc('userBase/$to').update({
        'receivedRequests': FieldValue.arrayRemove([from]),
        'connections': FieldValue.arrayUnion([from])
      });

      _firestore.doc('userBase/$from').update({
        'sentRequests': FieldValue.arrayRemove([to]),
        'connections': FieldValue.arrayUnion([to])
      });
    };

    await _firestore.runTransaction(transactionHandler);
  }

  @override
  Future<void> disconnect(String from, String to) {
    return _firestore.doc('userBase/$from').update({
      'connections': FieldValue.arrayRemove([to])
    }).then((value) {
      return _firestore.doc('userBase/$to').update({
        'connections': FieldValue.arrayRemove([from])
      });
    });
  }

  @override
  Future<void> uploadImage(String uid, File image) {
    var refId = new Uuid().v1();
    Reference storageReference = FirebaseStorage.instance.ref().child(refId);
    UploadTask uploadTask = storageReference.putFile(image);
    return uploadTask.then((value) => value.ref.getDownloadURL()).then((url) {
      _firestore.doc('userBase/$uid').update({'image': url});
    });
  }

  @override
  Future<void> approveAccount(String uid) {
    return _firestore.doc('userBase/$uid').update({'isVerified': true});
  }

  Stream<List<UserEntity>> getMyConnections(List<String> connections) async* {
    List<UserEntity> users = List();
    for (var id in connections) {
      var connection =
          await _firestore.collection('userBase').doc(id).snapshots().first;

      if (connection.exists)
        users.add(UserEntity.fromDocumentSnapshot(connection));
    }

    yield* Stream.value(users);
  }

  @override
  Stream<List<UserEntity>> getPublicFigures() {
    return _firestore
        .collection('userBase')
        .where('isVerified', isEqualTo: true)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Future<void> updateUserPhone(
      User user, String smsCode, String verificationId) async {
    var credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    return await user.linkWithCredential(credential);
  }

  @override
  Future<List<UserEntity>> runSearchQuery(String query, SearchType searchType) {
    print(query);
    if (searchType == SearchType.CHURCH) {
      return _firestore
          .collection('userBase')
          .where('searchData', arrayContains: query)
          .where('isChurch', isEqualTo: true)
          .limit(30)
          .get()
          .then(_toEntities);
    } else if (searchType == SearchType.USERS) {
      return _firestore
          .collection('userBase')
          .where('searchData', arrayContains: query)
          .limit(30)
          .get()
          .then(_toEntities);
    }
  }

  @override
  List<UserEntity> users(
    List<String> uids,
  ) {
    var entities = <UserEntity>[];
    uids.forEach((id) async {
      var user =
          await _firestore.collection('userBase').doc(id).snapshots().first;
      entities.add(UserEntity.fromDocumentSnapshot(user));
    });

    return entities;
  }

  @override
  Future<void> removeConnection(String uid, String userId) {
    return _firestore.collection('userBase').doc(uid).update({
      'connections': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Stream<List<UserEntity>> getPending() {
    return _firestore
        .collection('userBase')
        .where('status', isEqualTo: 0)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Future<void> saveApproval(
    String userId,
    bool approved,
    String userToken,
    String userImage,
  ) {
    if (approved) {
      return _firestore.collection('userBase').doc(userId).update({
        'isVerified': true,
        'status': 1,
      });
    } else {
      return _firestore.collection('userBase').doc(userId).update({
        'status': 3,
        'reason': '',
      });
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    await _firestore.doc('userBase/$userId').update({
      'isDeleted': true,
    });
  }

  @override
  Future<void> suspendUser(String userId) async {
    await _firestore.doc('userBase/$userId').update({
      'isSuspended': true,
    });
  }

  @override
  Future<void> mute(
    String uid,
    String id,
  ) {
    return _firestore.doc('userBase/$uid').update({
      'muted': FieldValue.arrayUnion([id]),
    });
  }

  @override
  Future<void> toggleAdmin(bool admin, String user) async {
    print(admin);
    print(user);
    await _firestore.doc('userBase/$user').update({
      'isAdmin': admin,
    }).then((value) => print('saved?'));
  }

  @override
  Future<void> updateToken(String userId, String token) async {
    await _firestore.doc('userBase/$userId').update({
      'pushNotificationToken': token,
    });
  }

  @override
  Stream<List<UserEntity>> getConnections(String userId) async* {
    var userDoc = await _firestore.doc('userBase/$userId').snapshots().first;
    var user = UserEntity.fromDocumentSnapshot(userDoc);

    List<UserEntity> users = List();
    for (var id in user.connections) {
      var connection =
          await _firestore.collection('userBase').doc(id).snapshots().first;

      if (connection.exists)
        users.add(UserEntity.fromDocumentSnapshot(connection));
    }

    yield* Stream.value(users);
  }
}
