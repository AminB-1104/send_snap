import 'package:hive/hive.dart';
part 'expense_model.g.dart';


@HiveType(typeId: 0)
class ExpenseModel {

  @HiveField(0)
  int id;

  @HiveField(1)
  String merchant;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  num total;

  @HiveField(4)
  String currency;

  @HiveField(5)
  String category;

  @HiveField(6)
  String note;
  
  @HiveField(7)
  String imagepath;

  ExpenseModel({
    required this.id,
    required this.merchant,
    required this.date,
    required this.total,
    required this.currency,
    required this.category,
    required this.note,
    required this.imagepath,
  });
}
