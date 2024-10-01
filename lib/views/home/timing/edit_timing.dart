// ignore_for_file: unused_field

import 'dart:convert';
import 'package:aupulse/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class EditTimingView extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;
  const EditTimingView({Key? key, required this.id, required this.data})
      : super(key: key);

  @override
  State<EditTimingView> createState() => _EditTimingViewState();
}

class _EditTimingViewState extends State<EditTimingView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameDateController = TextEditingController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  TimeOfDay _starttime = TimeOfDay.now();
  TimeOfDay _endtime = TimeOfDay.now();
  @override
  void initState() {
    super.initState();
    _nameDateController.text = widget.data["name"];
    _startController.text = widget.data["start"];
    _endController.text = widget.data["end"];
    _starttime=TimeOfDay.fromDateTime(DateFormat.Hms().parse(widget.data["start"]));
    _endtime=TimeOfDay.fromDateTime(DateFormat.Hms().parse(widget.data["end"]));
  }

  @override
  void dispose() {
    _nameDateController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }
  Future<void> _selectTime(
      BuildContext context, TextEditingController controller, bool s) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: s ? _starttime : _endtime,
    );
    if (picked != null) {
      setState(() {
        final MaterialLocalizations localizations =
            MaterialLocalizations.of(context);
        final String formattedTime =
            localizations.formatTimeOfDay(picked, alwaysUse24HourFormat: true);
        setState(() {
          if (s)
            _starttime = picked;
          else
            _endtime = picked;
          controller.text = formattedTime;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        title: const Text("Edit Timing"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _nameDateController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter slot name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter slot name';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _startController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Start Time',
                hintText: 'Enter start time',
                border: OutlineInputBorder(),
              ),
              onTap: () => _selectTime(context, _startController, true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter start time';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _endController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'End Time',
                hintText: 'Enter end time',
                border: OutlineInputBorder(),
              ),
              onTap: () => _selectTime(context, _endController, false),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter end time';
                }
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
      String start = _startController.text;
      String end = _endController.text;

      http.Response res = await http.patch(
        Uri.parse("https://aupulse-api.vercel.app/api/timing/${widget.id}/"),
        body: {
          "name": name,"start":start,"end":end
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
