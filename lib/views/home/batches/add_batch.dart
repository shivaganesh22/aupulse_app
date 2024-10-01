// ignore_for_file: unused_field

import 'dart:convert';
import 'package:aupulse/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AddBatchView extends StatefulWidget {
  const AddBatchView({Key? key}) : super(key: key);

  @override
  State<AddBatchView> createState() => _AddBatchViewState();
}

class _AddBatchViewState extends State<AddBatchView> {
  DateTime _date1 = DateTime.now();
  DateTime _date2 = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        title: const Text("Add Batch"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _startDateController,
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _date1,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _date1 = picked;
                    _startDateController.text = DateFormat('yyyy-MM-dd')
                        .format(picked); // Format as needed
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Start Date',
                hintText: 'Select start date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter start date';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _endDateController,
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _date2,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _date2 = picked;
                    _endDateController.text =
                        DateFormat('yyyy-MM-dd').format(picked);
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'End Date',
                hintText: 'Select end date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter end date';
                }
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

    if (_formKey.currentState!.validate()) {
      EasyLoading.show(status: "Adding");
      String start_date = _startDateController.text;
      String end_date = _endDateController.text;
      http.Response res = await http.post(
        Uri.parse("https://aupulse-api.vercel.app/api/batch/"),
        body: {"start": start_date, "end": end_date},
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
