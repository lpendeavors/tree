import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './app/app_locale_bloc.dart';
import './user_bloc/user_bloc.dart';
import './app/app.dart';
import './bloc/bloc_provider.dart';
import './data/user/firestore_user_repository_imp.dart';
import './dependency_injection.dart';
import './shared_pref_util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firestore = Firestore.instance;
  final firebaseAuth = FirebaseAuth.instance;
  final sharedPrefUtil = SharedPrefUtil.instance;

  ///
  /// Setup firestore
  ///
  await firestore.settings(persistenceEnabled: true);

  final userRepository = FirestoreUserRepositoryImpl(firebaseAuth, firestore);
  final userBloc = UserBloc(userRepository);

  runApp(
    Injector(
        userRepository: userRepository,
        child: BlocProvider<UserBloc>(
          bloc: userBloc,
          child: BlocProvider<LocaleBloc>(
            bloc: LocaleBloc(sharedPrefUtil),
            child: MyApp(),
          ),
        ),
    ),
  );
}