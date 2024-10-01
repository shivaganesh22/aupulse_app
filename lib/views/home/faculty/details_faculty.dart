
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DetailsFacultyView extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;
  const DetailsFacultyView({Key? key, required this.id, required this.data})
      : super(key: key);

  @override
  State<DetailsFacultyView> createState() => _DetailsFacultyViewState();
}

class _DetailsFacultyViewState extends State<DetailsFacultyView> {
  bool? status = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<List> items = [
      ["First Name", widget.data["first_name"]],
      ["Last Name", widget.data["last_name"]],
      ["Date of Birth", widget.data["date_of_birth"]],
      ["Mobile Number", widget.data["phone_number"]],
      ["Department", widget.data["department"]],
      ["Status", widget.data["status"] ? "Active" : "Inactive"],
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        title: const Text("View Faculty"),
      ),
      body: Column(
        children: [
          SizedBox(height: 16,),
          Center(
            child: Container(
              width: 150, // Adjust the size as needed
              height: 150, // Adjust the size as needed
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 2.0, // Adjust the border width as needed
                ),
              ),
              child: CircleAvatar(
                radius: 50,
                
                backgroundImage: NetworkImage(
                  widget.data["profile"]!=null?widget.data["profile"]:"https://img.freepik.com/premium-vector/no-photo-available-vector-icon-default-image-symbol-picture-coming-soon-web-site-mobile-app_87543-14040.jpg"
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var branch = items[index];
                return Card(
                  color: Colors.cyan[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                  child: ListTile(
                    title: Text("${branch[0]} : ${branch[1]}",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    leading: CircleAvatar(
                      child: Text((index + 1).toString()),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
