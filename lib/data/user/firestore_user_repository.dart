import 'dart:async';

import 'package:meta/meta.dart';
import '../../models/user_entity.dart';

abstract class FirestoreUserRepository {
  Stream<UserEntity> user();

  Future<void> signOut();

  Future<void> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  });

  Future<String> phoneSignIn(
    String phone
  );

  Future<void> verifyPhoneCode(
    String verificationId,
    String smsCode,
  );

  Future<void> registerWithEmail({
    @required String fullName,
    @required String email,
    @required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Stream<UserEntity> getUserById({@required String uid});
}