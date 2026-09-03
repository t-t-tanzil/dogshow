import 'package:dog_show/ui/breed_list_page.dart';
import 'package:dog_show/ui/splash_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      path: 'assets/locales',
      supportedLocales: const [Locale('en', 'US'),],
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp(),
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

// Disables the Android stretch/glow overscroll indicator app-wide so lists
// simply stop at their edges with no extra visual effect.
class NoOverscrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: EasyLoading.init(),
      scrollBehavior: NoOverscrollBehavior(),
      theme: ThemeData(
        hintColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 1,
        ),
      ),
      home: SplashScreen(),
    );
  }
}
