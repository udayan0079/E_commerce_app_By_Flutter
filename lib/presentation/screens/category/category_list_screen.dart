import 'package:flutter/material.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_urls.dart';
import '../../../data/models/category_model.dart';
import '../../../data/services/network_caller.dart';
import '../../widgets/category_card.dart';
import 'product_list_by_category_screen.dart';

/// Full screen displaying all live categories from API /categories in a grid.
class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final response = await NetworkCaller.getRequest(url: AppUrls.categories);
    if (response.isSuccess && response.responseData != null) {
      final List results = response.responseData['data']['results'] ?? [];
      final parsed = results.map((item) => CategoryModel.fromJson(item)).toList();
      if (mounted) {
        setState(() {
          _categories = CategoryModel.filterMeaningfulCategories(parsed);
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(AppConstants.screenPadding),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 14,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return CategoryCard(
                  category: cat,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListByCategoryScreen(
                          categoryName: cat.title,
                          categoryId: cat.id,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
