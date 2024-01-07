import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_resizer/res/Colors.dart';
import 'package:image_resizer/views/HomeScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

Future<void> saveImage(Uint8List imageBytes, context) async {
  String folderName = 'Image Resizer';
  // Get the base directory for saving the image
  final appDir = await getApplicationDocumentsDirectory();

  // Create the custom folder if it doesn't exist
  final customFolder = Directory('${appDir.path}/$folderName');
  if (!customFolder.existsSync()) {
    customFolder.createSync();
  }

  // Generate a unique file name for the image
  final fileName = DateTime.now().millisecondsSinceEpoch.toString();

  // Create the file path with the custom folder and file name
  final filePath = '${customFolder.path}/$fileName.png';

  // Write the image bytes to the file
  File(filePath).writeAsBytesSync(imageBytes);

  // Save the image to the gallery
  final result = await ImageGallerySaver.saveFile(filePath);
  print('Image saved to gallery: $result');

  showDialog(context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
    surfaceTintColor: Colors.white,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Image Saved Successfully', style: TextStyle(color: primaryColor, fontSize: 20),),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.width * 0.7,
          child: Image.file(
            File(filePath),
            fit: BoxFit.contain,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog when OK is pressed
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(),));
              },
              child: const Text('OK', style: TextStyle(color: primaryColor),),
            ),
          ],
        )
      ],
    ),
  ),);

}