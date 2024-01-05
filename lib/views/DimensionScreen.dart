import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_resizer/res/Colors.dart';
import 'dart:typed_data';
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

    print(width);
    print(height);

    calculateRatio(width, height);

  }

  calculateRatio(int width, int height) {
    int gcdValue = calculateGCD(width, height);

    // Calculate the simplified ratio
    simplifiedWidth = width ~/ gcdValue;
    simplifiedHeight = height ~/ gcdValue;

    print('$simplifiedWidth:$simplifiedHeight');
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
                    },
                  ),
                  const Text('Fix Aspect Ratio')
                ],),
              ),
              const SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.all(10),
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
                        onChanged: (value){
                          if(fixedRatio){
                            selectedHeight.text = ((int.parse(selectedWidth.text) / simplifiedWidth) * simplifiedHeight).toString();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Select Width',
                          suffixIcon: IconButton(
                            onPressed: () {
                              showDialog(context: context, builder: (context) {
                                return AlertDialog(
                                  content: Column(
                                    children: [
                                      SizeMenu('240', selectedWidth),
                                      SizeMenu('360', selectedWidth),
                                      SizeMenu('480', selectedWidth),
                                      SizeMenu('720', selectedWidth),
                                      SizeMenu('1080', selectedWidth),
                                      SizeMenu('1440', selectedWidth),
                                      SizeMenu('2160', selectedWidth)
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value){
                          if(fixedRatio){
                            selectedWidth.text = ((int.parse(selectedHeight.text) / simplifiedHeight) * simplifiedWidth).toString();
                          }
                        },
                        decoration: InputDecoration(
                            hintText: 'Select Height',
                            suffixIcon: IconButton(
                              onPressed: () {
                                showDialog(context: context, builder: (context) {
                                  return AlertDialog(
                                    content: Column(
                                      children: [
                                        SizeMenu('240', selectedHeight),
                                        SizeMenu('360', selectedHeight),
                                        SizeMenu('480', selectedHeight),
                                        SizeMenu('720', selectedHeight),
                                        SizeMenu('1080', selectedHeight),
                                        SizeMenu('1440', selectedHeight),
                                        SizeMenu('2160', selectedHeight)
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
              buttons(context, 'Save', () async{
                print(simplifiedHeight);
                print(simplifiedWidth);
              }),

            ],
          ),
        ),
      ),
    );
  }
}

SizeMenu(String txt, TextEditingController controller){
  return InkWell(
    onTap: (){
      controller.text = txt;
    },
    child: Text(txt),
  );
}
