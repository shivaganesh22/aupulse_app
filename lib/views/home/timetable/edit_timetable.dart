// ignore_for_file: unused_field

import 'dart:convert';
import 'package:aupulse/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class EditTimetableView extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;
  const EditTimetableView({Key? key, required this.id, required this.data})
      : super(key: key);

  @override
  State<EditTimetableView> createState() => _EditTimetableViewState();
}

class _EditTimetableViewState extends State<EditTimetableView> {
  final _formKey = GlobalKey<FormState>();
  late String branchid, batchid, sectionid, semesterid;
  List<dynamic> timing = [];
  List<dynamic> faculty = [];
  List<dynamic> subject = [];
  String? selectedTiming;
  String? selectedFaculty;
  String? selectedSubject;
  bool? repeatEveryWeek = false;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _tillDateController = TextEditingController();

  DateTime _date1 = DateTime.now();
  DateTime _date2 = DateTime.now();
  Future<void> apicall() async {
    http.Response res =
        await http.get(Uri.parse("https://aupulse-api.vercel.app/api/timing/"));

    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);
      if (mounted) {
        setState(() {
          timing = jsonData;
          selectedTiming = widget.data["timing"]["id"].toString();
        });
      }
    }
    http.Response res1 = await http
        .get(Uri.parse("https://aupulse-api.vercel.app/api/faculty/"));

    if (res1.statusCode == 200) {
      final jsonData = jsonDecode(res1.body);
      if (mounted) {
        setState(() {
          faculty = jsonData;
          selectedFaculty = widget.data["faculty"]["id"].toString();
          // Update data with API response
        });
      }
    }
    http.Response res2 = await http.get(Uri.parse(
        "https://aupulse-api.vercel.app/api/subject/?semester=${semesterid}"));

    if (res1.statusCode == 200) {
      final jsonData = jsonDecode(res2.body);
      if (mounted) {
        setState(() {
          subject = jsonData;
          selectedSubject = widget.data["subject"]["id"].toString();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _dateController.text = widget.data["date"];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = GoRouterState.of(context);
    branchid = state.pathParameters["branchid"] ?? '';
    batchid = state.pathParameters["batchid"] ?? "";
    sectionid = state.pathParameters["sectionid"] ?? "";
    semesterid = state.pathParameters["semesterid"] ?? "";
    apicall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        title: const Text("Edit Timetable"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Dropdown menu
                DropdownButtonFormField<String>(
                  value: selectedTiming,
                  onChanged: (newValue) {
                    setState(() {
                      selectedTiming = newValue;
                    });
                  },
                  items: timing.map<DropdownMenuItem<String>>((dynamic item) {
                    return DropdownMenuItem<String>(
                      value: item['id'].toString(),
                      child: Text(item['name'].toString() +
                          " (${item["start"]} - ${item["end"]})"),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select time slot';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Time Slot',
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 16.0),
                //subject
                DropdownButtonFormField<String>(
                  value: selectedSubject,
                  onChanged: (newValue) {
                    setState(() {
                      selectedSubject = newValue;
                    });
                  },
                  items: subject.map<DropdownMenuItem<String>>((dynamic item) {
                    return DropdownMenuItem<String>(
                      value: item['id'].toString(),
                      child: Text(
                        '${item['name'].toString()}${item["is_lab"] ? " (Lab)" : ""}',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select subject';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Subject',
                    border: OutlineInputBorder(),
                  ),
                ),
                //faculty
                SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: selectedFaculty,
                  onChanged: (newValue) {
                    setState(() {
                      selectedFaculty = newValue;
                    });
                  },
                  items: faculty.map<DropdownMenuItem<String>>((dynamic item) {
                    return DropdownMenuItem<String>(
                      value: item['id'].toString(),
                      child: Text(item['first_name'].toString() +
                          " " +
                          item["last_name"].toString() +
                          " " +
                          item["department"].toString()),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select faculty';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Faculty',
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 16.0),
                TextFormField(
                  controller: _dateController,
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
                        _dateController.text =
                            DateFormat('yyyy-MM-dd').format(picked);
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Date',
                    hintText: 'Select date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select date';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _handleadd,
                  child: Text('Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleadd() async {
    // login user

    if (_formKey.currentState!.validate()) {
      EasyLoading.show(status: "Updating");
      String date = _dateController.text;

      http.Response res = await http.patch(
        Uri.parse("https://aupulse-api.vercel.app/api/timetable/${widget.id}/"),
        body: {
          "date": date,
          "timing": selectedTiming,
          "subject": selectedSubject,
          "faculty": selectedFaculty
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
