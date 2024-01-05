import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_resizer/res/Colors.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;
import 'package:image_resizer/views/HomeScreen.dart';

class DimensionScreen extends StatefulWidget{
  final imageFile;

  const DimensionScreen({super.key, required this.imageFile});
  @override
  State<DimensionScreen> createState() => _DimensionScreenState();
}

class _DimensionScreenState extends State<DimensionScreen> {

  TextEditingController selectedHeight = TextEditingController();
  TextEditingController selectedWidth = TextEditingController();

  bool fixedRatio = true;
  int simplifiedWidth = 0;
  int simplifiedHeight = 0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOriginalDimension();
  }

  getOriginalDimension() async{

    final data = await widget.imageFile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(data);

    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final int width = frameInfo.image.width;
    final int height = frameInfo.image.height;

    calculateRatio(width, height);

  }

  calculateRatio(int width, int height) {
    int gcdValue = calculateGCD(width, height);

    // Calculate the simplified ratio
    simplifiedWidth = width ~/ gcdValue;
    simplifiedHeight = height ~/ gcdValue;

  }

  int calculateGCD(int a, int b) {
    while (b != 0) {
      final int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
              const SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(children: [
                  Checkbox(
                    activeColor: primaryColor,
                    checkColor: Colors.white,
                    value: fixedRatio,
                    onChanged: (value) {
                      setState(() {
                        fixedRatio = value ?? false;
                      });

                      if(value!=null && value){
                        try{
                          int? widthCheck = int.parse(selectedWidth.text);
                          int? heightCheck = int.parse(selectedHeight.text);

                          if(widthCheck != 0 && widthCheck != null){
                            int height = ((int.parse(selectedWidth.text) / simplifiedWidth) * simplifiedHeight).toInt();
                            selectedHeight.text = height.toString();
                          }
                          else if(heightCheck !=0 && heightCheck !=null){
                            int width = ((int.parse(selectedHeight.text) / simplifiedHeight) * simplifiedWidth).toInt();
                            selectedWidth.text = width.toString();
                          }
                        }
                        catch(error){
                          debugPrint(error.toString());
                        }
                      }

                    },
                  ),
                  const Text('Fix Aspect Ratio')
                ],),
              ),
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.4,
                      child: TextField(
                        controller: selectedWidth,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.phone,
                        onChanged: (value){
                          if(fixedRatio){
                            int height = ((int.parse(selectedWidth.text) / simplifiedWidth) * simplifiedHeight).toInt();
                            selectedHeight.text = height.toString();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Select Width',
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(color: primaryColor,width: 2)
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              showDialog(context: context, builder: (context) {
                                return AlertDialog(
                                  backgroundColor: primaryColor,
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizeMenu('240', selectedWidth, fixedRatio, true),
                                      SizeMenu('360', selectedWidth, fixedRatio, true),
                                      SizeMenu('480', selectedWidth, fixedRatio, true),
                                      SizeMenu('720', selectedWidth, fixedRatio, true),
                                      SizeMenu('1080', selectedWidth, fixedRatio, true),
                                      SizeMenu('1440', selectedWidth, fixedRatio, true),
                                      SizeMenu('2160', selectedWidth, fixedRatio,true)
                                    ],
                                  ),
                                );
                              },);
                            },
                            icon: const Icon(Icons.expand_more_outlined),
                          )
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.4,
                      child: TextField(
                        controller: selectedHeight,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value){
                          if(fixedRatio){
                            int width = ((int.parse(selectedHeight.text) / simplifiedHeight) * simplifiedWidth).toInt();
                            selectedWidth.text = width.toString();
                          }
                        },
                        decoration: InputDecoration(
                            hintText: 'Select Height',
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: primaryColor,width: 2)
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                showDialog(context: context, builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: primaryColor,
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizeMenu('240', selectedHeight, fixedRatio, false),
                                        SizeMenu('360', selectedHeight, fixedRatio, false),
                                        SizeMenu('480', selectedHeight, fixedRatio, false),
                                        SizeMenu('720', selectedHeight, fixedRatio, false),
                                        SizeMenu('1080', selectedHeight, fixedRatio, false),
                                        SizeMenu('1440', selectedHeight, fixedRatio, false),
                                        SizeMenu('2160', selectedHeight, fixedRatio, false)
                                      ],
                                    ),
                                  );
                                },);
                              },
                              icon: const Icon(Icons.expand_more_outlined),
                            )
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30,),
              buttons(context, 'Save', () async{
                if(selectedHeight.text.isNotEmpty && selectedWidth.text.isNotEmpty){
                  img.Image image = img.decodeImage(widget.imageFile.readAsBytesSync())!;

                  img.Image thumbnail = img.copyResize(image, width: int.parse(selectedWidth.text), height: int.parse(selectedHeight.text));

                  await ImageGallerySaver.saveImage(img.encodePng(thumbnail));
                  Navigator.pop(context);
                }
              }),

            ],
          ),
        ),
      ),
    );
  }
  SizeMenu(String txt, TextEditingController controller, bool ratio, bool width){
    return InkWell(
      onTap: (){
        controller.text = txt;
        if(ratio){
          if(width){
            int height = ((int.parse(selectedWidth.text) / simplifiedWidth) * simplifiedHeight).toInt();
            selectedHeight.text = height.toString();
          }
          else{
            int width = ((int.parse(selectedHeight.text) / simplifiedHeight) * simplifiedWidth).toInt();
            selectedWidth.text = width.toString();
          }
        }
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(txt, style: const TextStyle(color: Colors.white, fontSize: 20),),
      ),
    );
  }
}

