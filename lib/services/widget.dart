import 'package:flutter/material.dart';

//static class
class WG {

  static Text text(double size, String label, [Color? color, double? height]) {
    return Text(label, style: TextStyle(
      fontSize: size,
      //color: (color == null) ? Colors.black : color,
      color: color,
      height: height,
    ));
  }

  ///gap for padding or margin
  static EdgeInsets gap(double pixel) {
    return EdgeInsets.all(pixel);
  }

  /// get divider for list view
  /// @height line height
  static Divider divider([double height = 5]) {
    return Divider(height: height, thickness: 1);
  }

} //class
