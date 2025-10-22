// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:send_snap/Services/hive_service.dart';
import '../Models/category_model.dart';

class CategorySeeder {
  static Future<void> seedCategories() async {
    final box = HiveService.categories;

    if (box.isEmpty) {
      await box.addAll([
        CategoryModel(
          id: 1,
          name: 'Food',
          iconsvg: 'assets/icons/restaurant.svg',
          iconcolor: const Color(0xffFD3C4A).value,
        ),
        CategoryModel(
          id: 2,
          name: 'Transport',
          iconsvg: 'assets/icons/car.svg',
          iconcolor: const Color(0xff0077FF).value,
        ),
        CategoryModel(
          id: 3,
          name: 'Shopping',
          iconsvg: 'assets/icons/shopping-bag.svg',
          iconcolor: const Color(0xffFCAC12).value,
        ),
        CategoryModel(
          id: 5,
          name: 'Subscription',
          iconsvg: 'assets/icons/recurring-bill.svg',
          iconcolor: const Color(0xff7F3DFF).value,
        ),
      ]);
    }
  }
}
