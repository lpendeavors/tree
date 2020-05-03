import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../models/user_entity.dart';

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
  Stream<List<UserEntity>> get() {
    return _firestore
      .collection('(users)')
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
    String phone,
    String uid
  }) async {
    print(
        '[USER_REPO] registerWithPhone phone=${phone}'
    );

    await _updateUserData(
      uid,
      <String, dynamic>{
        'joined': FieldValue.serverTimestamp(),
        'phone': phone
      }
    );

    print('[USER_REPO] registerWithPhone firebaseUser=$user');
  }

  Future<void> _updateUserData(String uid, [Map<String, dynamic> addition]) {
    return _firestore.document('(users)/${uid}').setData(addition, merge: true);
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
    return _firestore.collection('(users)').document(uid).snapshots().map(
        (snapshot) => snapshot.exists ? UserEntity.fromDocumentSnapshot(snapshot) : null);
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
}