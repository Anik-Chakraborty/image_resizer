import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_resizer/controllers/saveImage.dart';
import 'package:image_resizer/res/Colors.dart';
import 'package:image_resizer/views/custom_widgets/custom_buttons.dart';

class CompressScreen extends StatefulWidget{
  final imageFile;

  const CompressScreen({super.key, required this.imageFile});
  @override
  State<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends State<CompressScreen> {
  String originalSize = '';
  double compressQuality = 50, imageSize =0;

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
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ],
          ),

          Text('File Name : ${widget.imageFile.path.split('/').last}', overflow: TextOverflow.ellipsis,),
          const SizedBox(height: 10,),
          Text('Original Size : $originalSize Kb'),
          const SizedBox(height: 20,),
          Text('Compressed Quality : ${compressQuality.round()}'),
          Slider(
            value: compressQuality,
            max: 100,
            divisions: 9,
            min: 10,
            activeColor: primaryColor,
            thumbColor: primaryColor,
            label: compressQuality.round().toString(),
            onChanged: (double value) {
              setState(() {
                compressQuality = value;
                // compressedSize = ((imageSize * compressQuality)/100).toStringAsFixed(2);
              });
            },
          ),
          const SizedBox(height: 20,),
          buttons(context, 'Compress', () async{
            var result = await FlutterImageCompress.compressWithFile(
              widget.imageFile.absolute.path,
              quality: compressQuality.toInt(),
            );
            if(result!=null){
              await saveImage(await widget.imageFile.readAsBytes(), context);
            }
          }),
        ],
      ),
    );
  }
}