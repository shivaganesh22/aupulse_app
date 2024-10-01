// ignore_for_file: unused_field

import 'dart:convert';
import 'package:aupulse/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class EditBatchView extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;
  const EditBatchView({
    Key? key,
    required this.id,
    required this.data,
  }) : super(key: key);

  @override
  State<EditBatchView> createState() => _EditBatchViewState();
}

class _EditBatchViewState extends State<EditBatchView> {
  bool? isCompleted = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  DateTime _date1 = DateTime.now();
  DateTime _date2 = DateTime.now();

  @override
  void initState() {
    super.initState();
    isCompleted = widget.data["is_completed"] ?? false;
    _date1 = DateTime.parse(widget.data["start"]);
    _date2 = DateTime.parse(widget.data["end"]);
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _startDateController.text = widget.data["start"];
    _endDateController.text = widget.data["end"];
    // isCompleted = widget.data["is_completed"] as bool;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        title: const Text("Edit Batch"),
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
                  initialDate:_date2,
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
      String start_date = _startDateController.text;
      String end_date = _endDateController.text;
      http.Response res = await http.patch(
        Uri.parse("https://aupulse-api.vercel.app/api/batch/${widget.id}/"),
        body: {
          "start": start_date,
          "end": end_date,
          "is_completed": isCompleted.toString()
        },
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
