import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:send_snap/Data/Database/catergoryseeder.dart';
import 'package:send_snap/Data/Models/category_model.dart';
import 'package:send_snap/Data/Models/expense_model.dart';
import 'package:send_snap/Data/Models/item_model.dart';

class HiveService {
  static late Box<ExpenseModel> _expenseBox;
  static late Box<CategoryModel> _categoryBox;
  static late Box<ItemsModel> _itemsBox;

  // Initialize Hive and open all boxes
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    Hive.registerAdapter(ExpenseModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(ItemsModelAdapter());

    _expenseBox = await Hive.openBox<ExpenseModel>('expenses');
    _categoryBox = await Hive.openBox<CategoryModel>('categories');
    _itemsBox = await Hive.openBox<ItemsModel>('items');

    await CategorySeeder.seedCategories(); // ensure predefined categories exist
  }

  // Getters
  static Box<ExpenseModel> get expenses => _expenseBox;
  static Box<CategoryModel> get categories => _categoryBox;
  static Box<ItemsModel> get items => _itemsBox;

  // --------------------------
  // Expense CRUD Helpers
  // --------------------------

  static Future<int> addExpense(ExpenseModel expense) async {
    return await _expenseBox.add(expense);
  }

  static Future<void> updateExpense(ExpenseModel expense) async {
    await expense.save();
  }

  static Future<void> deleteExpense(ExpenseModel expense) async {
    await expense.delete();
  }

  static Future<void> clearAllExpenses() async {
    await _expenseBox.clear();
  }
}
