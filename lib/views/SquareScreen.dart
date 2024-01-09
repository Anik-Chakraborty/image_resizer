import 'package:flutter/material.dart';
import 'package:image_resizer/controllers/saveImage.dart';
import 'package:image_resizer/res/Colors.dart';
import 'package:image_resizer/views/custom_widgets/custom_buttons.dart';
import 'package:image/image.dart' as img;

class SquareScreen extends StatefulWidget {
  final imageFile;

  const SquareScreen({super.key, required this.imageFile});

  @override
  State<SquareScreen> createState() => _SquareScreenState();
}

class _SquareScreenState extends State<SquareScreen> {
  int squareSize = 50;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(30),
              width: MediaQuery.of(context).size.width - 20,
              height: MediaQuery.of(context).size.width - 20,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/square_image.jpg'),
                      fit: BoxFit.fill,
                      alignment: Alignment.center)),
              child: Center(
                child: Image.file(
                  widget.imageFile,
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.width * 0.6,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20,),
            Text('Square Side : $squareSize', overflow: TextOverflow.ellipsis,),
            const SizedBox(height: 10,),
            Slider(
              value: squareSize.toDouble(),
              max: 1000,
              divisions: 950,
              min: 50,
              activeColor: primaryColor,
              thumbColor: primaryColor,
              label: squareSize.round().toString(),
              onChanged: (double value) {
                setState(() {
                  squareSize = value.toInt();
                });
              },
            ),
            const SizedBox(height: 20,),
            buttons(context, 'Square', () async{
              img.Image image = img.decodeImage(widget.imageFile.readAsBytesSync())!;

              img.Image thumbnail = img.copyResize(image, width: squareSize, height: squareSize);

              await saveImage(img.encodePng(thumbnail), context);
            }),
          ],
        ),
      ),
    );
  }
}
