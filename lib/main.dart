import 'package:flutter/material.dart';
import 'package:aupulse/navigation/app_navigation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Aupulse',
      debugShowCheckedModeBanner: false,
      routerConfig: AppNavigation.router,
      builder: EasyLoading.init(),
    );
  }
}

void showSnackBar(BuildContext context, String message, bool type) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: type == true ? Colors.green : Colors.red,
      action: SnackBarAction(
        label: 'Close',
        textColor: Colors.white,
        onPressed: () {},
      ),
    );

    // Use ScaffoldMessenger to show the SnackBar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }