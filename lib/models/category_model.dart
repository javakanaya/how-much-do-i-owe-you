// models/category_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryModel {
  final String categoryId;
  final String name;
  final String icon;
  final String color;

  CategoryModel({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.color,
  });

  // Convert CategoryModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'name': name,
      'icon': icon,
      'color': color,
    };
  }

  // Create CategoryModel from Firestore document
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return CategoryModel(
      categoryId: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      color: data['color'] ?? '#2176FF', // Default blue color
    );
  }

  // Create a copy of CategoryModel with some fields changed
  CategoryModel copyWith({
    String? categoryId,
    String? name,
    String? icon,
    String? color,
  }) {
    return CategoryModel(
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  // Helper to convert stored color string to Color object
  Color getColorObject() {
    try {
      return Color(int.parse(color.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF2176FF); // Default blue color
    }
  }

  // Predefined categories for initial app setup
  static List<CategoryModel> getPredefinedCategories() {
    return [
      CategoryModel(
        categoryId: 'food',
        name: 'Food',
        icon: '🍔',
        color: '#FF9800', // Orange
      ),
      CategoryModel(
        categoryId: 'entertainment',
        name: 'Entertainment',
        icon: '🎬',
        color: '#9C27B0', // Purple
      ),
      CategoryModel(
        categoryId: 'shopping',
        name: 'Shopping',
        icon: '🛍️',
        color: '#2196F3', // Blue
      ),
      CategoryModel(
        categoryId: 'transportation',
        name: 'Transportation',
        icon: '🚗',
        color: '#4CAF50', // Green
      ),
      CategoryModel(
        categoryId: 'utilities',
        name: 'Utilities',
        icon: '💡',
        color: '#FFC107', // Amber
      ),
      CategoryModel(
        categoryId: 'other',
        name: 'Other',
        icon: '📝',
        color: '#607D8B', // Blue Grey
      ),
    ];
  }
}
