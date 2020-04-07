import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
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
  Future<void> phoneSignIn(
    String phone,
    Duration timeout,
    PhoneVerificationCompleted completed,
    PhoneVerificationFailed failed,
    PhoneCodeSent sent,
    PhoneCodeAutoRetrievalTimeout codeTimeout,
  ) => _firebaseAuth.verifyPhoneNumber(
    phoneNumber: null,
    timeout: null,
    verificationCompleted: null,
    verificationFailed: null,
    codeSent: null,
    codeAutoRetrievalTimeout: null);

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
      firebaseUser,
      <String, dynamic>{
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
    );

    print('[USER_REPO] registerWithEmail firebaseUser=$firebaseUser');
  }

  Future<void> _updateUserData(FirebaseUser user, [Map<String, dynamic> addition]) {
    final data = <String, dynamic> {
      'email': user.email,
      'full_name': user.displayName
    };

    data.addAll(addition);

    print('[USER_REPO] _updateUserData data=$data');

    return _firestore.document('user/${user.uid}').setData(data, merge: true);
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
    return _firestore.document('users/$uid').snapshots().map(
        (snapshot) => snapshot.exists ? UserEntity.fromDocumentSnapshot(snapshot) : null);
  }
}