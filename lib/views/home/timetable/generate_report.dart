// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:io';
import 'package:aupulse/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class GenerateReportView extends StatefulWidget {
  const GenerateReportView({Key? key}) : super(key: key);

  @override
  State<GenerateReportView> createState() => _GenerateReportViewState();
}

class _GenerateReportViewState extends State<GenerateReportView> {
  DateTime _date1 = DateTime.now();
  DateTime _date2 = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  late String semesterid, sectionid, batchid, branchid;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch semesterid from GoRouterState in didChangeDependencies
    final state = GoRouterState.of(context);
    branchid = state.pathParameters["branchid"] ?? '';
    batchid = state.pathParameters["batchid"] ?? "";
    sectionid = state.pathParameters["sectionid"] ?? "";
    semesterid = state.pathParameters["semesterid"] ?? "";
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
                  firstDate: _date1,
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
              onPressed: _handlePdf,
              child: Text('Generate Pdf'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _handleExcel,
              child: Text('Generate Excel'),
            ),
          ]),
        ),
      ),
    );
  }

  void _handlePdf() async {
    if (_formKey.currentState!.validate()) {
      generatePdfBetweenDates(
          _startDateController.text, _endDateController.text);
    }
  }

  void _handleExcel() async {
    if (_formKey.currentState!.validate()) {
      generateExcelBetweenDates(
          _startDateController.text, _endDateController.text);
    }
  }

  Future<void> generatePdfBetweenDates(String startDate, String endDate) async {
    final pdf = pw.Document();
    List<dynamic> timetableData = [];
    List<dynamic> attendanceData = [];
    EasyLoading.show(status: "Generating");

    // Fetch timetable data from API
    http.Response timetableRes = await http.get(Uri.parse(
        "https://aupulse-api.vercel.app/api/timetabledisplay/?section=${sectionid}&subject_semester=${semesterid}&date_range_after=${startDate}&date_range_before=${endDate}"));

    if (timetableRes.statusCode == 200) {
      timetableData = jsonDecode(timetableRes.body) as List;
    }

    // Fetch attendance data from API
    http.Response attendanceRes = await http.get(Uri.parse(
        "https://aupulse-api.vercel.app/api/attendancedisplay/?section=${sectionid}&semester=${semesterid}&date_range_after=${startDate}&date_range_before=${endDate}"));

    if (attendanceRes.statusCode == 200) {
      attendanceData = jsonDecode(attendanceRes.body) as List;
    }

    // Process timetable and attendance data
    Map<String, Map<String, int>> studentAttendanceCounts = {};
    Map<String, String> subjects = {};
    Map<String, int> subjectCounts = {};

    for (var record in timetableData) {
      String subjectId = record['subject']['id'].toString();
      String subjectName = record['subject']['name'];
      subjects[subjectId] = subjectName;
      subjectCounts[subjectId] = (subjectCounts[subjectId] ?? 0) + 1;
    }

    for (var record in attendanceData) {
      String hallTicket = record['student']['hall_ticket'];
      String subjectId = record['period']['subject']['id'].toString();

      if (!studentAttendanceCounts.containsKey(hallTicket)) {
        studentAttendanceCounts[hallTicket] = {};
      }

      if (!studentAttendanceCounts[hallTicket]!.containsKey(subjectId)) {
        studentAttendanceCounts[hallTicket]![subjectId] = 0;
      }

      if (record['status'] == true) {
        studentAttendanceCounts[hallTicket]![subjectId] =
            studentAttendanceCounts[hallTicket]![subjectId]! + 1;
      }
    }

    int totalPeriods = timetableData.length;

    // Generate PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                  child: pw.Text(
                'Attendance Report - $startDate to $endDate',
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
                  ...subjects.entries.map((entry) =>
                      '${entry.value} (${subjectCounts[entry.key]})'),
                  'Total Presents',
                  'Total Absents',
                  'Total Percentage\n($totalPeriods)',
                ],
                data: List<List<String>>.generate(
                  studentAttendanceCounts.length,
                  (index) {
                    String hallTicket =
                        studentAttendanceCounts.keys.elementAt(index);
                    var student = attendanceData.firstWhere(
                        (record) =>
                            record['student']['hall_ticket'] == hallTicket,
                        orElse: () => null)?['student'];

                    int totalPresents = studentAttendanceCounts[hallTicket]!
                        .values
                        .reduce((a, b) => a + b);
                    int totalAbsents = totalPeriods - totalPresents;
                    double totalPercentage =
                        (totalPresents / totalPeriods) * 100;

                    return [
                      (index + 1).toString(),
                      hallTicket,
                      student != null
                          ? '${student['first_name']} ${student['last_name']}'
                          : 'Unknown',
                      ...subjects.keys.map((subjectId) {
                        return studentAttendanceCounts[hallTicket]!
                                .containsKey(subjectId)
                            ? studentAttendanceCounts[hallTicket]![subjectId]
                                .toString()
                            : '0';
                      }).toList(),
                      totalPresents.toString(),
                      totalAbsents.toString(),
                      '${totalPercentage.toStringAsFixed(2)}%',
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
          '${directory.path}/AttendanceReport-${startDate}_to_${endDate}.pdf');
      await file.writeAsBytes(await pdf.save());
      EasyLoading.showSuccess("Success");
      await OpenFile.open(file.path);
      showSnackBar(context, 'PDF saved to ${file.path}', true);
    } catch (e) {
      EasyLoading.showError("Failed");
      showSnackBar(context, 'Failed to save pdf', false);
    }
  }

  Future<void> generateExcelBetweenDates(
      String startDate, String endDate) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    List<dynamic> timetableData = [];
    List<dynamic> attendanceData = [];
    EasyLoading.show(status: "Generating");

    // Fetch timetable data from API
    http.Response timetableRes = await http.get(Uri.parse(
        "https://aupulse-api.vercel.app/api/timetabledisplay/?section=${sectionid}&subject_semester=${semesterid}&date_range_after=${startDate}&date_range_before=${endDate}"));

    if (timetableRes.statusCode == 200) {
      timetableData = jsonDecode(timetableRes.body) as List;
    }

    // Fetch attendance data from API
    http.Response attendanceRes = await http.get(Uri.parse(
        "https://aupulse-api.vercel.app/api/attendancedisplay/?section=${sectionid}&semester=${semesterid}&date_range_after=${startDate}&date_range_before=${endDate}"));

    if (attendanceRes.statusCode == 200) {
      attendanceData = jsonDecode(attendanceRes.body) as List;
    }

    // Process timetable and attendance data
    Map<String, Map<String, int>> studentAttendanceCounts = {};
    Map<String, String> subjects = {};
    Map<String, int> subjectCounts = {};

    for (var record in timetableData) {
      String subjectId = record['subject']['id'].toString();
      String subjectName = record['subject']['name'];
      subjects[subjectId] = subjectName;
      subjectCounts[subjectId] = (subjectCounts[subjectId] ?? 0) + 1;
    }

    for (var record in attendanceData) {
      String hallTicket = record['student']['hall_ticket'];
      String subjectId = record['period']['subject']['id'].toString();

      if (!studentAttendanceCounts.containsKey(hallTicket)) {
        studentAttendanceCounts[hallTicket] = {};
      }

      if (!studentAttendanceCounts[hallTicket]!.containsKey(subjectId)) {
        studentAttendanceCounts[hallTicket]![subjectId] = 0;
      }

      if (record['status'] == true) {
        studentAttendanceCounts[hallTicket]![subjectId] =
            studentAttendanceCounts[hallTicket]![subjectId]! + 1;
      }
    }

    int totalPeriods = timetableData.length;

    // Generate Excel
    // Header
    List<String> headers = [
      'S.No',
      'Hall Ticket',
      'Name',
      ...subjects.entries
          .map((entry) => '${entry.value} (${subjectCounts[entry.key]})'),
      'Total Presents',
      'Total Absents',
      'Total Percentage ($totalPeriods)',
    ];

    for (int i = 0; i < headers.length; i++) {
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(headers[i]);
    }

    // Data
    int rowIndex = 1;
    studentAttendanceCounts.forEach((hallTicket, attendance) {
      var student = attendanceData.firstWhere(
          (record) => record['student']['hall_ticket'] == hallTicket,
          orElse: () => null)?['student'];

      int totalPresents = attendance.values.reduce((a, b) => a + b);
      int totalAbsents = totalPeriods - totalPresents;
      double totalPercentage = (totalPresents / totalPeriods) * 100;

      List<CellValue> rowData = [
        IntCellValue(rowIndex),
        TextCellValue(hallTicket),
        TextCellValue(student != null
            ? '${student['first_name']} ${student['last_name']}'
            : 'Unknown'),
        ...subjects.keys.map((subjectId) => IntCellValue(
            attendance.containsKey(subjectId) ? attendance[subjectId]! : 0)),
        IntCellValue(totalPresents),
        IntCellValue(totalAbsents),
        DoubleCellValue(totalPercentage),
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

      final file = File(
          '${directory.path}/AttendanceReport-${startDate}_to_${endDate}.xlsx');
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
