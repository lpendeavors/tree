import 'dart:async';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import './app_locale_bloc.dart';
import '../bloc/bloc_provider.dart';
import '../dependency_injection.dart';
import '../pages/login/login_page.dart';
import '../pages/register/register_page.dart';
import '../pages/getting_started/getting_started_page.dart';
import '../pages/phone_verification/phone_verification_page.dart';
import '../pages/phone_verification/phone_verification_bloc.dart';
import '../pages/home_tabs/home_tabs_page.dart';
import '../pages/notifications/notifications_page.dart';
import '../pages/notifications/notifications_bloc.dart';
import '../pages/events/events_tabs_page.dart';
import '../pages/events/events_bloc.dart';
import '../pages/event_types/event_types_page.dart';
import '../pages/event_details/event_details_page.dart';
import '../pages/event_details/event_details_bloc.dart';
import '../pages/event_edit/event_edit_page.dart';
import '../pages/event_edit/event_edit_bloc.dart';
import '../pages/explore/explore_tabs_page.dart';
import '../user_bloc/user_bloc.dart';
import '../user_bloc/user_login_state.dart';

class MyApp extends StatelessWidget {
  final appTheme = ThemeData(
    primarySwatch: Colors.green,
    primaryColor: Color(0xFF6CA748),
  );

  final appRoutes = <String, WidgetBuilder>{
    '/': (context) {
      return HomeTabsPage(
        userBloc: BlocProvider.of<UserBloc>(context),
        postRepository: Injector.of(context).postRepository,
        userRepository: Injector.of(context).userRepository,
      );
    },
    '/login': (context) {
      return LoginPage(
        userBloc: BlocProvider.of<UserBloc>(context),
        userRepository: Injector.of(context).userRepository,
      );
    },
    '/register': (context) {
      return RegisterPage(
        userBloc: BlocProvider.of<UserBloc>(context),
        userRepository: Injector.of(context).userRepository,
      );
    },
    '/getting_started': (context) {
      return GettingStartedPage(
        userBloc: BlocProvider.of<UserBloc>(context),
      );
    },
    '/notifications': (context) {
      return NotificationsPage(
        userBloc: BlocProvider.of<UserBloc>(context),
        notificationsBloc: NotificationsBloc(
          userBloc: BlocProvider.of<UserBloc>(context),
          notificationRepository: Injector.of(context).notificationRepository,
        ),
      );
    },
    '/events': (context) {
      return EventsTabsPage(
        userBloc: BlocProvider.of<UserBloc>(context),
        eventsBloc: EventsBloc(
          userBloc: BlocProvider.of<UserBloc>(context),
          eventRepository: Injector.of(context).eventRepository,
        ),
      );
    },
    '/event_types': (context) {
      return EventTypesPage();
    },
  };

  final RouteFactory onGenerateRoute = (routerSettings) {
    if (routerSettings.name == '/phone_verification') {
      return MaterialPageRoute(
        builder: (context) {
          return PhoneVerificationPage(
            initPhoneVerificationBloc: () {
              return PhoneVerificationBloc(
                userRepository: Injector.of(context).userRepository,
                verificationId: routerSettings.arguments as String,
              );
            },
          );
        },
        settings: routerSettings,
      );
    }

    if (routerSettings.name == '/event_details') {
      return MaterialPageRoute(
        builder: (context) {
          return EventDetailsPage(
            userBloc: BlocProvider.of<UserBloc>(context),
            initEventDetailsBloc: () {
              return EventDetailsBloc(
                userBloc: BlocProvider.of<UserBloc>(context),
                eventRepository: Injector.of(context).eventRepository,
                eventId: routerSettings.arguments as String,
              );
            },
          );
        }
      );
    }

    if (routerSettings.name == '/edit_event') {
      return MaterialPageRoute(
        builder: (context) {
          Map<String, dynamic> args = routerSettings.arguments as Map<String, dynamic>;
          return EventEditPage(
            userBloc: BlocProvider.of<UserBloc>(context),
            initEventEditBloc: () {
              return EventEditBloc(
                userBloc: BlocProvider.of<UserBloc>(context),
                eventRepository: Injector.of(context).eventRepository,
                eventId: args['eventId'],
                eventType: args['eventType'],
              );
            },
            eventType: args['eventType'],
          );
        }
      );
    }
  };

  @override
  Widget build(BuildContext context) {
    final localeBloc = BlocProvider.of<LocaleBloc>(context);

    return StreamBuilder<Locale>(
      stream: localeBloc.locale$,
      initialData: localeBloc.locale$.value,
      builder: (context, snapshot) {
        print('[APP_LOCALE] locale = ${snapshot.data}');

        if (!snapshot.hasData) {
          return Container(
            width: double.infinity,
            height: double.infinity,
          );
        }

        return MaterialApp(
          locale: snapshot.data,
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: [
            S.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
          ],
          onGenerateTitle: (context) => S.of(context).app_title,
          theme: appTheme,
          builder: (BuildContext context, Widget child) {
            print('[DEBUG] App builder');
            return Scaffold(
              body: BodyChild(
                child: child,
                userBloc: BlocProvider.of<UserBloc>(context),
              ),
            );
          },
          initialRoute: '/getting_started',
          routes: appRoutes,
          onGenerateRoute: onGenerateRoute,
        );
      },
    );
  }
}

class BodyChild extends StatefulWidget {
  final Widget child;
  final UserBloc userBloc;

  const BodyChild({
    Key key,
    @required this.child,
    @required this.userBloc,
  }) : super(key: key);

  @override
  _BodyChildState createState() => _BodyChildState();
}

class _BodyChildState extends State<BodyChild> {
  StreamSubscription _subscription;

  @override void initState() {
    super.initState();
    print('[DEBUG] _BodyChildState initState');

    _subscription = widget.userBloc.message$.listen((message) {
      var s = S.of(context);
      if (message is UserLogoutMessage) {
        if (message is UserLogoutMessageSuccess) {
          _showSnackBar(s.logout_success);
        }
        if (message is UserLogoutMessageError) {
          print('[DEBUG] logout error = ${message.error}');
          _showSnackBar(s.logout_error);
        }
      }
    });
  }

  @override
  void dispose() {
    print('[DEBUG] _BodyChildState dispose');
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('[DEBUG] _BodyChildState build');
    return widget.child;
  }

  void _showSnackBar(String message) {
    Scaffold.of(context, nullOk: true)?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}