/// Live Category Model from API /categories
class CategoryModel {
  final String id;
  final String title;
  final String slug;
  final String icon;

  const CategoryModel({
    required this.id,
    required this.title,
    this.slug = '',
    this.icon = '',
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      icon: json['icon'] ?? '',
    );
  }

  /// Filters out test / spam entries (e.g. duplicate 'New Category', 'dfsd Category', 'sample Category')
  /// and keeps the 8 distinct, authentic categories from the senior's API:
  /// Apply, Books, Book, New Arrival, Special, Popular, Trampolins, Electronics.
  static List<CategoryModel> filterMeaningfulCategories(List<CategoryModel> list) {
    const targetTitles = [
      'apply',
      'books',
      'book',
      'new arrival',
      'special',
      'popular',
      'trampolins',
      'electronics',
    ];

    final Set<String> seen = {};
    final List<CategoryModel> filtered = [];

    for (final cat in list) {
      final t = cat.title.trim().toLowerCase();
      if (targetTitles.contains(t) && !seen.contains(t)) {
        seen.add(t);
        filtered.add(cat);
      }
    }

    return filtered.isNotEmpty ? filtered : list;
  }
}
