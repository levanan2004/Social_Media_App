import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/auth/auth.dart';
import 'package:social_media_app/firebase_options.dart';
import 'package:social_media_app/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();

  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: EasyLocalization(
      supportedLocales: const [Locale("vi"), Locale("en")],
      path: "assets/translations",
      child: const MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Banner: false
      debugShowCheckedModeBanner: false,
      // Home Controller
      home: const AuthPage(),
      // Multi language
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      // Theme(Light/Dark)
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
