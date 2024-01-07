import 'package:flutter/material.dart';
import 'package:image_resizer/res/Colors.dart';

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