
import 'package:aupulse/login/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          backgroundColor: Colors.indigoAccent,
        ),
        body: Column(
          children: [
            SizedBox(
              height: 16,
            ),
            Center(
              child: Container(
                width: 110, // Adjust the size as needed
                height: 110, // Adjust the size as needed
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 2.0, // Adjust the border width as needed
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                      "https://d1csarkz8obe9u.cloudfront.net/posterpreviews/profile-design-template-4c23db68ba79c4186fbd258aa06f48b3_screen.jpg?ts\\u003d1581063859"),
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: _handlePassword,
              child: Text('Change Password'),
            ),
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () =>
                  {AuthService.clearLoginDetails(), context.goNamed("Home")},
              child: Text('Logout'),
            ),
          ],
        ));
  }

  void _handlePassword() async {
    EasyLoading.show(status: "Sending mail");
    http.Response res = await http.get(
      Uri.parse("https://aupulse-api.vercel.app/api/password/change/"),
      headers: {
        'Authorization': 'Token ${await AuthService.getLoginDetails()}',
      },
    );
    if (res.statusCode == 200) {
      EasyLoading.showSuccess("Email Sent");
    } else {
      EasyLoading.showError("Failed");
    }
  }
}
