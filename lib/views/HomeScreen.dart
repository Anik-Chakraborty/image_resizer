import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_resizer/controllers/saveImage.dart';
import 'package:image_resizer/views/CompressScreen.dart';
import 'package:image_resizer/views/DimensionScreen.dart';
import 'package:image_resizer/views/SavedImagesScreen.dart';
import 'package:image_resizer/views/SquareScreen.dart';
import 'package:image_resizer/views/custom_widgets/custom_buttons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_editor_plus/options.dart' as o;

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/home_bg.jpg'),
              fit: BoxFit.fill),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(30),
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.width * 0.3,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      image: const DecorationImage(
                        image: AssetImage('assets/images/resize-image.png'),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                      borderRadius: BorderRadius.circular(100)),
                ),
              ],
            ),
            const SizedBox(
              width: 30,
            ),
            buttons(context, 'Crop/Flip/Rotate', () async {
              await handelPermission();
              Uint8List? data = await pickImage();
              openImageEditor(data);
            }),
            buttons(context, 'Compress', () async {
              openImageCompressor();
            }),
            buttons(context, 'Change Dimension', () {
              openImageDimension();
            }),
            buttons(context, 'Square', () async {
              await handelPermission();
              openSquareImageEditor();
            }),
            buttons(context, 'Saved Images', () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SavedImagesScreen(),
                  ));
            }),
          ],
        ),
      ),
    );
  }

  openImageEditor(data) async {
    if (data != null) {
      final editedImage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageEditor(
            image: data, // <-- Uint8List of an image
          ),
        ),
      );
      print(editedImage.runtimeType);
      saveImage(editedImage, context);
      // File('my_image.jpg').writeAsBytes(editedImage);
    }
  }

  openSquareImageEditor() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SquareScreen(
            imageFile: File(image.path), // <-- Uint8List of an image
          ),
        ),
      );
    }
  }

  openImageCompressor() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final editedImage = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CompressScreen(imageFile: File(image.path))),
      );
    }
  }

  openImageDimension() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final editedImage = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DimensionScreen(imageFile: File(image.path))),
      );
    }
  }

  handelPermission() async {
    bool androidExistNotSave = false;
    bool isGranted;
    if (Platform.isAndroid) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;
      if (androidExistNotSave) {
        isGranted = await (sdkInt > 33 ? Permission.photos : Permission.storage)
            .request()
            .isGranted;
      } else {
        isGranted =
            sdkInt < 29 ? await Permission.storage.request().isGranted : true;
      }
    } else {
      isGranted = await Permission.photosAddOnly.request().isGranted;
    }
  }

  pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    return (image != null) ? await image.readAsBytes() : null;
  }
}
