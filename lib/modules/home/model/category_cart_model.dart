// lib/modules/home/model/category_cart_model.dart
import 'package:flutter/material.dart';

class CategoryCartModel {
  final int id;
  final String image;
  final double price;
  final String address;
  final String title;
  final List<String> tags;
  final Color color;

  // NEW:
  final VoidCallback? onTap;
  final bool imageIsNetwork;

  CategoryCartModel({
    required this.id,
    required this.image,
    required this.price,
    required this.address,
    required this.title,
    required this.tags,
    required this.color,
    this.onTap,                // NEW
    this.imageIsNetwork = false, // NEW
  });
}
