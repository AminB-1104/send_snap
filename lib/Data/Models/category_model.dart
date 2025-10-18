import 'package:hive/hive.dart';
part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {

  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(3)
  String iconsvg;

  CategoryModel({required this.id, required this.name, required this.iconsvg});
}
