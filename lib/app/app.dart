import 'dart:async';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:treeapp/pages/perform_search/perform_search_page.dart';
import 'package:treeapp/pages/settings/settings_state.dart';
import 'package:treeapp/widgets/modals/info_dialog.dart';
import '../pages/settings/profile/profile_settings_bloc.dart';
import '../pages/settings/profile/profile_settings_page.dart';
import '../pages/preview_image/preivew_image_page.dart';
import '../pages/connections/connections_bloc.dart';
import '../pages/connections/connections_page.dart';
import '../pages/trophies/trophies_bloc.dart';
import '../pages/trophies/trophies_page.dart';
import '../pages/trophy_info/trophy_info_bloc.dart';
import '../pages/trophy_info/trophy_info_page.dart';
import '../util/asset_utils.dart';
import '../generated/l10n.dart';
import './app_locale_bloc.dart';
import '../bloc/bloc_provider.dart';
import '../dependency_injection.dart';
import '../pages/splash/splash_page.dart';
import '../pages/login/login_page.dart';
import '../pages/register/register_page.dart';
import '../pages/forgot_password/forgot_password_page.dart';
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
import '../pages/chat_room_details/chat_room_details_page.dart';
import '../pages/chat_room_details/chat_room_details_bloc.dart';
import '../pages/chat_room/chat_room_page.dart';
import '../pages/chat_room/chat_room_bloc.dart';
import '../pages/chat_settings/chat_settings_page.dart';
import '../pages/chat_settings/chat_settings_bloc.dart';
import '../pages/settings/settings_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/profile/profile_bloc.dart';
import '../pages/settings/notifications/notification_settings_page.dart';
import '../pages/post_edit/post_edit_page.dart';
import '../pages/post_edit/post_edit_bloc.dart';
import '../pages/poll_edit/poll_edit_bloc.dart';
import '../pages/poll_edit/poll_edit_page.dart';
import '../pages/create_message/create_message_page.dart';
import '../pages/create_message/create_message_bloc.dart';
import '../pages/create_message/create_message_state.dart';
import '../pages/create_group/create_group_bloc.dart';
import '../pages/create_group/create_group_page.dart';
import '../pages/post_details/post_details_bloc.dart';
import '../pages/post_details/post_details_page.dart';
import '../user_bloc/user_bloc.dart';
import '../user_bloc/user_login_state.dart';

class MyApp extends StatelessWidget {
  final appTheme = ThemeData(
    primarySwatch: Colors.green,
    primaryColor: Color(0xFF6CA748),
    indicatorColor: Color(0xff5c4eb2),
    fontFamily: poppinBold,
  );

  final appRoutes = <String, WidgetBuilder>{
    '/': (context) {
      return HomeTabsPage(
        userBloc: BlocProvider.of<UserBloc>(context),
        postRepository: Injector.of(context).postRepository,
        roomRepository: Injector.of(context).roomRepository,
        userRepository: Injector.of(context).userRepository,
        chatRepository: Injector.of(context).chatRepository,
        groupRepository: Injector.of(context).groupRepository,
        requestRepository: Injector.of(context).requestRepository,
      );
    },
    '/splash': (context) {
      return SplashPage(
        userBloc: BlocProvider.of<UserBloc>(context),
      );
    },
    '/login': (context) {
      return LoginPage(
        userBloc: BlocProvider.of<UserBloc>(context),
        userRepository: Injector.of(context).userRepository,
      );
    },
    '/forgot_password': (context) {
      return ForgotPasswordPage(
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
      return GettingStartedPage();
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
    '/settings': (context) {
      return SettingsPage(
        userBloc: BlocProvider.of<UserBloc>(context),
      );
    },
    '/notification_settings': (context) {
      //Old app does have this working either
      return NotificationSettingsPage();
    }
  };

  final RouteFactory onGenerateRoute = (routerSettings) {
    if (routerSettings.name == '/phone_verification') {
      var args = routerSettings.arguments as List<Object>;
      return MaterialPageRoute(
        builder: (context) {
          return PhoneVerificationPage(
            initPhoneVerificationBloc: () {
              return PhoneVerificationBloc(
                userRepository: Injector.of(context).userRepository,
                verificationId: args[0] as String,
                update: args[1] as bool
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

    if (routerSettings.name == '/chat_room_details') {
      return MaterialPageRoute(
        builder: (context) {
          return ChatRoomDetailsPage(
            userBloc: BlocProvider.of<UserBloc>(context),
            initRoomDetailsBloc: () {
              return ChatRoomDetailsBloc(
                userBloc: BlocProvider.of<UserBloc>(context),
                groupRepository: Injector.of(context).groupRepository,
                postRepository: Injector.of(context).postRepository,
                roomId: routerSettings.arguments as String,
              );
            },
          );
        }
      );
    }

    if (routerSettings.name == '/connections') {
      return MaterialPageRoute(
          builder: (context) {
            return ConnectionsPage(
              initConnectionsBloc: () {
                return ConnectionsBloc(
                  userBloc: BlocProvider.of<UserBloc>(context),
                  userId: routerSettings.arguments as String,
                  userRepository: Injector.of(context).userRepository
                );
              },
            );
          }
      );
    }

    if (routerSettings.name == '/trophies') {
      return MaterialPageRoute(
          builder: (context) {
            return TrophiesPage(
              initTrophiesBloc: () {
                return TrophiesBloc(
                  userBloc: BlocProvider.of<UserBloc>(context),
                  userId: routerSettings.arguments as String,
                  userRepository: Injector.of(context).userRepository
                );
              },
            );
          }
      );
    }

    if (routerSettings.name == '/trophy_info') {
      return MaterialPageRoute(
          builder: (context) {
            return TrophyInfoPage(
              initTrophyInfoBloc: () {
                return TrophyInfoBloc(
                    userBloc: BlocProvider.of<UserBloc>(context),
                    trophyIndex: routerSettings.arguments as int,
                    userRepository: Injector
                        .of(context)
                        .userRepository
                );
              },
            );
          }
      );
    }

    if (routerSettings.name == '/chat_room') {
      return MaterialPageRoute(
        builder: (context) {
          Map<String, dynamic> args = routerSettings.arguments as Map<String, dynamic>;

          return ChatRoomPage(
            userBloc: BlocProvider.of<UserBloc>(context),
            initChatRoomBloc: () {
              return ChatRoomBloc(
                userBloc: BlocProvider.of<UserBloc>(context),
                chatRepository: Injector.of(context).chatRepository,
                groupRepository: Injector.of(context).groupRepository,
                roomId: args['roomId'],
                isRoom: args['isRoom'],
              );
            },
          );
        }
      );
    }

    if (routerSettings.name == '/chat_settings') {
      return MaterialPageRoute(
        builder: (context) {
          return ChatSettingsPage(
            userBloc: BlocProvider.of<UserBloc>(context),
            initChatSettingsBloc: () {
              return ChatSettingsBloc(
                userBloc: BlocProvider.of<UserBloc>(context),
                userRepository: Injector.of(context).userRepository,
              );
            },
          );
        }
      );
    }

    if (routerSettings.name == '/profile') {
      return MaterialPageRoute(
        builder: (context) {
          return ProfilePage(
            isTab: false,
            userBloc: BlocProvider.of<UserBloc>(context),
            initProfileBloc: () {
              return ProfileBloc(
                userBloc: BlocProvider.of<UserBloc>(context),
                userRepository: Injector.of(context).userRepository,
                postRepository: Injector.of(context).postRepository,
                userId: routerSettings.arguments as String,
              );
            },
          );
        },
      );
    }

    if (routerSettings.name == '/preview_image') {
      return MaterialPageRoute(
        builder: (context) {
          return PreviewImage(
            imageURL: routerSettings.arguments as String,
          );
        },
      );
    }

    if(routerSettings.name == '/update_info'){
      return MaterialPageRoute(
        builder: (context) {
          return ProfileSettingsPage(
            userRepository: Injector.of(context).userRepository,
            initProfileSettingsBloc: (){
              return ProfileSettingsBloc(
                index: routerSettings.arguments as int,
                userBloc: BlocProvider.of<UserBloc>(context),
                userRepository: Injector.of(context).userRepository,
              );
            },
            index: routerSettings.arguments as int,
          );
        },
      );
    }

    if (routerSettings.name == '/edit_post') {
      return MaterialPageRoute(
        builder: (context) {
          return EditPostPage(
            userBloc: BlocProvider.of<UserBloc>(context),
            initEditPostBloc: () {
              return EditPostBloc(
                userBloc: BlocProvider.of<UserBloc>(context),
                postRepository: Injector.of(context).postRepository,
                postId: routerSettings.arguments as String,
              );
            },
          );
        }
      );
    }

    if (routerSettings.name == '/edit_poll') {
      return MaterialPageRoute(
        builder: (context) {
          return EditPollPage(
            userBloc: BlocProvider.of<UserBloc>(context),
            initEditPollBloc: () {
              return EditPollBloc(
                userBloc: BlocProvider.of<UserBloc>(context),
                postRepository: Injector.of(context).postRepository,
                pollId: routerSettings.arguments as String,
              );
            },
          );
        }
      );
    }

    if (routerSettings.name == '/create_message') {
      return MaterialPageRoute(
        builder: (context) {
          return CreateMessagePage(
            userBloc: BlocProvider.of<UserBloc>(context),
            initCreateMessageBloc: () {
              return CreateMessageBloc(
                userBloc: BlocProvider.of<UserBloc>(context),
                groupRepository: Injector.of(context).groupRepository,
                chatRepository: Injector.of(context).chatRepository,
                userRepository: Injector.of(context).userRepository,
                type: routerSettings.arguments as int,
              );
            },
          );
        }
      );
    }

    if (routerSettings.name == '/create_group') {
      return MaterialPageRoute(
        builder: (context) {
          return CreateGroupPage(
            userBloc: BlocProvider.of<UserBloc>(context),
            initCreateGroupBloc: () {
              return CreateGroupBloc(
                groupRepository: Injector.of(context).groupRepository,
                members: routerSettings.arguments as List<MemberItem>,
              );
            },
          );
        }
      );
    }

    if (routerSettings.name == '/post_details') {
      return MaterialPageRoute(
        builder: (context) {
          return PostDetailsPage(
            userBloc: BlocProvider.of<UserBloc>(context),
            initPostDetailsBloc: () {
              return PostDetailsBloc(
                userBloc: BlocProvider.of<UserBloc>(context),
                postRepository: Injector.of(context).postRepository,
                commentRepository: Injector.of(context).commentRepository,
                postId: routerSettings.arguments as String,
              );
            },
          );
        }
      );
    }

    if (routerSettings.name == '/search') {
      return MaterialPageRoute(
        builder: (context) {
          return PerformSearch(
            userRepository: Injector.of(context).userRepository,
            eventRepository: Injector.of(context).eventRepository,
            groupRepository: Injector.of(context).groupRepository,
            searchType: (routerSettings.arguments as Map)['searchType'],
            searchFilter: (routerSettings.arguments as Map)['filter'],
          );
        }
      );
    }

    if (routerSettings.name == '/info') {
      return MaterialPageRoute(
        builder: (context) {
          return InfoDialog(
            title: "Profile Update",
            message: (routerSettings.arguments as SettingsType) == SettingsType.updateChurch ? "Your Church information needs to be updated" : "Your Personal information needs to be updated",
            btnTitle: "Update Now",
            onClick: () {
              Navigator.of(context).pushReplacementNamed('/update_info', arguments: (routerSettings.arguments as SettingsType) == SettingsType.updateChurch ? 1 : 0);
            }
          );
        },
      );
    }

    return null;
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
          initialRoute: '/splash',
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