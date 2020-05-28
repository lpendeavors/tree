import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
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

    await _updateUserData(
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

    await _updateUserData(
      user.uid,
      <String, dynamic>{
        'joined': FieldValue.serverTimestamp(),
        'phone': user.phoneNumber,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'password': password
      }
    );

    print('[USER_REPO] registerWithPhone firebaseUser=$user');
  }

  Future<void> _updateUserData(String uid, [Map<String, dynamic> addition]) {
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
  Stream<List<UserEntity>> getConnections() {
    return _firestore
      .collection('userBase')
      .where('isChurch', isEqualTo: false)
      .limit(50)
      .orderBy('time', descending: true)
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
  Stream<List<UserEntity>> getMyConnections(
    List<String> connections
  ) {
    return _firestore
      .collection('userBase')
      .where('docId', whereIn: connections)
      .snapshots()
      .map(_toEntities);
  }
}