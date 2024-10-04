import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zuriel/models/utils.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';

class ImageHandler extends StatefulWidget {
  final String storageRef;
  final String networkImage;
  bool showFileChange;
  DocumentReference? documentRefToUpdate;
  final Future<void> Function(String) callback;
  ImageHandler({
    super.key,
    required this.storageRef,
    required this.networkImage,
    required this.callback,
    this.showFileChange = false,
    this.documentRefToUpdate,
  });
  @override
  _ImageHandlerState createState() => _ImageHandlerState();
}

class _ImageHandlerState extends State<ImageHandler> {
  XFile? _image;
  Uint8List? fileBytes;
  String? fileName;
  bool _isUploading = false;
  String imageUrl = "";
  ImageAttr? imageNameFile;
  Future<void> _pickImage() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxHeight: 500, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
      });
      await uploadImage();
    }
  }

  uploadImage() async {
    setState(() {
      _isUploading = true;
    });
    try {
      if (_image != null) {
        final storageRef =
            FirebaseStorage.instance.ref().child(widget.storageRef);
        fileBytes = await _image!.readAsBytes();

        final uploadTask = storageRef.putData(fileBytes!);

        uploadTask.snapshotEvents.listen((event) {
          final progress = (event.bytesTransferred / event.totalBytes);

          setState(() {
          });
        });
        final taskSnapshot = await uploadTask.whenComplete(() => null);

        final downloadURL = await taskSnapshot.ref.getDownloadURL();
        FullMetadata metadata = await taskSnapshot.ref.getMetadata();
        await widget.callback(downloadURL);
        setState(() {
          imageUrl = downloadURL;
        });
      }
      setState(() {
        fileBytes = null;
        fileName = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully!')),
      );
      setState(() {
        _isUploading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isUploading = false;
      });
      // Display an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error uploading Image. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showFullButton = false;
    return Container(
        // height: 100,
        width: 400,
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: _image != null
                ? (kIsWeb
                    ? NetworkImage(
                        _image!.path,
                      )
                    : FileImage(File(_image!.path)))
                : NetworkImage(
                    widget.networkImage,
                  ),
            child: _image == null ? (widget.networkImage.isEmpty? Icon(Icons.person, size: 50):null) : null,
          ),
          SizedBox(
            height: 20,
          ),
          widget.showFileChange
              ? ElevatedButton.icon(
                  icon: _isUploading
                      ? Container(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.change_circle,
                          // size: 75,
                        ),
                  label: Text(_isUploading
                      ? 'Uploading Image...'
                      : 'Update Profile Image'),
                  onPressed: _isUploading ? null : _pickImage,
                )
              : SizedBox(),
        ]));
  }
}
