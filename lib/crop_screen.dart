import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class CropScreen extends StatefulWidget {
  const CropScreen({super.key});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  File? _imageFile;
  final Rect _cropRect = const Rect.fromLTWH(0, 0, 200, 200);

  // Image picker
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }

  // Crop image
  void _cropImage() {
    if(_imageFile != null){
      final imageFile = _imageFile!;
      final cropRect = _cropRect;
      final bytes = imageFile.readAsBytesSync();
      final image = img.decodeImage(bytes);
      final pieceSize = image!.width ~/ 3; 
    final cropped = img.copyCrop(image, 
      x: cropRect.left.toInt(), 
      y: cropRect.top.toInt(),
      width: pieceSize,
      height: pieceSize
    );

    final pngBytes = img.encodePng(cropped);
    final croppedFile = File('${imageFile.path}_cropped.png')..writeAsBytesSync(pngBytes);

    setState(() {
      _imageFile = croppedFile;
    });
    }
    
  }

  void _clearImage(){
    setState(() {
        _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _imageFile != null
        ? Stack(
          children: [
            Image.file(_imageFile!),

            // Positioned(

            //   child: Container(
            //     width: double.infinity,
            //     height: 200,
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.red, width: 4)
            //     ),
            //     child: GestureDetector(
            //       onPanEnd: (details) {
                    
            //         log("details: ${details.velocity}");
            //       },
            //     )
            //   )
            // )
          ],
        )

        : Center(child: ElevatedButton.icon(
          onPressed: _pickImage, 
          icon: const Icon(Icons.image), 
          label: const Text("Pick image"))),
      
      floatingActionButton: _imageFile != null ? FloatingActionButton(
        onPressed: _cropImage,
        child: const Icon(Icons.crop),
      ) : FloatingActionButton(onPressed: _clearImage, child: const Icon(Icons.clear)));
    
  }
}