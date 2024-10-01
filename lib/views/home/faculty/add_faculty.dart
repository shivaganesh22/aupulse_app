import 'dart:convert';
import 'dart:io';
import 'package:aupulse/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:flutter/cupertino.dart';

class AddFacultyView extends StatefulWidget {
  const AddFacultyView({Key? key}) : super(key: key);

  @override
  State<AddFacultyView> createState() => _AddFacultyViewState();
}

class _AddFacultyViewState extends State<AddFacultyView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Select Image Source'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Gallery'),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  DateTime _date = DateTime(2000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        title: const Text("Add Faculty"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _usernameController,
                  onChanged: (value) => {
                    _emailController.text =
                        value.toLowerCase() + "@anurag.edu.in"
                  },
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter username';
                    }
                    // Add custom validation for date format if needed
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    // Add custom validation for date format if needed
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _firstNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    hintText: 'Enter first name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter first name';
                    }
                    // Add custom validation for date format if needed
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    hintText: 'Enter last name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter last name';
                    }
                    // Add custom validation for date format if needed
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _dobController,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(1965),
                      lastDate: DateTime(2010),
                    );
                    if (picked != null) {
                      setState(() {
                        _date = picked;
                        _dobController.text = DateFormat('yyyy-MM-dd')
                            .format(picked); // Format as needed
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Date Of Birth',
                    hintText: 'Select date of birth',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter date of birth';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _departmentController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Department Name',
                    hintText: 'Enter department name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter department name';
                    }
                    // Add custom validation for date format if needed
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    hintText: 'Enter mobile number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter mobile number';
                    }
                    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                      return 'Please enter a valid mobile number ';
                    }
                    return null;
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                SizedBox(height: 16.0),
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 2.0,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
                if (_image == null)
                     Text('No image selected.'),
                  
                ElevatedButton(
                  onPressed: () => _showImageSourceActionSheet(context),
                  child: Text('Select Profile Photo'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _handleadd,
                  child: Text('Add'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleadd() async {
    if (_formKey.currentState!.validate()) {
      final Uri apiUrl =
          Uri.parse("https://aupulse-api.vercel.app/api/faculty/");
      final request = http.MultipartRequest('POST', apiUrl);
      request.fields.addAll({
        'username': _usernameController.text,
        'email': _emailController.text,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'date_of_birth': _dobController.text,
        'password': _passwordController.text,
        'department': _departmentController.text,
        'phone_number': _phoneController.text,
        'status': true.toString()
      });

      if (_image != null) {
        final mimeTypeData =
            lookupMimeType(_image!.path, headerBytes: [0xFF, 0xD8])?.split('/');
        final file = await http.MultipartFile.fromPath(
          'profile',
          _image!.path,
          contentType: mimeTypeData != null
              ? MediaType(mimeTypeData[0], mimeTypeData[1])
              : null,
        );
        request.files.add(file);
        EasyLoading.show(status: "Adding");
      }
      try {
        final response = await request.send();
        print(response);
        final responseData = await response.stream.bytesToString();
        final parsedData = jsonDecode(responseData);

        if (response.statusCode == 200) {
          EasyLoading.showSuccess("Success");
          context.pop(); // Navigate to students page after success
        } else {
          EasyLoading.showError("Failed");
          if (parsedData is Map<String, dynamic>) {
            parsedData.forEach((key, value) {
              if (value is List && value.isNotEmpty && value[0] is String) {
                showSnackBar(context, key + value[0] as String, false);
              }
            });
          }
        }
      } catch (e) {
        print("Error: $e");
      } finally {
        EasyLoading.dismiss();
      }
    }
  }
}
