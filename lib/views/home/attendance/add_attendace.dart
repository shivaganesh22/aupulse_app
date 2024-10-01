import 'dart:convert';
import 'package:aupulse/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class AddAttendanceView extends StatefulWidget {
  const AddAttendanceView({Key? key}) : super(key: key);

  @override
  State<AddAttendanceView> createState() => _AddAttendanceViewState();
}

class _AddAttendanceViewState extends State<AddAttendanceView> {
  List<dynamic> branches = []; // Changed to dynamic list for API response
  bool is_loading = false;
  late String branchid, batchid, sectionid, semesterid, periodId;
  Map<String, bool> attendanceStatus = {};

  Future<void> apicall() async {
    http.Response res = await http.get(Uri.parse(
        "https://aupulse-api.vercel.app/api/student/?section=$sectionid&status=True"));

    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);
      if (mounted) {
        setState(() {
          branches = jsonData;
          // Initialize all students as present (true) by default
          attendanceStatus = {
            for (var student in branches) student['id'].toString(): true
          };
        });
      }
    }
    setState(() {
      is_loading = true;
    });
  }

  @override
  void initState() {
    super.initState();
    // apicall();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = GoRouterState.of(context);

    batchid = state.pathParameters["batchid"] ?? "";
    sectionid = state.pathParameters["sectionid"] ?? "";
    branchid = state.pathParameters["branchid"] ?? "";
    semesterid = state.pathParameters["semesterid"] ?? "";
    periodId = state.pathParameters["periodid"] ?? "";
    apicall();
  }

  Future<void> submitAttendance() async {
    EasyLoading.show(status: "Submitting");
    List<dynamic> attendanceData = branches.map((branch) {
      return {
       'student': branch['id'].toString(),
        'period': periodId.toString(),
        'status': attendanceStatus[branch['id'].toString()],
      };
    }).toList();

    http.Response res = await http.post(
      Uri.parse("https://aupulse-api.vercel.app/api/attendance/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(attendanceData),
    );
    if (res.statusCode == 201) {
      EasyLoading.showSuccess("Success");
      context.pop();
    } else {
      final Map<String, dynamic> data = jsonDecode(res.body);
      data.forEach((key, value) {
        if (value is List && value.isNotEmpty && value[0] is String) {
          showSnackBar(context, value[0] as String, false);
        }
      });
      EasyLoading.showError("Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.indigoAccent, title: Text("Add Attendance")),
      body: RefreshIndicator(
        onRefresh: apicall,
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            if (is_loading && branches.isEmpty)
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  title: Text(
                    "No results",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Column(children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: branches.length,
                  itemBuilder: (context, index) {
                    var branch = branches[index];
                    return Card(
                      color: Colors.cyan[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                      child: ListTile(
                        title: Row(
                          children: [
                            Text("${branch["hall_ticket"]}",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        leading: CircleAvatar(
                          child: Text((index + 1)
                              .toString()), // Displaying batch ID in CircleAvatar
                        ),
                        trailing: Checkbox(
                          value:
                              attendanceStatus[branch['id'].toString()] ?? true,
                          onChanged: (bool? value) {
                            setState(() {
                              attendanceStatus[branch['id'].toString()] =
                                  value ?? true;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: submitAttendance,
                    child: Text('Submit Attendance'),
                  ),
                ),
              ]),
          ],
        ),
      ),
    );
  }
}
