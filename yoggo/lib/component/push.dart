import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> showNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  print('잉');

  try {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // 채널 ID
      'your_channel_name', // 채널 이름
      channelDescription: 'your_channel_description', // 채널 설명
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // 알림 ID
      'Notification Title', // 알림 제목
      'Notification Body', // 알림 내용
      platformChannelSpecifics,
      payload: 'Custom_Sound', // 푸시 알림을 클릭했을 때 전달되는 데이터
    );
    print('포여줬다!!');
  } catch (e) {
    print('푸시 실패');
    print(e);
  }
}
