import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String iconsvg;

  @HiveField(3)
  int iconcolor;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconsvg,
    required this.iconcolor,
  });

  Color get color => Color(iconcolor);
}
