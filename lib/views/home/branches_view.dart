import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class BranchView extends StatefulWidget {
  final String id;
  const BranchView({Key? key, required this.id}) : super(key: key);

  @override
  State<BranchView> createState() => _BranchViewState();
}

class _BranchViewState extends State<BranchView> {
  List<dynamic> branches = []; // Changed to dynamic list for API response
  bool is_loading = false;
  late String batchid,semesterid;
  Future<void> apicall() async {
    http.Response res = await http.get(Uri.parse(
        "https://aupulse-api.vercel.app/api/branch/?batch=${batchid}"));

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
    // apicall();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = GoRouterState.of(context);
    batchid = state.pathParameters["batchid"] ?? "";
    semesterid = state.pathParameters["semesterid"] ?? "";

    apicall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigoAccent,
          title: Text("Branches"),
         ),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await context.push(context.namedLocation("addBranch",
                  pathParameters: {
                    "semesterid":semesterid,
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
                            title: Text("${branch['name']}",
                                style: TextStyle(
                                    fontWeight: FontWeight
                                        .bold)), // Displaying batch ID
                            // subtitle: Text(
                            //     "Name: ${branch['name']}"), // Displaying start and end dates
                            leading: CircleAvatar(
                              child: Text((index + 1)
                                  .toString()), // Displaying batch ID in CircleAvatar
                            ),
                            trailing:
                                PopupMenuButton(onSelected: (value) async {
                              if (value == 'edit') {
                                await context.push(
                                    context.namedLocation("editBranch",
                                        pathParameters: {
                                          "semesterid":semesterid,
                                          "batchid": batchid,
                                          "branchid": branch["id"].toString()
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
                              // context.goNamed("semesters", pathParameters: {
                              //   "id": branch["id"].toString()
                              // });
                              context.push(context.namedLocation("sections",
                                  pathParameters: {
                                    "branchid": branch["id"].toString(),
                                    "semesterid":semesterid,
                                    "batchid": batchid
                                  }));
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
    http.Response res = await http
        .delete(Uri.parse("https://aupulse-api.vercel.app/api/branch/${id}/"));
    if (res.statusCode == 204) {
      EasyLoading.showSuccess("Success");
      apicall();
    } else {
      EasyLoading.showSuccess("Failed");
    }
  }
}
