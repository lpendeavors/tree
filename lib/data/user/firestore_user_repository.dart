import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';
import '../../models/user_entity.dart';

abstract class FirestoreUserRepository {
  Stream<UserEntity> user();

  Stream<List<UserEntity>> get();

  Future<void> signOut();

  Future<void> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  });

  Future<Tuple2<String,bool>> phoneSignIn(
    String phone
  );

  Future<AuthResult> verifyPhoneCode(
    String verificationId,
    String smsCode,
  );

  Future<void> registerWithEmail({
    @required String fullName,
    @required String email,
    @required String password,
  });

  Future<void> registerWithPhone({
    @required String uid,
    @required String phone,
  });

  Future<void> sendPasswordResetEmail(String email);

  Stream<UserEntity> getUserById({@required String uid});
}