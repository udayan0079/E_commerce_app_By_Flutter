import 'package:flutter/material.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_urls.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/network_caller.dart';
import '../../widgets/product_card.dart';
import '../product/product_details_screen.dart';

/// Products catalog filtered by selected category name or category ID.
class ProductListByCategoryScreen extends StatefulWidget {
  final String categoryName;
  final String? categoryId;

  const ProductListByCategoryScreen({
    super.key,
    required this.categoryName,
    this.categoryId,
  });

  @override
  State<ProductListByCategoryScreen> createState() => _ProductListByCategoryScreenState();
}

class _ProductListByCategoryScreenState extends State<ProductListByCategoryScreen> {
  List<ProductModel> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final url = (widget.categoryId != null && widget.categoryId!.isNotEmpty)
        ? AppUrls.productsByCategory(widget.categoryId!)
        : AppUrls.products;

    final response = await NetworkCaller.getRequest(url: url);
    if (response.isSuccess && response.responseData != null) {
      final List results = response.responseData['data']['results'] ?? [];
      if (mounted) {
        setState(() {
          _products = results
              .map((item) => ProductModel.fromJson(item))
              .toList();
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
        title: Text(widget.categoryName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('No products found'))
              : GridView.builder(
                  padding: const EdgeInsets.all(AppConstants.screenPadding),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsScreen(product: product),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
