import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PuzzleGame extends StatefulWidget {
  const PuzzleGame({super.key});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  List<String> imagePieces = [];
  File pickedImage = File("");
  bool gameOver = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 139, 138, 139),
      appBar: AppBar(
        title: const Text("Image Puzzle Game"),
        actions: [
          IconButton(onPressed: shufflePieces, icon: const Icon(Icons.shuffle)),
          IconButton(onPressed: pickImage, icon: const Icon(Icons.add_a_photo),)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!gameOver) ...[
              const SizedBox(height: 60,),
              Expanded(
                child: GridView.count(
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  crossAxisCount: 3,
                  children: imagePieces.map((piece) {
                    return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color.fromARGB(255, 39, 37, 37), width: 3),
                        ),
                        child: Image.file(File(piece), fit: BoxFit.fill,));
                  }).toList(),
                ),
              ),
          
            ] else ...[
              const Text('You solved the puzzle!'),
              ElevatedButton(
                onPressed: resetGame,
                child: const Text('Play Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      pickedImage = File(pickedFile.path);
      cropImage();
    }
  }

  void cropImage() {
    // Crop image
    img.Image? image = img.decodeImage(pickedImage.readAsBytesSync());
    final size = min(image!.width, image.height);
    final peiceSize = size ~/ sqrt(8); 
    img.Image thumb = img.copyCrop(image,
        x: 0, y: 0, width: size, height: size);

    // Split image into pieces
    List<img.Image> pieces = [];
    for (int x = 0; x < sqrt(8); x++) {
      for (int y = 0; y < sqrt(8); y++) {
        img.Image piece = img.copyCrop(thumb,
            x: x * peiceSize,
            y: y * peiceSize,
            width: peiceSize,
            height: peiceSize);
        pieces.add(piece);
      }
    }

    // Save pieces and update state
    List<String> piecePaths = [];
    for (int i = 0; i < pieces.length; i++) {
      Uint8List pngBytes = img.encodePng(pieces[i]);
      final file = File(
          '${pickedImage.path}_${DateTime.now().millisecondsSinceEpoch}_$i.png')
        ..writeAsBytesSync(pngBytes);
      piecePaths.add(file.path);
    }

    setState(() {
      imagePieces = piecePaths;
    });

    //shufflePieces();
  }

  Future<String> getPath() async {
    final directory = await getTemporaryDirectory();

    return directory.path;
  }

  void shufflePieces() {
    imagePieces.shuffle();
    setState(() {});
  }

  void resetGame() {
    setState(() {
      gameOver = false;
      imagePieces.clear();
    });
  }
}
