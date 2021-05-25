import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:treeapp/pages/perform_search/perform_search_page.dart';
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

  Future<UserCredential> verifyPhoneCode(
    String verificationId,
    String smsCode,
  );

  Future<void> registerWithEmail({
    @required String fullName,
    @required String email,
    @required String password,
  });

  Future<void> registerWithPhone({
    @required User user,
    @required String email,
    @required String churchName,
    @required String firstName,
    @required String lastName,
    @required String password,
  });

  Future<void> updateUserData(String uid, [Map<String, dynamic> addition]);

  Future<void> updateUserPhone(
    User user,
    String smsCode,
    String verificationId,
  );

  Future<void> sendPasswordResetEmail(String email);

  Stream<UserEntity> getUserById({@required String uid});

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

  Future<void> removeConnection(
    String uid,
    String userId,
  );

  Stream<List<UserEntity>> getPending();

  Future<void> saveApproval(
    String userId,
    bool approved,
    String userToken,
    String userImage,
  );

  Future<void> suspendUser(String userId);

  Future<void> deleteUser(String userId);

  Future<void> mute(String userId, String id);

  Future<void> toggleAdmin(bool admin, String user);

  Future<void> updateToken(String userId, String token);

  Stream<List<UserEntity>> getConnections(String userId);
}
