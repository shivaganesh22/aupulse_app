import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<dynamic> completed = []; // Changed to dynamic list for API response
  List<dynamic> not_completed = []; // Changed to dynamic list for API response
  bool is_loading = false;
  Future<void> apicall() async {
    http.Response res = await http.get(Uri.parse(
        "https://aupulse-api.vercel.app/api/batch/?is_completed=true"));
    http.Response res1 = await http.get(Uri.parse(
        "https://aupulse-api.vercel.app/api/batch/?is_completed=false"));
    if (res.statusCode == 200) {
      final jsonData = jsonDecode(res.body);
      if (mounted)
        setState(() {
          completed = jsonData; // Update data with API response
        });
    }
    if (res1.statusCode == 200) {
      final jsonData = jsonDecode(res1.body);
      if (mounted)
        setState(() {
          not_completed = jsonData; // Update data with API response
        });
    }
    is_loading = true;
  }

  @override
  void initState() {
    super.initState();
    apicall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigoAccent,
          title: const Text("Home"),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(child: Text("Faculty"), value: "faculty"),
              ],
              onSelected: (String newValue) {
                // Update the selected index based on the selected menu item
                switch (newValue) {
                  case "faculty":
                    context.push(
                        context.namedLocation("Faculty", pathParameters: {}));
                    break;
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await context.push(context.namedLocation(
                "addBatch",
              ));
              apicall();
            },
            backgroundColor: Colors.indigoAccent,
            child: const Icon(Icons.add)),
        body: RefreshIndicator(
          onRefresh: apicall,
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              is_loading && completed.isEmpty && not_completed.isEmpty
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
                      itemCount: not_completed.length,
                      itemBuilder: (context, index) {
                        var batch = not_completed[index];
                        return Card(
                          color: Colors.cyan[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 2,
                          child: ListTile(
                            title: Text("${batch['start']} - ${batch['end']}",
                                style: TextStyle(
                                    fontWeight: FontWeight
                                        .bold)), // Displaying batch ID
                            leading: CircleAvatar(
                              child: Text((index + 1)
                                  .toString()), // Displaying batch ID in CircleAvatar
                            ),
                            trailing:
                                PopupMenuButton(onSelected: (value) async {
                              if (value == 'edit') {
                                await context.push(
                                    context.namedLocation("editBatch",
                                        pathParameters: {
                                          "batchid": batch["id"].toString()
                                        }),
                                    extra: batch);
                                apicall();
                              }
                              if (value == 'delete') _handleDelete(batch["id"]);
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
                              context.push(context.namedLocation("semesters",
                                  pathParameters: {
                                    "batchid": batch["id"].toString()
                                  }));
                            },
                          ),
                        );
                      },
                    ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: completed.length,
                itemBuilder: (context, index) {
                  var batch = completed[index];
                  return Card(
                    color: Colors.green[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      title: Text(
                        "${batch['start']} - ${batch['end']}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ), // Displaying batch ID
                      
                      leading: CircleAvatar(
                        child: Text((not_completed.length + index + 1)
                            .toString()), // Displaying batch ID in CircleAvatar
                      ),
                      trailing: PopupMenuButton(onSelected: (value) async {
                        if (value == 'edit') {
                          await context.push(
                              context.namedLocation("editBatch",
                                  pathParameters: {
                                    "batchid": batch["id"].toString()
                                  }),
                              extra: batch);
                          apicall();
                        }
                        if (value == 'delete') _handleDelete(batch["id"]);
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
                        context.push(context.namedLocation("semesters",
                            pathParameters: {
                              "batchid": batch["id"].toString()
                            }));
                        // context.goNamed("branches",
                        //     pathParameters: {"id": batch["id"].toString()});
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
        .delete(Uri.parse("https://aupulse-api.vercel.app/api/batch/${id}/"));
    if (res.statusCode == 204) {
      EasyLoading.showSuccess("Success");
      apicall();
    } else {
      EasyLoading.showSuccess("Failed");
    }
  }
}
