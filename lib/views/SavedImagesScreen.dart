import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SavedImagesScreen extends StatefulWidget {
  @override
  _SavedImagesScreenState createState() => _SavedImagesScreenState();
}

class _SavedImagesScreenState extends State<SavedImagesScreen> {
  List? imageFiles;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      String folderName = 'Image Resizer';
      final appDir = await getApplicationDocumentsDirectory();
      final customFolder = Directory('${appDir.path}/$folderName');

      setState(() {
        imageFiles = customFolder.listSync().map((e) => e.path).toList();
      });
    } catch (error) {
      imageFiles = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Images'),
      ),
      body: (imageFiles == null)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : (imageFiles != null && imageFiles!.isNotEmpty)
              ? GridView.builder(
                  itemCount: imageFiles!.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        // Display the selected image in a dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ImageDialog(imagePath: imageFiles![index]);
                          },
                        );
                      },
                      child: Image.file(
                        File(imageFiles![index]),
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.width * 0.25,
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text('No Image Available'),
                ),
    );
  }
}

class ImageDialog extends StatelessWidget {
  final String imagePath;

  ImageDialog({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Image Preview'),
      content: Container(
        width: double.maxFinite,
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog when OK is pressed
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}
