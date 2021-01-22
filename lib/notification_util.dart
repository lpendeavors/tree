import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

class NotificationService {
  static String myImage =
      "https://firebasestorage.googleapis.com/v0/b/tree-mobile-app.appspot.com/o/userBase%2F8GCIDXSNUYT3BpDi6trD3gwDnFm2%2F1560971222273.jpg?alt=media&token=a53620d8-ebe3-497f-9334-46fb3b162ce1";

  static final Client client = Client();

  // from 'https://console.firebase.google.com'
  // --> project settings --> cloud messaging --> "Server key"
  static const String serverKey =
      'AAAAR7bvzfs:APA91bGqG3QPg5ZKDJRiubgUsJDW9MoJf-JaigAzgfJBYmg61ZYK6VeZTgPtvsGYdA_O9OdEh92JrD6htcOe5oIPhf0lxBAwXMUd-qZDB3Ao1npBsBAq-oAhfVcUzPApBuiocnmd3Aas';

  static sendPlainPush({
    String topic,
    String token,
    int liveTimeInSeconds = (Duration.secondsPerDay * 7),
    String title,
    String body,
    String image,
    Map data,
    String tag,
  }) async {
    String fcmToken = topic != null ? '/topics/$topic' : token;
    data = data ?? Map();
    data['click_action'] = 'FLUTTER_NOTIFICATION_CLICK';
    data['id'] = '1';
    data['status'] = 'done';
    client.post(
      'https://fcm.googleapis.com/fcm/send',
      body: json.encode({
        'notification': {
          'body': body,
          'title': title,
          'image': image,
          //'icon': "ic_launcher",
          //'color': "#ffffff",
          'icon': "ic_launcher",
          'color': "white",
          'tag': tag
        },
        'data': data,
        'to': fcmToken,
        'time_to_live': liveTimeInSeconds
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
    );
  }

  static Future<Response> sendPush(
          {@required String title,
          @required String body,
          @required String sendToToken,
          @required Map<String, String> payload,
          @required int type,
          @required String id}) =>
      client.post(
        'https://fcm.googleapis.com/fcm/send',
        body: json.encode({
          'collapse_key': 'type_mtellect',
          'delay_while_idle': false,

          //'shouldCollapse': 'true',
          'notification': {
            'body': '$body',
            'title': '$title',
            'tag': 'type_mtellect',
            'badge': "1",
            'image': payload['image'],
            //'image': "http://tiny.cc/75snaz",
            'icon': "ic_launcher",
            'color': "white",
            //'alert': 'Here is a notification'
            //'vibrate': 'true'
          },
          'priority': 'high',
          'data': generateNotificationData(
              /*sendTo: sendTo,*/ payload: payload,
              type: type,
              id: id),
          'to': sendToToken,
          'sound': "slow_spring_board"
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
      );

  static Map<String, String> generateNotificationData(
      {
      //@required BaseModel sendTo,
      @required Map<String, String> payload,
      @required int type,
      @required String id}) {
    Map<String, String> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'id': id,
      'notificationType': type.toString(),
      'body': jsonEncode(payload),
      //NOTIFICATION_SEND_TO: encodePayloadToString(sendTo),
    };

    return data;
  }

  static Future<Response> sendPushTo({
    String server,
    @required String title,
    @required String message,
    @required String image,
    @required String fcmToken,
    @required Map<String, String> payload,
  }) =>
      client.post(
        'https://fcm.googleapis.com/fcm/send',
        body: json.encode({
          'collapse_key': 'type_mtellect',
          'delay_while_idle': false,

          //'shouldCollapse': 'true',
          'notification': {
            'title': '$title',
            'body': '$message',
            'badge': "1",
            'tag': 'type_mtellect',
            'image': image,
            'icon': "ic_launcher",
            'color': "white",
            //'alert': 'Here is a notification'
            //'vibrate': 'true'
          },
          'priority': 'high',
          'data': updatePayloadData(payload: payload),
          'to': fcmToken,
          'sound': "slow_spring_board"
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=${server ?? serverKey}',
        },
      );

  static Map<String, String> updatePayloadData({
    @required Map<String, String> payload,
  }) {
    Map<String, String> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      // 'id': '1',
      'status': 'done',
      'id': payload['id'],
      'notificationType': payload['notificationType'],
      'body': jsonEncode(payload),
    };

    return data;
  }
}
