import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// --- Simple Category model ---
/// If you already have one, remove this and import your own.
class CategoryModel {
  final int? id;
  final String? name;
  final String? slug;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryModel({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
    name: (json['name'] ?? '').toString(),
    slug: (json['slug'] ?? '').toString(),
    description: json['description']?.toString(),
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'].toString())
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'description': description,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
