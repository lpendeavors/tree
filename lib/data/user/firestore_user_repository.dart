import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:treeapp/pages/perform_search/perform_search_page.dart';
import 'package:treeapp/pages/perform_search/perform_search_state.dart';
import '../../models/old/user_preview_entity.dart';
import 'package:tuple/tuple.dart';
import '../../models/old/user_entity.dart';

abstract class FirestoreUserRepository {
  Stream<UserEntity> user();

  List<UserEntity> users(
    List<String> uids,
  );

  Stream<List<UserEntity>> get();

  Stream<List<UserEntity>> getSuggestionsByCity({
    @required String city,
  });

  Stream<List<UserEntity>> getSuggestionsByChurch({
    @required String church,
  });

  Stream<List<UserEntity>> getMyConnections(List<String> connections);

  Future<void> signOut();

  Future<void> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  });

  Future<Tuple2<String, bool>> phoneSignIn(String phone);

  Future<Tuple2<String, bool>> phoneRegister(String phone);

  Future<AuthResult> verifyPhoneCode(
    String verificationId,
    String smsCode,
  );

  Future<void> registerWithEmail({
    @required String fullName,
    @required String email,
    @required String password,
  });

  Future<void> registerWithPhone(
      {@required FirebaseUser user,
      @required String email,
      @required String churchName,
      @required String firstName,
      @required String lastName,
      @required String password});

  Future<void> updateUserData(String uid, [Map<String, dynamic> addition]);

  Future<void> updateUserPhone(
      @required FirebaseUser user, String smsCode, String verificationId);

  Future<void> sendPasswordResetEmail(String email);

  Stream<UserEntity> getUserById({@required String uid});

  Stream<List<UserPreviewEntity>> getUserConnections({@required String uid});

  Future<void> sendConnectionRequest(String from, String to);

  Future<void> cancelConnectionRequest(String from, String to);

  Future<void> acceptConnectionRequest(String from, String to);

  Future<void> disconnect(String from, String to);

  Future<void> uploadImage(String uid, File image);

  Future<void> approveAccount(String uid);

  Future<void> saveNotifications({
    @required String user,
    @required bool messages,
    @required bool chat,
    @required bool group,
    @required bool online,
  });

  Stream<List<UserEntity>> getPublicFigures();

  Future<List<UserEntity>> runSearchQuery(String query, SearchType type);
}
