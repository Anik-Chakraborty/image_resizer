import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_resizer/res/Colors.dart';
import 'package:image_resizer/views/HomeScreen.dart';

class CompressScreen extends StatefulWidget{
  final imageFile;

  const CompressScreen({super.key, required this.imageFile});
  @override
  State<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends State<CompressScreen> {
  String originalSize = '';
  String compressedSize = '';
  double compressPercentage = 50, imageSize =0;
  bool compressed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSize();
  }

  getSize() async{
    Uint8List data = await widget.imageFile.readAsBytes();
    imageSize = (data.lengthInBytes / 1024);

    setState(() {
      originalSize = imageSize.toStringAsFixed(2);
      compressedSize = ((imageSize * compressPercentage)/100).toStringAsFixed(2);
    });
  }

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
                child: Image.file(
                  widget.imageFile, // Use the picked image file
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.width * 0.4 + 100,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),

          const Text('File Name : '),
          const SizedBox(height: 10,),
          Text('Original Size : $originalSize Kb'),
          const SizedBox(height: 20,),
          Visibility(
            visible: true,
              child: Text('Compressed Size : $compressedSize Kb')),
          Visibility(
              visible: compressed,
              child: const SizedBox(height: 20,)),
          Slider(
            value: compressPercentage,
            max: 100,
            divisions: 9,
            min: 10,
            activeColor: primaryColor,
            thumbColor: primaryColor,
            label: compressPercentage.round().toString(),
            onChanged: (double value) {
              setState(() {
                compressPercentage = value;
                compressedSize = ((imageSize * compressPercentage)/100).toStringAsFixed(2);
              });
            },
          ),
          const SizedBox(height: 20,),
          buttons(context, 'Compress', () async{
            var result = await FlutterImageCompress.compressWithFile(
              widget.imageFile.absolute.path,
              quality: compressPercentage.toInt(),
            );
            if(result!=null){
              print((result.lengthInBytes / 1024));
              final data = await ImageGallerySaver.saveImage(await widget.imageFile.readAsBytes(), quality: compressPercentage.toInt());

              print(data.runtimeType);
              setState(() {
                compressed = true;
                // compressedSize = ( data. / 1024).toStringAsFixed(2);
              });
            }
          }),
        ],
      ),
    );
  }
}