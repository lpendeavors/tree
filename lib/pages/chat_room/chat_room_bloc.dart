import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/chat/firestore_chat_repository.dart';
import '../../data/group/firestore_group_repository.dart';
import '../../bloc/bloc_provider.dart';
import '../../user_bloc/user_bloc.dart';
import '../../user_bloc/user_login_state.dart';
import '../../models/old/chat_entity.dart';
import '../../models/old/group_entity.dart';
import './chat_room_state.dart';

bool _isMessageValid(String message) {
  return message.length > 0;
}

const _kInitialChatRoomState = ChatRoomState(
  error: null,
  isLoading: true,
  messages: [],
  details: null,
);

class ChatRoomBloc implements BaseBloc {
  /// 
  /// Input functions
  ///
  final void Function() sendMessage;
  final void Function(String) messageChanged;
  final void Function(int) messageTypeChanged;

  /// 
  /// Output streams
  ///
  final ValueStream<ChatRoomState> chatRoomState$;
  final Stream<MessageError> messageError$;
  final Stream<ChatRoomMessage> message$;
  final ValueStream<bool> isLoading$;

  /// 
  /// Clean up
  /// 
  final void Function() _dispose;

  ChatRoomBloc._({
    @required this.sendMessage,
    @required this.messageChanged,
    @required this.messageTypeChanged,
    @required this.chatRoomState$,
    @required this.messageError$,
    @required this.message$,
    @required this.isLoading$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory ChatRoomBloc({
    @required UserBloc userBloc,
    @required FirestoreChatRepository chatRepository,
    @required FirestoreGroupRepository groupRepository,
    @required String roomId,
    @required bool isRoom,
  }) {
    /// 
    /// Assert 
    /// 
    assert(userBloc != null, 'userBloc cannot be null');
    assert(chatRepository != null, 'chatRepository cannot be null');
    assert(groupRepository != null, 'groupRepository cannot be null');
    assert(roomId != null, 'roomId cannot be null');
    assert(isRoom != null, 'isRoom cannot be null');

    /// 
    /// Stream controllers
    ///
    final sendMessageSubject = PublishSubject<void>();
    final messageSubject = BehaviorSubject<String>.seeded('');
    final messageTypeSubject = BehaviorSubject<int>.seeded(null);
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);

    /// 
    /// Streams
    ///
    final messageError$ = messageSubject.map((message) {
      if (_isMessageValid(message)) return null;
      return const MessageError();
    }).share();

    final allFieldsAreValid$ = Rx.combineLatest(
      [
        messageError$,
      ],
      (allError) => allError.every((error) {
        print(error);
        return error == null;
      }),
    );

    final chatRoomState$ = _getChatRoomContent(
      userBloc,
      groupRepository,
      chatRepository,
      roomId,
      isRoom,
    ).publishValueSeeded(_kInitialChatRoomState);

    final message$ = sendMessageSubject
      .withLatestFrom(allFieldsAreValid$, (_, bool isValid) => isValid)
      .where((isValid) => isValid)
      .exhaustMap(
        (_) => sendNewMessage(
          userBloc,
          chatRepository,
          messageSubject.value,
          messageTypeSubject.value,
          isLoadingSubject,
          roomId,
          isRoom,
        ),
      ).publish();

    ///
    /// Controllers and subscriptions
    ///
    final subscriptions = <StreamSubscription>[
      chatRoomState$.connect(),
      message$.connect(),
    ];

    final controllers = <StreamController>[
      messageSubject,
      messageTypeSubject,
      isLoadingSubject,
    ];

    return ChatRoomBloc._(
      messageChanged: messageSubject.add,
      messageTypeChanged: messageTypeSubject.add,
      sendMessage: () => sendMessageSubject.add(null),
      chatRoomState$: chatRoomState$,
      messageError$: messageError$,
      isLoading$: isLoadingSubject,
      message$: message$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      }
    );
  }

  @override
  void dispose() => _dispose;

  static Stream<ChatRoomState> _toState(
    LoginState loginState,
    FirestoreChatRepository chatRepository,
    FirestoreGroupRepository groupRepository,
    String roomId,
    bool isGroup,
  ) {
    if (loginState is Unauthenticated) {
      return Stream.value(
        _kInitialChatRoomState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return Rx.zip2(
        isGroup ? groupRepository.getById(groupId: roomId) : Stream.value(null),
        chatRepository.getByGroup(roomId),
        (group, chats) {
          return _kInitialChatRoomState.copyWith(
            isLoading: false,
            details: isGroup ? _entityToChatRoomItem(group) : null,
            messages: _entitiesToChatMessageItems(chats, loginState.uid),
          );
        }
      )
      .startWith(_kInitialChatRoomState)
      .onErrorReturnWith((e) {
        return _kInitialChatRoomState.copyWith(
          error: e,
          isLoading: false,
        );
      });
    }

    return Stream.value(
      _kInitialChatRoomState.copyWith(
        error: 'Dont know loginState=$loginState',
        isLoading: false,
      ),
    );
  }

  static ChatRoomItem _entityToChatRoomItem(
    GroupEntity entity,
  ) {
    return ChatRoomItem(
      id: entity.documentId,
      isConversation: entity.isConversation,
      isGroup: entity.isGroup,
      members: entity.groupMembers,
      image: entity.image,
      groupImage: entity.groupImage,
      name: entity.groupName,
    );
  }

  static List<ChatMessageItem> _entitiesToChatMessageItems(
    List<ChatEntity> entities,
    String uid,
  ) {
    entities.sort((a, b) => b.time.compareTo(a.time));
    return entities.map((entity) {
      return ChatMessageItem(
        id: entity.documentId,
        type: MessageType.values[entity.type],
        isMine: entity.ownerId == uid,
        isRead: (entity.readBy ?? []).contains(uid),
        showDate: entity.showDate,
        sentDate: DateTime.fromMillisecondsSinceEpoch(entity.time),
        message: entity.message,
        image: entity.image,
        name: entity.fullName,
      );
    }).toList();
  }

  static Stream<ChatRoomState> _getChatRoomContent(
    UserBloc userBloc,
    FirestoreGroupRepository groupRepository,
    FirestoreChatRepository chatRepository,
    String roomId,
    bool isGroup,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        chatRepository,
        groupRepository,
        roomId,
        isGroup,
      );
    });
  }

  static Stream<ChatRoomMessage> sendNewMessage(
    UserBloc userBloc,
    FirestoreChatRepository chatRepository,
    String message,
    int messageType,
    Sink<bool> isLoading,
    String chatId,
    bool isRoom,
  ) async* {
    print('[DEBUG] sendMessage');
    LoginState loginState = userBloc.loginState$.value;

    if (loginState is LoggedInUser) {
      try {
        isLoading.add(true);
        await chatRepository.send(
          message,
          messageType,
          loginState.isAdmin,
          chatId,
          loginState.fullName,
          loginState.email,
          loginState.image,
          loginState.isVerified,
          loginState.isChurch,
          isRoom,
          loginState.token,
          false,
        );
        yield ChatMessageAddedSuccess();
      } catch (e) {
        yield ChatMessageAddedError(e);
      } finally {
        isLoading.add(false);
      }
    } else {
      yield ChatMessageAddedError(NotLoggedInError());
    }
  }
}