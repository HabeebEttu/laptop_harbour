import 'package:flutter/material.dart';

double getResponsiveFontSize(BuildContext context, double baseFontSize) {
  double screenWidth = MediaQuery.of(context).size.width;

  if (screenWidth > 1200) {
    return baseFontSize * 1.2;
  } else if (screenWidth > 600) {
    return baseFontSize * 1.1;
  } else {
    return baseFontSize;
  }
}
