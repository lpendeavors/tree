import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import '../../models/user_entity.dart';

abstract class FirestoreUserRepository {
  Stream<UserEntity> user();

  Future<void> signOut();

  Future<void> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  });

  Future<void> phoneSignIn(
    String phone,
    Duration timeout,
    PhoneVerificationCompleted completed,
    PhoneVerificationFailed failed,
    PhoneCodeSent sent,
    PhoneCodeAutoRetrievalTimeout codeTimeout,
  );

  Future<void> registerWithEmail({
    @required String fullName,
    @required String email,
    @required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Stream<UserEntity> getUserById({@required String uid});
}