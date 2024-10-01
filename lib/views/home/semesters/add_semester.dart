// ignore_for_file: unused_field

import 'dart:convert';
import 'package:aupulse/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class AddSemesterView extends StatefulWidget {
  const AddSemesterView({Key? key}) : super(key: key);

  @override
  State<AddSemesterView> createState() => _AddSemesterViewState();
}

class _AddSemesterViewState extends State<AddSemesterView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _semController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _yearController.dispose();
    _semController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        title: const Text("Add Semester"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Year',
                hintText: 'Enter year',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter year';
                }
                // Add custom validation for date format if needed
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _semController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Semester',
                hintText: 'Enter semester',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter semester';
                }
                // Add custom validation for date format if needed
                return null;
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _handleadd,
              child: Text('Add'),
            ),
          ]),
        ),
      ),
    );
  }

  void _handleadd() async {
    // login user
    final state = GoRouterState.of(context);
    final batchid = state.pathParameters["batchid"];
    if (_formKey.currentState!.validate()) {
      EasyLoading.show(status: "Adding");
      String sem = _semController.text;
      String year = _yearController.text;

      http.Response res = await http.post(
        Uri.parse("https://aupulse-api.vercel.app/api/semester/"),
        body: {"year": year,"semester":sem, "batch": batchid},
      );
      final Map<String, dynamic> data = jsonDecode(res.body);
      if (res.statusCode == 201) {
        EasyLoading.showSuccess("Success");
        context.pop();
      } else {
        data.forEach((key, value) {
          if (value is List && value.isNotEmpty && value[0] is String) {
            showSnackBar(context, value[0] as String, false);
          }
        });
        EasyLoading.showError("Failed");
      }
    }
  }
}
