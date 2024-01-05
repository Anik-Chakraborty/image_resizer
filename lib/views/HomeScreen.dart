import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_resizer/res/Colors.dart';
import 'package:image_resizer/views/CompressScreen.dart';
import 'package:image_resizer/views/DimensionScreen.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
          buttons(context, 'Compress', () async{
            openImageCompressor();
          }),
          buttons(context, 'Change Dimension', () {
            openImageDimension();
          }),
        ],
      ),
    );
  }

  openImageEditor(data) async{
    if(data!=null){
      final editedImage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageEditor(
            image: data, // <-- Uint8List of an image
          ),
        ),
      );
      print(editedImage.runtimeType);
      _saveLocalImage(editedImage);
      // File('my_image.jpg').writeAsBytes(editedImage);
    }
  }

  openImageCompressor() async{
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if(image!=null){
      final editedImage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompressScreen(imageFile: File(image.path))
        ),
      );
    }
  }

  openImageDimension() async{
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if(image!=null){
      final editedImage = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DimensionScreen(imageFile: File(image.path))
        ),
      );
    }
  }

  _saveLocalImage(data) async {
    final result = await ImageGallerySaver.saveImage(data);
    print(result);
  }


  // Future<void> _saveImage(Uint8List modifiedImageData) async {
  //   final result = await ImageEditor.save(
  //     imageBytes: modifiedImageData,
  //     directory: "YourDirectory", // Set the directory where you want to save the image
  //     name: "modified_image.jpg", // Set the filename
  //   );
  //
  //   if (result != null && result) {
  //     print("Image saved successfully!");
  //   } else {
  //     print("Error saving image.");
  //   }
  // }

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

    return (image!=null) ? await image.readAsBytes() : null;
  }
}

Widget buttons(context, String txt, Function onPress) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    width: MediaQuery.of(context).size.width * 0.6,
    child: ElevatedButton(
        onPressed: () => onPress(),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          surfaceTintColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        ),
        child: Text(txt,
            style: const TextStyle(color: Colors.white, fontSize: 20))),
  );
}
