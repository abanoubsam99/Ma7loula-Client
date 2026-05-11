import 'package:flutter/material.dart';

class CategoriesModel {
  String? pic;
  String? title;
  VoidCallback onTap;
  CategoriesModel(
      {required this.pic, required this.title, required this.onTap});
}
