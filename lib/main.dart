import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
import './dependency_injection.dart';
import './shared_pref_util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firestore = Firestore.instance;
  final crashlytics = Crashlytics.instance;
  final firebaseAuth = FirebaseAuth.instance;
  final sharedPrefUtil = SharedPrefUtil.instance;

  ///
  /// Setup firestore
  ///
  await firestore.settings(persistenceEnabled: false);

  ///
  /// Setup crashlytics
  ///
  crashlytics.enableInDevMode = true;
  FlutterError.onError = crashlytics.recordFlutterError;

  final userRepository = FirestoreUserRepositoryImpl(firebaseAuth, firestore);
  final postRepository = FirestorePostRepositoryImpl(firestore);
  final roomRepository = FirestoreRoomRepositoryImpl(firestore);
  final notificationRepository = FirestoreNotificationRepositoryImpl(firestore);
  final eventRepository = FirestoreEventRepositoryImpl(firestore);
  final userBloc = UserBloc(userRepository);

  // runZoned(() {
    runApp(
      Injector(
        userRepository: userRepository,
        postRepository: postRepository,
        notificationRepository: notificationRepository,
        eventRepository: eventRepository,
        roomRepository: roomRepository,
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