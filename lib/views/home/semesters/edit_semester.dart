// ignore_for_file: unused_field

import 'dart:convert';
import 'package:aupulse/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class EditSemesterView extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;
  const EditSemesterView({Key? key, required this.id, required this.data})
      : super(key: key);

  @override
  State<EditSemesterView> createState() => _EditSemesterViewState();
}

class _EditSemesterViewState extends State<EditSemesterView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _semController = TextEditingController();
  bool? isCompleted=false;
  @override
  void initState() {
    super.initState();
    isCompleted = widget.data["is_completed"] ?? false;
    _yearController.text = widget.data["year"].toString();
    _semController.text = widget.data["semester"].toString();
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
        title: const Text("Edit Semester"),
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
            Row(
              children: [
                Checkbox(
                  value: isCompleted,
                  activeColor: Colors.green,
                  onChanged: (newValue) {
                    setState(() {
                      isCompleted = newValue;
                    });
                  },
                ),
                const SizedBox(width: 8.0),
                Text('Completed'),
              ],
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
      String year = _yearController.text;
      String sem = _semController.text;

      http.Response res = await http.patch(
        Uri.parse("https://aupulse-api.vercel.app/api/semester/${widget.id}/"),
        body: {"year": year,"semester":sem, "is_completed": isCompleted.toString()},
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
