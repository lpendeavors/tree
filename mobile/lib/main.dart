import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import './app/app_locale_bloc.dart';
import './user_bloc/user_bloc.dart';
import './app/app.dart';
import './bloc/bloc_provider.dart';
import './data/user/firestore_user_repository_imp.dart';
import './data/post/firestore_post_repository_impl.dart';
import './data/room/firestore_room_repository_impl.dart';
import './data/notification/firestore_notification_repository_impl.dart';
import './data/event/firestore_event_repository_impl.dart';
import './data/group/firestore_group_repository_impl.dart';
import './data/chat/firestore_chat_repository_impl.dart';
import './data/comment/firestore_comment_repository_impl.dart';
import './data/request/firestore_request_repository_impl.dart';
import './data/report/firestore_report_repository_impl.dart';
import './dependency_injection.dart';
import './shared_pref_util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;
  final crashlytics = FirebaseCrashlytics.instance;
  final firebaseAuth = FirebaseAuth.instance;
  final firebaseStorage = FirebaseStorage.instance;
  final sharedPrefUtil = SharedPrefUtil.instance;

  ///
  /// Setup firestore
  ///
  // await firestore.enablePersistence();

  ///
  /// Setup crashlytics
  ///
  FlutterError.onError = crashlytics.recordFlutterError;

  final userRepository = FirestoreUserRepositoryImpl(firebaseAuth, firestore);
  final postRepository =
      FirestorePostRepositoryImpl(firestore, firebaseStorage);
  final roomRepository = FirestoreRoomRepositoryImpl(firestore);
  final notificationRepository = FirestoreNotificationRepositoryImpl(firestore);
  final eventRepository =
      FirestoreEventRepositoryImpl(firestore, firebaseStorage);
  final chatRepository = FirestoreChatRepositoryImpl(firestore);
  final groupRepository =
      FirestoreGroupRepositoryImpl(firestore, firebaseStorage);
  final commentRepository = FirestoreCommentRepositoryImpl(firestore);
  final requestReposirory = FirestoreRequestRepositoryImpl(firestore);
  final reportRepository = FirestoreReportRepositoryImpl(firestore);
  final userBloc = UserBloc(userRepository);

  // runZoned(() {
  runApp(
    Injector(
      userRepository: userRepository,
      postRepository: postRepository,
      notificationRepository: notificationRepository,
      eventRepository: eventRepository,
      roomRepository: roomRepository,
      chatRepository: chatRepository,
      groupRepository: groupRepository,
      commentRepository: commentRepository,
      requestRepository: requestReposirory,
      reportRepository: reportRepository,
      child: BlocProvider<UserBloc>(
        bloc: userBloc,
        child: BlocProvider<LocaleBloc>(
          bloc: LocaleBloc(sharedPrefUtil),
          child: MyApp(),
        ),
      ),
    ),
  );
  // }, onError: crashlytics.recordFlutterError);
}
