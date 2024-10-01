// ignore_for_file: unused_field

import 'dart:convert';
import 'package:aupulse/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class AddSectionView extends StatefulWidget {
  const AddSectionView({Key? key}) : super(key: key);

  @override
  State<AddSectionView> createState() => _AddSectionViewState();
}

class _AddSectionViewState extends State<AddSectionView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        title: const Text("Add Section"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _nameDateController,
              decoration: InputDecoration(
                labelText: 'Section Name',
                hintText: 'Enter section name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter section name';
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
    final branchId = state.pathParameters["branchid"];
    if (_formKey.currentState!.validate()) {
      EasyLoading.show(status: "Adding");
      String name = _nameDateController.text;

      http.Response res = await http.post(
        Uri.parse("https://aupulse-api.vercel.app/api/section/"),
        body: {"name": name, "branch": branchId},
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
