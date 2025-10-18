
import 'package:hive/hive.dart';
part 'item_model.g.dart';

@HiveType(typeId: 2)
class ItemsModel extends HiveObject {

  @HiveField(0)
  String name;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  int unitprice;

  ItemsModel({
    required this.name,
    required this.quantity,
    required this.unitprice,
  });
}
