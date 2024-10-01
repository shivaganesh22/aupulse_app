import 'dart:convert';
import 'package:aupulse/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class UpdateAttendanceView extends StatefulWidget {
  final List<dynamic> data;
  const UpdateAttendanceView({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<UpdateAttendanceView> createState() => _UpdateAttendanceViewState();
}

class _UpdateAttendanceViewState extends State<UpdateAttendanceView> {
  List<dynamic> branches = [];
  bool is_loading = false;
  late String branchid, batchid, sectionid, semesterid, periodId;
  Map<String, bool> attendanceStatus = {};

  @override
  void initState() {
    super.initState();

    branches = widget.data;
    for (var branch in branches) {
      attendanceStatus[branch['id'].toString()] = branch['status'];
    }
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
  }

  Future<void> submitAttendance() async {
    EasyLoading.show(status: "Updating");
    List<dynamic> attendanceData = branches.map((branch) {
      return {
        'id': branch['id'].toString(),
        'student':branch["student"]["id"].toString(),
        'period':branch["period"]["id"].toString(),
        'status': attendanceStatus[branch['id'].toString()] ?? true,
      };
    }).toList();

    http.Response res = await http.put(
      Uri.parse("https://aupulse-api.vercel.app/api/attendance/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(attendanceData),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        title: Text("Update Attendance"),
      ),
      body: ListView(
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
            Column(
              children: [
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
                            Text("${branch["student"]["hall_ticket"]}",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        leading: CircleAvatar(
                          child: Text((index + 1).toString()),
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
                    child: Text('Update Attendance'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
