import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_resizer/controllers/saveImage.dart';
import 'package:image_resizer/res/Colors.dart';
import 'package:image/image.dart' as img;
import 'package:image_resizer/views/custom_widgets/custom_buttons.dart';
import 'dart:ui' as ui;
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DimensionScreen extends StatefulWidget{
  final imageFile;

  const DimensionScreen({super.key, required this.imageFile});
  @override
  State<DimensionScreen> createState() => _DimensionScreenState();
}

class _DimensionScreenState extends State<DimensionScreen> {

  TextEditingController selectedHeight = TextEditingController();
  TextEditingController selectedWidth = TextEditingController();

  GlobalKey _containerKey = GlobalKey();

  bool fixedRatio = true;
  int simplifiedWidth = 0;
  int simplifiedHeight = 0;

  double artBoardHeight = 1024;
  double artBoardWidth = 1024;

  Color selectedColor = Colors.grey;

  PhotoViewController photoViewController = PhotoViewController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSelectedDimension();
  }

  getSelectedDimension() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      selectedHeight.text =  (prefs.getInt('artBoardHeight') ?? 1024).toString();
      selectedWidth.text =  (prefs.getInt('artBoardWidth') ?? 1024).toString();
    });

    if(fixedRatio){
      try{
        calculateRatio(int.parse(selectedWidth.text.trim()), int.parse(selectedHeight.text.trim()));
      }
      catch(error){
        debugPrint(error.toString());
      }
    }

    changeArtBoardDimension();

  }

  changeArtBoardDimension(){

    if(selectedHeight.text.isNotEmpty && selectedWidth.text.isNotEmpty){

      double maxSize = MediaQuery.of(context).size.width * 0.8;

      if(double.parse(selectedWidth.text) == double.parse(selectedHeight.text)){
        artBoardHeight = maxSize;
        artBoardWidth = maxSize;
      }
      else if (double.parse(selectedWidth.text) > double.parse(selectedHeight.text)){
        artBoardWidth = maxSize;
        artBoardHeight = double.parse(selectedHeight.text) / (double.parse(selectedWidth.text)/maxSize);
      }
      else{
        artBoardHeight = maxSize;
        artBoardWidth = double.parse(selectedWidth.text) / (double.parse(selectedHeight.text)/maxSize);
      }

    }

    setState(() {});

  }

  saveArtBoardDimension() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('artBoardHeight', int.parse(selectedHeight.text.trim()));
    prefs.setInt('artBoardWidth', int.parse(selectedWidth.text.trim()));
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

  void showColorPicker() {
    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Pick a color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            paletteType: PaletteType.hueWheel,
            onColorChanged: (value) {
              setState(() {
                selectedColor = value;
              });
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height -40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20,),
                RepaintBoundary(
                  key: _containerKey,
                  child: ClipRect(
                    child: SizedBox(
                      width: artBoardWidth,
                      height: artBoardHeight,
                      child: PhotoView(
                        backgroundDecoration: BoxDecoration(
                          color: selectedColor,
                        ),
                        enablePanAlways: true,
                        disableGestures: false,
                        enableRotation: true,
                        controller: photoViewController,
                        imageProvider: FileImage(widget.imageFile),
                      ),
                    ),
                  ),
                ),
                const Expanded(child: SizedBox(),),
                const SizedBox(height: 15,),
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
                            calculateRatio(int.parse(selectedWidth.text.trim()), int.parse(selectedHeight.text.trim()));
                          }
                          catch(error){
                            debugPrint(error.toString());
                          }
                        }

                      },
                    ),
                    const Text('Fix Aspect Ratio'),
                    const Expanded(child: SizedBox(),),
                    InkWell(
                      onTap: () {
                        showColorPicker();
                      },
                      child:  Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedColor
                        ),
                      ),
                    )
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
                            if(fixedRatio && selectedWidth.text.isNotEmpty){
                              int height = ((int.parse(selectedWidth.text) / simplifiedWidth) * simplifiedHeight).toInt();
                              selectedHeight.text = height.toString();
                            }
                          },
                          onTapOutside: (event) {
                            changeArtBoardDimension();
                            saveArtBoardDimension();
                          },
                          onEditingComplete: () {
                            changeArtBoardDimension();
                            saveArtBoardDimension();
                          },
                          decoration: InputDecoration(
                              labelText: 'Select Width',
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor,width: 2)
                              ),
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  showDialog(context: context, builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: primaryColor,
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizeMenu('240', selectedWidth, true),
                                          SizeMenu('360', selectedWidth, true),
                                          SizeMenu('480', selectedWidth, true),
                                          SizeMenu('720', selectedWidth, true),
                                          SizeMenu('1080', selectedWidth, true),
                                          SizeMenu('1440', selectedWidth, true),
                                          SizeMenu('2160', selectedWidth,true)
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
                            if(fixedRatio && selectedHeight.text.isNotEmpty){
                              int width = ((int.parse(selectedHeight.text.trim()) / simplifiedHeight) * simplifiedWidth).toInt();
                              selectedWidth.text = width.toString();
                            }

                          },
                          onTapOutside: (event) {
                            changeArtBoardDimension();
                            saveArtBoardDimension();
                          },
                          onEditingComplete: () {
                            changeArtBoardDimension();
                            saveArtBoardDimension();
                          },
                          decoration: InputDecoration(
                              labelText: 'Select Height',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
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
                                          SizeMenu('240', selectedHeight, false),
                                          SizeMenu('360', selectedHeight, false),
                                          SizeMenu('480', selectedHeight, false),
                                          SizeMenu('720', selectedHeight, false),
                                          SizeMenu('1080', selectedHeight, false),
                                          SizeMenu('1440', selectedHeight, false),
                                          SizeMenu('2160', selectedHeight, false)
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

                  changeArtBoardDimension();
                  saveArtBoardDimension();

                  if(selectedHeight.text.isNotEmpty && selectedWidth.text.isNotEmpty){

                    RenderRepaintBoundary boundary = _containerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                    ui.Image boundaryImage = await boundary.toImage();
                    ByteData? byteData = await boundaryImage.toByteData(format: ui.ImageByteFormat.png);

                    if(byteData != null){
                      Uint8List captureImage = byteData.buffer.asUint8List();

                      img.Image image = img.decodeImage(captureImage)!;

                      img.Image thumbnail = img.copyResize(image, width: int.parse(selectedWidth.text), height: int.parse(selectedHeight.text));

                      await saveImage(img.encodePng(thumbnail), context);
                    }
                  }
                })

              ],
            ),
          ),
        ),
      ),
    );
  }

  SizeMenu(String txt, TextEditingController controller, bool width){
    return InkWell(
      onTap: (){
        controller.text = txt;
        if(fixedRatio){

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

        changeArtBoardDimension();
        saveArtBoardDimension();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(txt, style: const TextStyle(color: Colors.white, fontSize: 20),),
      ),
    );
  }
}

