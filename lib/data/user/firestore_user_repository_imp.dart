import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treeapp/pages/perform_search/perform_search_state.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../models/old/user_entity.dart';
import '../../models/old/user_preview_entity.dart';

class FirestoreUserRepositoryImpl implements FirestoreUserRepository {
  final FirebaseAuth _firebaseAuth;
  final Firestore _firestore;

  const FirestoreUserRepositoryImpl(
    this._firebaseAuth,
    this._firestore,
  );

  @override
  Stream<UserEntity> getUserById({String uid}) => _getUserByUid$(uid);

  @override
  Stream<List<UserPreviewEntity>> getUserConnections({String uid}) => _getUserConnections$(uid);

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
    return querySnapshot.documents.map((documentSnapshot) {
      return UserEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }

  @override
  Future<void> registerWithEmail({
    String fullName,
    String email,
    String password
  }) async {
    if (fullName == null) return Future.error('fullName must not be null');
    if (email == null) return Future.error('email must not be null');
    if (password == null) return Future.error('password must not be null');
    print(
      '[USER_REPO] registerWithEmail fullName=$fullName, email=$email, password=$password'
    );

    var result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    var firebaseUser = result.user;

    await updateUserData(
      firebaseUser.uid,
      <String, dynamic>{
        'joined': FieldValue.serverTimestamp(),
        'firstName': firebaseUser.displayName.split(' ')[0],
        'lastName': firebaseUser.displayName.split(' ').length > 1 ? firebaseUser.displayName.split(' ')[1] : '',
        'email': email
      },
    );

    print('[USER_REPO] registerWithEmail firebaseUser=$firebaseUser');
  }

  @override
  Future<void> registerWithPhone({
    FirebaseUser user,
    String email,
    String firstName,
    String lastName,
    String password
  }) async {
    print('[USER_REPO] registerWithPhone phone=${user.phoneNumber}');
    AuthCredential emailCredential = EmailAuthProvider.getCredential(email: email, password: password);
    user.linkWithCredential(emailCredential);



    await updateUserData(
      user.uid,
      UserEntity.createWith({
        'joined': FieldValue.serverTimestamp(),
        'phoneNo': user.phoneNumber,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
        'fullName': "$firstName $lastName",
        'uid': user.uid
      })
    );

    print('[USER_REPO] registerWithPhone firebaseUser=$user');
  }

  @override
  Future<void> updateUserData(String uid, [Map<String, dynamic> addition]) {
    return _firestore.document('userBase/$uid').setData(addition, merge: true);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    if (email == null) return Future.error('Email must not be null');
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signInWithEmailAndPassword({String email, String password}) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password
    );
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Stream<UserEntity> user() {
    return _firebaseAuth.onAuthStateChanged
      .switchMap((user) => _getUserByUid$(user?.uid));
  }

  Stream<UserEntity> _getUserByUid$(String uid) {
    if (uid == null) {
      return null;
    }
    return _firestore.collection('userBase').document(uid).snapshots().map(
      (snapshot) => snapshot.exists ? UserEntity.fromDocumentSnapshot(snapshot) : null);
  }

  Stream<List<UserPreviewEntity>> _getUserConnections$(String uid) {
    if (uid == null) {
      return null;
    }
    return _firestore.collection('userBase')
        .document(uid)
        .snapshots()
        .asyncMap((snapshot) {
          return Future.wait((snapshot.data['connections'] as List<dynamic>).map((uid){
            return _firestore.collection('userBase').document(uid).get().then((snapshot) => snapshot.exists ? UserPreviewEntity.fromDocumentSnapshot(snapshot) : null);
          }));
        });
  }

  @override
  Future<Tuple2<String,bool>> phoneSignIn(String phone) async {
    var completer = Completer<Tuple2<String,bool>>();

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: Duration(seconds: 60),
      verificationCompleted: (phoneAuthCredential) => completer.complete(Tuple2(null, true)),
      verificationFailed: (authException) => completer.completeError(authException.message),
      codeSent: (s, [x]) => completer.complete(Tuple2(s, false)),
      codeAutoRetrievalTimeout: (timeout) => print(timeout),
    ).catchError((error) => Future.error(error));

    return completer.future;
  }

  @override
  Future<AuthResult> verifyPhoneCode(
    String smsCode,
    String verificationId
  ) async {
    AuthCredential credential = PhoneAuthProvider
      .getCredential(verificationId: verificationId, smsCode: smsCode);

    return _firebaseAuth.signInWithCredential(credential)
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
    bool online
  }) {
    var addition = <String, dynamic>{
      'messageNotification': messages,
      'chatNotification': chat,
      'groupNotification': group,
      'chatOnlineStatus': online,
    };

    return _firestore
      .document('userBase/$user')
      .setData(addition, merge: true);
  }

  @override
  Future<void> sendConnectionRequest(String from, String to) {
    return _firestore.document('userBase/$from').updateData({
      'sentRequests': FieldValue.arrayUnion([to])
    }).then((value){
      return _firestore.document('userBase/$to').updateData({
        'receivedRequests': FieldValue.arrayUnion([from])
      });
    });
  }

  @override
  Future<void> cancelConnectionRequest(String from, String to) {
    return _firestore.document('userBase/$from').updateData({
      'sentRequests': FieldValue.arrayRemove([to])
    }).then((value){
      return _firestore.document('userBase/$to').updateData({
        'receivedRequests': FieldValue.arrayRemove([from])
      });
    });
  }

  @override
  Future<void> acceptConnectionRequest(String from, String to) {
    return _firestore.document('userBase/$to').updateData({
      'receivedRequests': FieldValue.arrayRemove([from]),
      'connections': FieldValue.arrayUnion([from])
    }).then((value){
      return _firestore.document('userBase/$from').updateData({
        'sentRequests': FieldValue.arrayRemove([to]),
        'connections': FieldValue.arrayUnion([to])
      });
    });
  }

  @override
  Future<void> disconnect(String from, String to) {
    return _firestore.document('userBase/$from').updateData({
      'connections': FieldValue.arrayRemove([to])
    }).then((value){
      return _firestore.document('userBase/$to').updateData({
        'connections': FieldValue.arrayRemove([from])
      });
    });
  }

  @override
  Future<void> uploadImage(String uid, File image) {
    var refId = new Uuid().v1();
    StorageReference storageReference = FirebaseStorage.instance.ref().child(refId);
    StorageUploadTask uploadTask = storageReference.putFile(image);
    return uploadTask.onComplete.then((value) => value.ref.getDownloadURL()).then((url){
      _firestore.document('userBase/$uid').updateData({
        'image': url
      });
    });
  }

  @override
  Future<void> approveAccount(String uid) {
    return _firestore.document('userBase/$uid').updateData({
      'isVerified': true
    });
  }
  
  Stream<List<UserEntity>> getMyConnections(
    List<String> connections
  ) {
    return _firestore
      .collection('userBase')
      .where('docId', whereIn: connections)
      .snapshots()
      .map(_toEntities);
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
      FirebaseUser user,
      String smsCode,
      String verificationId
  ) async {
    var credential = PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: smsCode);
    return await user.updatePhoneNumberCredential(credential);
  }

  @override
  Future<List<UserEntity>> runSearchQuery(String query) {
    print('impl');
    return _firestore
        .collection('userBase')
        .where('searchData', arrayContains: query)
        .where('isChurch', isEqualTo: true)
        .limit(30)
        .getDocuments()
        .then(_toEntities);
  }
}