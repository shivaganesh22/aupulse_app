import 'dart:convert';

import 'package:aupulse/login/auth.dart';
import 'package:aupulse/main.dart';
import 'package:flutter/material.dart';
import 'package:aupulse/components/common/custom_input_field.dart';
import 'package:aupulse/components/common/page_heading.dart';

import 'package:aupulse/components/common/custom_form_button.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //
  final _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffEEF1F3),
        body: Column(
          children: [
            // const PageHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      children: [
                        const PageHeading(
                          title: 'Admin Login',
                        ),
                        CustomInputField(
                            labelText: 'Username',
                            hintText: 'Your username',
                            controller: _usernameController,
                            validator: (textValue) {
                              if (textValue == null || textValue.isEmpty) {
                                return 'Username is required!';
                              }

                              return null;
                            }),
                        const SizedBox(
                          height: 16,
                        ),
                        CustomInputField(
                          labelText: 'Password',
                          hintText: 'Your password',
                          obscureText: true,
                          controller: _passwordController,
                          suffixIcon: true,
                          validator: (textValue) {
                            if (textValue == null || textValue.isEmpty) {
                              return 'Password is required!';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Container(
                          width: size.width * 0.80,
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _handleForgot,
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Color(0xff939393),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomFormButton(
                          innerText: 'Login',
                          onPressed: _handleLoginUser,
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLoginUser() async {
    // login user

    if (_loginFormKey.currentState!.validate()) {
      EasyLoading.show(status: "Signing");
      String username = _usernameController.text;
      String password = _passwordController.text;
      http.Response res = await http.post(
        Uri.parse("https://aupulse-api.vercel.app/api/login/admin/"),
        body: {"username": username, "password": password},
      );
      final Map<String, dynamic> data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        EasyLoading.showSuccess("Success");
        AuthService.storeLoginDetails(data["token"]);
        context.goNamed("Home");
      } else {
        EasyLoading.showError(data["error"]);
      }
    }
  }

  void _handleForgot() async {
    String username = _usernameController.text;
    if (username.isEmpty) {
      showSnackBar(context, "Enter username", false);
    } else {
      EasyLoading.show(status: "Sending mail");

      http.Response res = await http.post(
        Uri.parse("https://aupulse-api.vercel.app/api/password/reset/"),
        body: {
          "username": username,
        },
      );
      final Map<String, dynamic> data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        EasyLoading.showSuccess("Email Sent");
      } else {
        EasyLoading.showError(data["error"]);
      }
    }
  }
}
