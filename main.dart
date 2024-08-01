import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Student Registration Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: StudentRegistrationApp(),
      ),
    ),
  );
}

class StudentRegistrationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Registration Form'),
      ),
      body: StudentRegistrationForm(),
    );
  }
}

class StudentRegistrationForm extends StatefulWidget {
  @override
  _StudentRegistrationFormState createState() =>
      _StudentRegistrationFormState();
}

class _StudentRegistrationFormState extends State<StudentRegistrationForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController percentage10thController =
      TextEditingController();
  DateTime? _dob;
  String? _marksheetPdfPath;

  Future<void> _pickMarksheetPdf() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _marksheetPdfPath = result.files.single.path;
        });
      }
    }
  }

  Future<void> submitForm() async {
    // Check if a file is selected for marksheet PDF
    if (_marksheetPdfPath == null) {
      print('Please select a marksheet PDF file');
      return;
    }

    // Check if date of birth is selected
    if (_dob == null) {
      print('Please select the date of birth');
      return;
    }

    // Format date of birth
    String formattedDob = _dob!.toIso8601String().split('T')[0];

    final String apiUrl = 'http://127.0.0.1:8000/api/register/';

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    // Add form fields
    request.fields['name'] = nameController.text;
    request.fields['dob'] = formattedDob;
    request.fields['father_name'] = fatherNameController.text;
    request.fields['address'] = addressController.text;
    request.fields['student_class'] = classController.text;
    request.fields['percentage_10th'] = percentage10thController.text;

    // Add marksheet PDF file
    request.files.add(
      http.MultipartFile(
        'marksheet_pdf',
        File(_marksheetPdfPath!).readAsBytes().asStream(),
        File(_marksheetPdfPath!).lengthSync(),
        filename: _marksheetPdfPath!.split('/').last,
      ),
    );

    // Send request
    var response = await request.send();

    // Check response
    if (response.statusCode == 201) {
      // Data was successfully stored
      print('Data stored successfully');
      // Clear text controllers and reset variables
      nameController.clear();
      fatherNameController.clear();
      addressController.clear();
      classController.clear();
      percentage10thController.clear();
      setState(() {
        _dob = null;
        _marksheetPdfPath = null;
      });
    } else {
      // Error occurred
      print('Error storing data: ${response.stream.bytesToString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: 'Name'),
                        maxLength: 100,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: fatherNameController,
                        decoration:
                            InputDecoration(labelText: 'Father\'s Name'),
                        maxLength: 100,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your father\'s name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: addressController,
                        decoration: InputDecoration(labelText: 'Address'),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: classController,
                        decoration: InputDecoration(labelText: 'Class'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your class';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: percentage10thController,
                        decoration:
                            InputDecoration(labelText: '10th Percentage'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your 10th percentage';
                          }
                          return null;
                        },
                      ),
                      ListTile(
                        title: Text(_dob == null
                            ? 'Date of Birth'
                            : _dob!.toLocal().toString().split(' ')[0]),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _dob = picked;
                            });
                          }
                        },
                      ),
                      ListTile(
                        title: Text(_marksheetPdfPath == null
                            ? 'Upload Marksheet PDF'
                            : 'File Selected: $_marksheetPdfPath'),
                        trailing: Icon(Icons.upload_file),
                        onTap: _pickMarksheetPdf,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: submitForm,
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
