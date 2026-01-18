
import 'package:flutter/material.dart';
import 'package:weather/homePage.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

final fln = FlutterLocalNotificationsPlugin();// Flutter 本地通知插件实例，用来在手机本地弹通知

/*
  分3种情况
  1.正在用App（前台）
  2.app切到后台
  3.app被划掉（结束后台）
 */

//情况3：app被划掉，但是需要推送来的数据
Future<void> _bgHandler(RemoteMessage m) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);//后台必须重新初始化 Firebase
}

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snap.data == null ? const SignInPage() : const Homepage();
        },
      ),
    );
  }
}

