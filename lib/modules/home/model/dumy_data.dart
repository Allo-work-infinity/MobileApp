import 'dart:ui';
import 'package:job_finding/utils/k_images.dart';
import 'category_cart_model.dart';

final tagList = [
  "Software Engineer",
  "Web Developer",
  "UI Engineer",
  "UX Engineer",
  "Andriod Engineer",
  "IOS Engineer",
  "ASP .NET Engineer",
  "PHP Engineer",
  "Software Engineer",
  "Software Engineer",
];

final categoryList = [
  "Populaire",
];

List<CategoryCartModel> categoryCardList = [
  CategoryCartModel(
    id: 0,
    image: Kimages.figmaIcon,
    price: 10,
    address: "Dhaka, Bangladesh",
    title: "UX Desinger",
    tags: ["Full Time", "Remote"],
    color: const Color(0xff4FAA89),
  ),
  CategoryCartModel(
    id: 1,
    image: Kimages.shopifyIcon,
    price: 20,
    address: "Dhaka, Bangladesh",
    title: "Web Desinger",
    tags: ["Full Time", "Remote"],
    color: const Color.fromARGB(255, 109, 108, 108),
  ),
  CategoryCartModel(
    id: 2,
    image: Kimages.shopifyIcon,
    price: 15,
    address: "Dhaka, Bangladesh",
    title: "UI Desinger",
    tags: ["Full Time", "Remote"],
    color: const Color.fromARGB(255, 247, 224, 224),
  ),
];
