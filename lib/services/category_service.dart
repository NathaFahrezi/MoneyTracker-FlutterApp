import '../models/category_model.dart';

class CategoryService {
  static final List<CategoryModel> _categories = [
    CategoryModel(id: '1', name: 'Makanan'),
    CategoryModel(id: '2', name: 'Transportasi'),
    CategoryModel(id: '3', name: 'Belanja'),
    CategoryModel(id: '4', name: 'Gaji'),
  ];

  static List<CategoryModel> getCategories() {
    return _categories;
  }

  static void addCategory(String name) {
    _categories.add(
      CategoryModel(
        id: DateTime.now().toIso8601String(),
        name: name,
      ),
    );
  }

  static void removeCategory(String id) {
    _categories.removeWhere((cat) => cat.id == id);
  }
}
