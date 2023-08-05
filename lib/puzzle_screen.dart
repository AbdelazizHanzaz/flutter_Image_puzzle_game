import 'dart:io';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({super.key});

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  File? _image;
  List<Widget> _puzzlePieces = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Game'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _image == null
                ? const Center(child: Text('No image selected'))
                : PuzzleBoard(pieces: _puzzlePieces),
          ),
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text('Select Image'),
          ),
        ],
      ),
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile!.path);
      _splitImage();
    });
  }

  void _splitImage() {
    if (_image == null) return;
    final imageFile = _image!;
    final bytes = imageFile.readAsBytesSync();
    final image = img.decodeImage(bytes);

    final size = min(image!.width, image.height);
    const int numberOfPieces = 4;
    final pieceSize = size ~/ numberOfPieces;

    _puzzlePieces = [];

    for (int x = 0; x < numberOfPieces; x++) {
      for (int y = 0; y < numberOfPieces; y++) {
        final pieceImage = _cropImage(image, x * pieceSize, y * pieceSize, pieceSize);
        _puzzlePieces.add(PuzzlePiece(image: pieceImage));
      }
    }

    _shufflePieces();
  }

  File _cropImage(img.Image image, int x, int y, int pieceSize) {
    
    final cropped =
        img.copyCrop(image, x: x, y: y, width: pieceSize, height: pieceSize);

    final pngBytes = img.encodePng(cropped);
    developer.log("x: $x and y: $y");
    final croppedFile = File('${_image!.path}_cropped{$x}.png')
      ..writeAsBytesSync(pngBytes);

    return croppedFile;
  }

  void _shufflePieces() {
    _puzzlePieces.shuffle();
  }
}

class PuzzleBoard extends StatelessWidget {
  final List<Widget> pieces;

  const PuzzleBoard({super.key, required this.pieces});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: pieces.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        //childAspectRatio: 2,
        crossAxisCount: sqrt(pieces.length).toInt(),
      ),
      itemBuilder: (context, index) {
        return pieces[index];
      },
    );
  }
}

class PuzzlePiece extends StatelessWidget {
  final File image;

  const PuzzlePiece({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Image.file(image, fit: BoxFit.cover,);
  }
}
