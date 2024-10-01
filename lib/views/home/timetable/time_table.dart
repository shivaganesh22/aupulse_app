import 'dart:convert';
import 'dart:io';
import 'package:aupulse/main.dart';
import 'package:excel/excel.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TimeTableView extends StatefulWidget {
  final String id;
  const TimeTableView({Key? key, required this.id}) : super(key: key);

  @override
  State<TimeTableView> createState() => _TimeTableViewState();
}

class _TimeTableViewState extends State<TimeTableView> {
  List<dynamic> branches = []; // Changed to dynamic list for API response
  bool is_loading = false;
  DateTime _date1 = DateTime.now();
  String? date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  late String semesterid, sectionid, batchid, branchid;
  Future<void> apicall() async {
    http.Response res = await http.get(Uri.parse(
        "https://aupulse-api.vercel.app/api/timetabledisplay/?section=${widget.id}&subject_semester=${semesterid}&date=${date}"));
    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);
      if (mounted)
        setState(() {
          branches = jsonData; // Update data with API response
        });
    }
    is_loading = true;
  }

  @override
  void initState() {
    super.initState();
    // final state = GoRouterState.of(context);
    // semesterid = state.pathParameters["semesterid"] ?? "";

    // apicall();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch semesterid from GoRouterState in didChangeDependencies
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
          title: Row(
            children: [
              Text("TimeTable"),
              SizedBox(
                  width:
                      8), // Adjust the space between the title text and the icon
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.calendar_today), // Calendar icon
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _date1,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _date1 = picked;
                          date = DateFormat('yyyy-MM-dd').format(picked);
                          apicall();
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(child: Text("Students"), value: "students"),
                PopupMenuItem(child: Text("Subjects"), value: "subjects"),
                PopupMenuItem(child: Text("Timings"), value: "timings"),
                PopupMenuItem(
                    child: Text("Daily report(.pdf)"), value: "reportPdf"),
                PopupMenuItem(
                    child: Text("Daily report(.xlsx)"), value: "reportExcel"),
                PopupMenuItem(
                    child: Text("Custom range report"), value: "custom"),
              ],
              onSelected: (String newValue) {
                // Update the selected index based on the selected menu item
                switch (newValue) {
                  case "timings":
                    context
                        .push(context.namedLocation("Timing", pathParameters: {
                      "branchid": branchid,
                      "semesterid": semesterid,
                      "sectionid": sectionid,
                      "batchid": batchid
                    }));
                    break;
                  case "students":
                    context.push(
                        context.namedLocation("Students", pathParameters: {
                      "branchid": branchid,
                      "semesterid": semesterid,
                      "sectionid": sectionid,
                      "batchid": batchid
                    }));
                    break;
                  case "subjects":
                    context.push(
                        context.namedLocation("Subjects", pathParameters: {
                      "branchid": branchid,
                      "semesterid": semesterid,
                      "sectionid": sectionid,
                      "batchid": batchid
                    }));
                    break;
                  case "reportPdf":
                    generatePdf();
                    break;
                  case "reportExcel":
                    generateExcel();
                    break;
                  case "custom":
                    context
                  .push(context.namedLocation("generateReport", pathParameters: {
                "branchid": branchid,
                "semesterid": semesterid,
                "sectionid": sectionid,
                "batchid": batchid
              }));
                    break;
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await context
                  .push(context.namedLocation("addTimetable", pathParameters: {
                "branchid": branchid,
                "semesterid": semesterid,
                "sectionid": sectionid,
                "batchid": batchid
              }));
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
                        "No results",
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
                            title: Text(
                                "${branch['subject']["name"]} " +
                                    "${branch['subject']["is_lab"] ? "(Lab)" : ""}",
                                style: TextStyle(
                                    fontWeight: FontWeight
                                        .bold)), // Displaying batch ID
                            subtitle: Text(
                                "${branch['timing']["start"]}-${branch['timing']["end"]}"), // Displaying start and end dates
                            leading: CircleAvatar(
                              child: Text((index + 1)
                                  .toString()), // Displaying batch ID in CircleAvatar
                            ),
                            trailing:
                                PopupMenuButton(onSelected: (value) async {
                              if (value == 'edit') {
                                await context.push(
                                    context.namedLocation("editTimetable",
                                        pathParameters: {
                                          "branchid": branchid,
                                          "semesterid": semesterid,
                                          "sectionid": sectionid,
                                          "batchid": batchid,
                                          "timetableid": branch["id"].toString()
                                        }),
                                    extra: branch);
                                apicall();
                              }

                              if (value == 'delete')
                                _handleDelete(branch["id"]);
                            }, itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  child: Text("Edit"),
                                  value: "edit",
                                ),
                                PopupMenuItem(
                                  child: Text("Delete"),
                                  value: "delete",
                                ),
                              ];
                            }),
                            onTap: () {
                              context.push(
                                context.namedLocation("Attendance",
                                    pathParameters: {
                                      "branchid": branchid,
                                      "semesterid": semesterid,
                                      "sectionid": sectionid,
                                      "batchid": batchid,
                                      "periodid": branch["id"].toString()
                                    }),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ],
          ),
        ));
  }

  Future<void> _handleDelete(id) async {
    EasyLoading.show(status: "Deleting");
    http.Response res = await http.delete(
        Uri.parse("https://aupulse-api.vercel.app/api/timetable/${id}/"));
    if (res.statusCode == 204) {
      EasyLoading.showSuccess("Success");
      apicall();
    } else {
      EasyLoading.showSuccess("Failed");
    }
  }

  Future<void> generatePdf() async {
    final pdf = pw.Document();
    List<dynamic> attendanceData = [];
    EasyLoading.show(status: "Generating");
    // Fetch attendance data from API
    http.Response res = await http.get(Uri.parse(
        "https://aupulse-api.vercel.app/api/attendancedisplay/?section=${widget.id}&date=${date}&semester=${semesterid}"));

    if (res.statusCode == 200) {
      attendanceData = jsonDecode(res.body) as List;
    }

    // Process attendance data
    Map<String, Map<String, bool>?> studentAttendance = {};

    for (var record in attendanceData) {
      String hallTicket = record['student']['hall_ticket'];
      if (!studentAttendance.containsKey(hallTicket)) {
        studentAttendance[hallTicket] = {};
      }
      studentAttendance[hallTicket]![record['period']['id'].toString()] =
          record['status'];
    }
    // Generate PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                  child: pw.Text(
                'Attendance Report - ${date}',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              )),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                headers: [
                  'S.No',
                  'Hall Ticket',
                  'Name',
                  ...branches.map((period) =>
                      '${period['subject']["name"]}\n${period['subject']["is_lab"] ? "(Lab)" : ""}'),
                  'Presents',
                  'Absents',
                  'Total',
                ],
                data: List<List<String>>.generate(
                  studentAttendance.length,
                  (index) {
                    String hallTicket = studentAttendance.keys.elementAt(index);
                    var student = attendanceData.firstWhere(
                        (record) =>
                            record['student']['hall_ticket'] == hallTicket,
                        orElse: () => null)?['student'];
                    int presents = studentAttendance[hallTicket]
                            ?.values
                            .where((status) => status)
                            .length ??
                        0;
                    int absents = studentAttendance[hallTicket]
                            ?.values
                            .where((status) => !status)
                            .length ??
                        0;

                    return [
                      (index + 1).toString(),
                      hallTicket,
                      student != null
                          ? '${student['first_name']} ${student['last_name']}'
                          : 'Unknown',
                      ...branches.map((period) {
                        String periodId = period['id'].toString();
                        if (studentAttendance[hallTicket]
                                ?.containsKey(periodId) ??
                            false) {
                          return studentAttendance[hallTicket]![periodId] ==
                                  true
                              ? 'Present'
                              : 'Absent';
                        } else {
                          return 'Not Taken';
                        }
                      }),
                      presents.toString(),
                      absents.toString(),
                      (presents + absents).toString(),
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

      final file = File('${directory.path}/Daily report-${date}.pdf');
      await file.writeAsBytes(await pdf.save());
      EasyLoading.showSuccess("Success");
      await OpenFile.open(file.path);
      showSnackBar(context, 'PDF saved to ${file.path}', true);
    } catch (e) {
      EasyLoading.showError("Failed");
      showSnackBar(context, 'Failed to save pdf', false);
    }
  }

  Future<void> generateExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    List<dynamic> attendanceData = [];
    EasyLoading.show(status: "Generating");
    // Fetch attendance data from API
    http.Response res = await http.get(Uri.parse(
        "https://aupulse-api.vercel.app/api/attendancedisplay/?section=${widget.id}&date=${date}&semester=${semesterid}"));
    if (res.statusCode == 200) {
      attendanceData = jsonDecode(res.body) as List;
    }

    // Process attendance data
    Map<String, Map<String, bool>?> studentAttendance = {};

    for (var record in attendanceData) {
      String hallTicket = record['student']['hall_ticket'];
      if (!studentAttendance.containsKey(hallTicket)) {
        studentAttendance[hallTicket] = {};
      }
      studentAttendance[hallTicket]![record['period']['id'].toString()] =
          record['status'];
    }

    // Generate Excel
    // Header
    List<String> headers = [
      'S.No',
      'Hall Ticket',
      'Name',
      ...branches.map((period) =>
          '${period['subject']["name"]}${period['subject']["is_lab"] ? "(Lab)" : ""}'),
      'Presents',
      'Absents',
      'Total',
    ];

    for (int i = 0; i < headers.length; i++) {
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(headers[i]);
    }

    // Data
    int rowIndex = 1;
    studentAttendance.forEach((hallTicket, attendance) {
      var student = attendanceData.firstWhere(
          (record) => record['student']['hall_ticket'] == hallTicket,
          orElse: () => null)?['student'];
      int presents = attendance?.values.where((status) => status).length ?? 0;
      int absents = attendance?.values.where((status) => !status).length ?? 0;

      List<CellValue> rowData = [
        IntCellValue(rowIndex),
        TextCellValue(hallTicket),
        TextCellValue(student != null
            ? '${student['first_name']} ${student['last_name']}'
            : 'Unknown'),
        ...branches.map((period) {
          String periodId = period['id'].toString();
          if (attendance?.containsKey(periodId) ?? false) {
            return TextCellValue(
                attendance![periodId] == true ? 'Present' : 'Absent');
          } else {
            return TextCellValue('Not Taken');
          }
        }),
        IntCellValue(presents),
        IntCellValue(absents),
        IntCellValue(presents + absents),
      ];

      for (int i = 0; i < rowData.length; i++) {
        sheetObject
            .cell(
                CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex))
            .value = rowData[i];
      }

      rowIndex++;
    });

    try {
      Directory directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final file = File('${directory.path}/Daily report-${date}.xlsx');
      await file.writeAsBytes(excel.encode()!);
      EasyLoading.showSuccess("Success");
      await OpenFile.open(file.path);
      showSnackBar(context, 'Excel file saved to ${file.path}', true);
    } catch (e) {
      EasyLoading.showError("Failed");
      showSnackBar(context, 'Failed to save Excel file', false);
    }
  }
}
