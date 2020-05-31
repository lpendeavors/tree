import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import '../../models/old/user_preview_entity.dart';
import 'package:tuple/tuple.dart';
import '../../models/old/user_entity.dart';

abstract class FirestoreUserRepository {
  Stream<UserEntity> user();

  Stream<List<UserEntity>> get();

  Stream<List<UserEntity>> getSuggestionsByCity({
    @required String city,
  });

  Stream<List<UserEntity>> getSuggestionsByChurch({
    @required String church,
  });

  Stream<List<UserEntity>> getMyConnections(
    List<String> connections
  );

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
    @required FirebaseUser user,
    @required String email,
    @required String firstName,
    @required String lastName,
    @required String password
  });

  Future<void> sendPasswordResetEmail(String email);

  Stream<UserEntity> getUserById({
    @required String uid
  });

  Stream<List<UserPreviewEntity>> getUserConnections({
    @required String uid
  });
  
  Future<void> saveNotifications({
    @required String user,
    @required bool messages,
    @required bool chat,
    @required bool group,
    @required bool online,
  });
}