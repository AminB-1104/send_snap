import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:send_snap/UI/Components/appbar.dart';

class ImagePickerCamera extends StatefulWidget {
  const ImagePickerCamera({super.key});

  @override
  State<ImagePickerCamera> createState() => _ImagePickerCameraState();
}

class _ImagePickerCameraState extends State<ImagePickerCamera> {
  @override
  void initState() {
    super.initState();
    pickImage();
  }

  File? _image;

  final _picker = ImagePicker();

  pickImage() async {
    final pickedImage = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      maxHeight: 66,
      maxWidth: 50,
    );

    if (pickedImage != null) {
      _image = File(pickedImage.path);
      setState(() {});
    } else {
      return AlertDialog(content: Center(child: Text("Error loading image!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: _image == null
            ? const Text("No Image Picked!", style: TextStyle(fontSize: 25))
            : Image.file(_image!),
      ),
    );
  }
}
