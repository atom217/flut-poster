import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String icon;

  Category({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class Quote {
  final String id;
  final String text;
  final String author;
  final String categoryId;

  Quote({
    required this.id,
    required this.text,
    this.author = 'Dr. B.R. Ambedkar',
    required this.categoryId,
  });
}

class UserProfile {
  final String name;
  final String subtitle;
  final String? photoUrl;

  UserProfile({
    required this.name,
    required this.subtitle,
    this.photoUrl,
  });

  // Added copyWith for state updates
  UserProfile copyWith({
    String? name,
    String? subtitle,
    String? photoUrl,
  }) {
    return UserProfile(
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

class TemplateModel {
  final String id;
  final String name;
  final Color backgroundColor;
  final Color textColor;
  final String categoryId; // For filtering
  final bool isPremium; // For premium features
  final List<Color>? gradientColors;
  final Alignment? gradientBegin;
  final Alignment? gradientEnd;

  TemplateModel({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.textColor,
    required this.categoryId,
    this.isPremium = false,
    this.gradientColors,
    this.gradientBegin,
    this.gradientEnd,
  });
}
