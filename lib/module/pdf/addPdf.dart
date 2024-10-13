import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zuriel/tools/tools.dart';

class AddPdf extends StatefulWidget {
  static const route_name = "AddPdf";
  const AddPdf({super.key});
  @override
  _AddPdfState createState() => _AddPdfState();
}

class _AddPdfState extends State<AddPdf> {
  Uint8List? fileBytes;
  String? fileName;
  bool isUploading = false;
  double _uploadProgress = 0;
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _charCount = 0;
  bool _isRequired = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() {
      setState(() {
        _charCount = _descriptionController.text.length;
        _isRequired = _descriptionController.text.isNotEmpty;
      });
    });
  }

  Future<void> deleteFile(String filePath) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(filePath);
      await storageRef.delete();
      // print('File deleted successfully!');
    } catch (e) {
      // print('Error deleting file: $e');
    }
  }

  Future<void> insertDBData(Map<String, dynamic> insertData) async {
    final CollectionReference collection =
        FirebaseFirestore.instance.collection('pdfdata');
    await collection.add(insertData);
  }

  Future<void> _pickPDFFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        fileBytes = result.files.first.bytes;
        fileName = result.files.first.name;
      });
    }
  }

  Future<void> _uploadPDF() async {
    if (_formKey.currentState!.validate()) {
      if (fileBytes == null) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing Data')),
      );
      setState(() {
        isUploading = true;
      });
      final storageRef = FirebaseStorage.instance.ref().child('pdfs/$fileName');

      try {
        final uploadTask = storageRef.putData(fileBytes!);
        uploadTask.snapshotEvents.listen((event) {
          final progress = (event.bytesTransferred / event.totalBytes);

          setState(() {
            _uploadProgress = progress;
          });
        });

        final taskSnapshot = await uploadTask.whenComplete(() => null);
        FullMetadata metadata = await taskSnapshot.ref.getMetadata();

        final downloadURL = await taskSnapshot.ref.getDownloadURL();

        Map<String, dynamic> insertDataObj = {
          "filename": metadata.name.toString(),
          "title": _descriptionController.text,
          "updated": DateTime.now().millisecondsSinceEpoch,
          "url": downloadURL.toString(),
        };
        await insertDBData(insertDataObj);
        sendNotificationToTopic(
            "New PDF Available", insertDataObj["title"], "pdfdata",insertDataObj);

        setState(() {
          _uploadProgress = 0;
          fileBytes = null;
          fileName = null;
          _descriptionController.text = "";
        });

        // Display a success message or navigate to another screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF uploaded successfully!')),
        );
        setState(() {
          isUploading = false;
        });
      } catch (e) {
        // Display an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error uploading PDF. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16.0),
      height: 250,
      width: 400,
      child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Enter Title (max 50 characters)',
                        errorText: _isRequired ? null : 'Title is required',
                      ),
                      maxLength: 50,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                  ),
                  Text('$_charCount/50'),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.picture_as_pdf),
                    onPressed: _pickPDFFile,
                    label: const Text('Select PDF'),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.upload_file),
                    onPressed: isUploading ? null : _uploadPDF,
                    label: Text(isUploading ? "Uploading..." : 'Upload PDF'),
                  ),
                ],
              ),
              const Divider(),
              if (fileName != null) Text('Selected PDF: $fileName'),
              if (_uploadProgress > 0)
                LinearProgressIndicator(value: _uploadProgress),
            ],
          )),
    );
  }
}
