import 'package:flutter/material.dart';

double getResponsiveFontSize(BuildContext context, double baseFontSize) {
  double screenWidth = MediaQuery.of(context).size.width;
  double scaleFactor = screenWidth / 400;
  return baseFontSize * scaleFactor;
}
