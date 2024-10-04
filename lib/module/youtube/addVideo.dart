import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zuriel/models/youtube.dart';

class AddVideo extends StatefulWidget {
  static const route_name = "AddVideo";
  const AddVideo({super.key});
  @override
  _AddVideoState createState() => _AddVideoState();
}

class _AddVideoState extends State<AddVideo> {
  Uint8List? fileBytes;
  String? fileName;
  bool isUploading = false;
  final _linkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isRequired = false;

  @override
  void initState() {
    super.initState();
    // _linkController.text = "https://www.youtube.com/watch?v=EUKhHJlIveY";
    _linkController.addListener(() {
      setState(() {
        _isRequired = _linkController.text.isNotEmpty;
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
        FirebaseFirestore.instance.collection('youtubevideodata');
    await collection.add(insertData);
  }

  Future<void> _addVideoData() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing Data')),
      );

      setState(() {
        isUploading = true;
      });

      try {
        final String videolink = _linkController.text;
        final YoutubeData youtubeMetaData =
            await YoutubeDataFetcher.fetchMetadata(videolink);

        Map<String, dynamic> insertDataObj = youtubeMetaData.toJson();
        await insertDBData(insertDataObj);
        setState(() {
          fileBytes = null;
          fileName = null;
          _linkController.text = "";
        });

        // Display a success message or navigate to another screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF uploaded successfully!')),
        );
        setState(() {
          isUploading = false;
        });
      } catch (e) {
        print(e);
        // Display an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error Adding Video. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16.0),
      height: 170,
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
                      controller: _linkController,
                      decoration: InputDecoration(
                        hintText: 'Enter YouTube Link',
                        errorText: _isRequired ? null : 'Link is required',
                      ),
                      maxLength: 250,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a YouTube link';
                        }
                        final regex = RegExp(
                          r'^(https?\:\/\/)?(www\.youtube\.com|youtu\.?be)\/.+$',
                        );
                        if (!regex.hasMatch(value)) {
                          return 'Please enter a valid YouTube link';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.video_camera_back_outlined),
                onPressed: isUploading ? null : _addVideoData,
                label: Text(isUploading ? 'Adding Video...' : "Add Video"),
              ),
            ],
          )),
    );
  }
}
