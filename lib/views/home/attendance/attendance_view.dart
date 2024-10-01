import 'dart:convert';
import 'dart:io';
import 'package:aupulse/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class AttendanceView extends StatefulWidget {
  final String id;
  const AttendanceView({Key? key, required this.id}) : super(key: key);

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  List<dynamic> branches = []; // Changed to dynamic list for API response
  bool is_loading = false;
  late String branchid, batchid, sectionid, semesterid, periodId;

  Future<void> apicall() async {
    http.Response res = await http.get(Uri.parse(
        "https://aupulse-api.vercel.app/api/attendancedisplay/?period=${periodId}&student_status=1"));

    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);
      if (mounted)
        setState(() {
          branches = jsonData;
        });
    }
    is_loading = true;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigoAccent,
          title: Text("Attendance"),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(child: Text("Presents report"), value: "present"),
                PopupMenuItem(child: Text("Absents report"), value: "absent"),
                PopupMenuItem(child: Text("Full report"), value: "all"),
              ],
              onSelected: (String newValue) {
                if (branches.length == 0) {
                  showSnackBar(context, "Attendance not taken", false);
                } else {
                  switch (newValue) {
                    case "present":
                      generatePdf(branches, 'present');
                      break;
                    case "absent":
                      generatePdf(branches, 'absent');
                      break;
                    case "all":
                      generatePdf(branches, "all");
                      break;
                  }
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (branches.length == 0) {
                await context.push(
                    context.namedLocation("addAttendance", pathParameters: {
                  "branchid": branchid,
                  "sectionid": sectionid,
                  "semesterid": semesterid,
                  "batchid": batchid,
                  "periodid": periodId,
                }));
              } else {
                await context.push(
                    context.namedLocation("updateAttendance", pathParameters: {
                      "branchid": branchid,
                      "sectionid": sectionid,
                      "semesterid": semesterid,
                      "batchid": batchid,
                      "periodid": periodId,
                    }),
                    extra: branches);
              }

              apicall();
            },
            backgroundColor: Colors.indigoAccent,
            child: const Icon(Icons.add)),
        body: RefreshIndicator(
          onRefresh: apicall,
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              is_loading && branches.isEmpty
                  ? Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                          title: Text(
                        "Attendance not taken",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
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
                                Text("${branch['student']["hall_ticket"]}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            leading: CircleAvatar(
                              child: Text((index + 1)
                                  .toString()), // Displaying batch ID in CircleAvatar
                            ),
                            trailing: branch["status"]
                                ? Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  )
                                : Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ));
  }

  Future<void> generatePdf(List<dynamic> students, String filter) async {
    final pdf = pw.Document();
    List<dynamic> filteredStudents;
    int presentCount = students.where((student) => student['status']).length;
    int absentCount = students.where((student) => !student['status']).length;
    if (filter == 'present') {
      filteredStudents =
          students.where((student) => student['status']).toList();
    } else if (filter == 'absent') {
      filteredStudents =
          students.where((student) => !student['status']).toList();
    } else {
      filteredStudents = students;
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                  child: pw.Text(
                'Attendance Report ',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              )),
              pw.SizedBox(height: 20),
              pw.Text(
                  '${branches[0]['period']["timing"]["name"] ?? ''}: ${branches[0]["period"]["timing"]['start'] ?? ''} - ${branches[0]['period']["timing"]['end'] ?? ''}'),
              pw.Text('Date: ${branches[0]['period']['date']}'),
              if (filter != 'present' || filter != 'absent')
                pw.Text(
                    'Present: ${presentCount} Absent: ${absentCount} Total:${branches.length}'),
              pw.Text(
                  'Subject: ${branches[0]['period']['subject']["name"] ?? ''}'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                headers: [
                  'S.No',
                  'Hall Ticket',
                  'Name',
                  'Phone Number',
                  'Status'
                ],
                data: List<List<String>>.generate(
                  filteredStudents.length,
                  (index) {
                    final student = filteredStudents[index];
                    return [
                      (index + 1).toString(),
                      student['student']['hall_ticket'],
                      student['student']['first_name'] +
                              " " +
                              student['student']['last_name'] ??
                          'N/A',
                      student['student']['phone_number'] ?? 'N/A',
                      student['status'] ? "Present" : "Absent",
                    ];
                  },
                ),
                cellStyle: pw.TextStyle(fontSize: 10),
                headerStyle: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(color: PdfColors.blue),
                rowDecoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    try {
      Directory directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final file = File(
          '${directory.path}/${branches[0]["period"]["date"]} - ${branches[0]["period"]["subject"]["name"]}.pdf');
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);
      showSnackBar(context, 'PDF saved to ${file.path}', true);
    } catch (e) {
      showSnackBar(context, 'Failed to save pdf', false);
    }
  }
}
