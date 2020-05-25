import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../bloc/bloc_provider.dart';
import '../../data/user/firestore_user_repository.dart';
import '../../models/old/user_entity.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import './chat_settings_state.dart';

const _kInitialChatSettingsState = ChatSettingsState(
  chatSettings: null,
  isLoading: true,
  error: null,
);

class ChatSettingsBloc implements BaseBloc {
  /// 
  /// Input functions
  ///
  final void Function() saveSettings;
  final void Function(bool) messageNotificationsChanged;
  final void Function(bool) chatNotificationsChanged;
  final void Function(bool) groupNotificationsChanged;
  final void Function(bool) onlineStatusChanged;

  /// 
  /// Output streams
  /// 
  final ValueStream<ChatSettingsState> chatSettingsState$;
  final Stream<ChatSettingsMessage> message$;
  final ValueStream<bool> isLoading$;

  /// 
  /// Clean up
  ///
  final void Function() _dispose;

  ChatSettingsBloc._({
    @required this.saveSettings,
    @required this.messageNotificationsChanged,
    @required this.chatNotificationsChanged,
    @required this.groupNotificationsChanged,
    @required this.onlineStatusChanged,
    @required this.chatSettingsState$,
    @required this.message$,
    @required this.isLoading$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  @override
  void dispose() => _dispose;

  factory ChatSettingsBloc({
    @required UserBloc userBloc,
    @required FirestoreUserRepository userRepository,
  }) {
    /// 
    /// Assert
    /// 
    assert(userBloc != null, 'userBloc cannot be null');
    assert(userRepository != null, 'userRepository cannot be null');

    /// 
    /// Stream controller
    /// 
    final messageNotificationsSubject = BehaviorSubject<bool>.seeded(false);
    final chatNotificationsSubject = BehaviorSubject<bool>.seeded(false);
    final groupNotificationsSubject = BehaviorSubject<bool>.seeded(false);
    final onlineStatusSubject = BehaviorSubject<bool>.seeded(false);
    final saveNotificationsSubject = PublishSubject<void>();
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);

    /// 
    /// Streams
    /// 
    final message$ = saveNotificationsSubject
      .switchMap((_) => performSave(
          userRepository,
          messageNotificationsSubject.value,
          chatNotificationsSubject.value,
          groupNotificationsSubject.value,
          onlineStatusSubject.value,
          (userBloc.loginState$.value as LoggedInUser).uid,
          isLoadingSubject,
        )
      ).publish();

    final chatSettingsState$ = _getChatNotificationSettings(
      userBloc,
      userRepository,
    ).publishValueSeeded(_kInitialChatSettingsState);

    /// 
    /// Controllers and subscriptions
    /// 
    final subscriptions = <StreamSubscription>[
      chatSettingsState$.connect(),
      message$.connect(),
    ];

    final controllers = <StreamController>[
      messageNotificationsSubject,
      chatNotificationsSubject,
      groupNotificationsSubject,
      onlineStatusSubject,
      isLoadingSubject,
    ];

    return ChatSettingsBloc._(
      saveSettings: () => saveNotificationsSubject.add(null),
      messageNotificationsChanged: messageNotificationsSubject.add,
      chatNotificationsChanged: chatNotificationsSubject.add,
      groupNotificationsChanged: groupNotificationsSubject.add,
      onlineStatusChanged: onlineStatusSubject.add,
      isLoading$: isLoadingSubject,
      chatSettingsState$: chatSettingsState$,
      message$: message$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      }
    );
  }

  static Stream<ChatSettingsState> _toState(
    LoginState loginState,
    FirestoreUserRepository userRepository,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialChatSettingsState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return userRepository.getUserById(uid: loginState.uid)
        .map((entity) {
          return _entityToChatSettingsItem(entity);
        })
        .map((chatSettingsItem) {
          return _kInitialChatSettingsState.copyWith(
            chatSettings: chatSettingsItem,
            isLoading: false,
          );
        })
        .startWith(_kInitialChatSettingsState)
        .onErrorReturnWith((e) {
          return _kInitialChatSettingsState.copyWith(
            error: e,
            isLoading: false,
          );
        });
    }

    return Stream.value(
      _kInitialChatSettingsState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static ChatSettingsItem _entityToChatSettingsItem(
    UserEntity entity
  ) {
    return ChatSettingsItem(
      messageNotifications: entity.messageNotification ?? false,
      groupNotifications: entity.groupNotification ?? false,
      chatNotifications: entity.chatNotification ?? false,
      onlineStatus: entity.chatOnlineStatus ?? false,
    );
  }

  static Stream<ChatSettingsState> _getChatNotificationSettings(
    UserBloc userBloc,
    FirestoreUserRepository userRepository,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        userRepository,
      );
    });
  }

  static Stream<ChatSettingsMessage> performSave(
    FirestoreUserRepository userRepository,
    bool messageSetting,
    bool chatSetting,
    bool groupSetting,
    bool onlineStatusSetting,
    String uid,
    Sink<bool> isLoadingSink,
  ) async* {
    print('[DEBUG] ChatSettingsBloc#performSave');
    try {
      isLoadingSink.add(true);
      await userRepository.saveNotifications(
        user: uid,
        messages: messageSetting,
        chat: chatSetting,
        group: groupSetting,
        online: onlineStatusSetting,
      );
      yield ChatSettingsSavedSuccess();
    } catch (e) {
      yield ChatSettingsSavedError(e);
    } finally {
      isLoadingSink.add(false);
    }
  }
}