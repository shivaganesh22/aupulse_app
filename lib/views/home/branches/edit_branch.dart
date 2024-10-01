// ignore_for_file: unused_field

import 'dart:convert';
import 'package:aupulse/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class EditBranchView extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;
  const EditBranchView({Key? key, required this.id, required this.data})
      : super(key: key);

  @override
  State<EditBranchView> createState() => _EditBranchViewState();
}

class _EditBranchViewState extends State<EditBranchView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameDateController.text = widget.data["name"];
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
        title: const Text("Edit Branch"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _nameDateController,
              decoration: InputDecoration(
                labelText: 'Branch Name',
                hintText: 'Enter branch name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter branch name';
                }
                // Add custom validation for date format if needed
                return null;
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _handleadd,
              child: Text('Update'),
            ),
          ]),
        ),
      ),
    );
  }

  void _handleadd() async {
    // login user
    
    if (_formKey.currentState!.validate()) {
      EasyLoading.show(status: "Updating");
      String name = _nameDateController.text;

      http.Response res = await http.patch(
        Uri.parse("https://aupulse-api.vercel.app/api/branch/${widget.id}/"),
        body: {"name": name, },
      );
      final Map<String, dynamic> data = jsonDecode(res.body);
      if (res.statusCode == 200) {
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
