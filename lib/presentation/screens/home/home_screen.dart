import 'package:flutter/material.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_urls.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/cart_service.dart';
import '../../../data/services/wishlist_service.dart';
import '../../../data/services/network_caller.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/category_card.dart';
import '../../widgets/product_card.dart';
import '../auth/sign_in_screen.dart';
import '../category/product_list_by_category_screen.dart';
import '../product/product_details_screen.dart';
import 'widgets/home_banner_slider.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/section_header.dart';

/// Live Home Screen wired to API with Profile modal & Logout support.
class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToCategory;

  const HomeScreen({
    super.key,
    this.onNavigateToCategory,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  bool _isLoadingCategories = true;
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchProducts();
    WishlistService.fetchWishlist();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _products;
    return _products.where((p) {
      final inTitle = p.title.toLowerCase().contains(query);
      final inDesc = p.description.toLowerCase().contains(query);
      return inTitle || inDesc;
    }).toList();
  }

  Future<void> _fetchCategories() async {
    final response = await NetworkCaller.getRequest(url: AppUrls.categories);
    if (response.isSuccess && response.responseData != null) {
      final List results = response.responseData['data']['results'] ?? [];
      final parsed = results.map((item) => CategoryModel.fromJson(item)).toList();
      if (mounted) {
        setState(() {
          _categories = CategoryModel.filterMeaningfulCategories(parsed);
          _isLoadingCategories = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _fetchProducts() async {
    final response = await NetworkCaller.getRequest(url: AppUrls.products);
    if (response.isSuccess && response.responseData != null) {
      final List results = response.responseData['data']['results'] ?? [];
      if (mounted) {
        setState(() {
          _products = results
              .map((item) => ProductModel.fromJson(item))
              .toList();
          _isLoadingProducts = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  void _showProfileModal() {
    if (!AuthService.isLoggedIn) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(AppConstants.screenPadding * 1.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(size: 80),
                const SizedBox(height: 16),
                const Text(
                  'Sign in to CraftyBay',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in or verify your email to access your cart, wishlist, and orders.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
                  },
                  child: const Text('Sign In'),
                ),
              ],
            ),
          );
        },
      );
      return;
    }

    final user = AuthService.userData ?? {};
    final fullName = '${user['first_name'] ?? 'User'} ${user['last_name'] ?? ''}'.trim();
    final email = user['email'] ?? 'demo@craftybay.com';
    final phone = user['phone'] ?? 'N/A';
    final city = user['city'] ?? 'N/A';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppConstants.screenPadding * 1.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primaryLight,
                child: const Icon(Icons.person, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                fullName.isNotEmpty ? fullName : 'CraftyBay User',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(phone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(city, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // close bottom sheet
                  _logout();
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _logout() {
    AuthService.clearAuth();
    CartService.clearCart();
    WishlistService.clearWishlist();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully'),
        backgroundColor: AppColors.primary,
      ),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppConstants.screenPadding,
        title: const AppLogo(size: 32, showText: true),
        actions: [
          // Profile & Logout Button
          _buildActionIconButton(Icons.person_outline, _showProfileModal),
          _buildActionIconButton(Icons.phone_outlined, () {}),
          _buildActionIconButton(Icons.notifications_none, () {}),
          _buildActionIconButton(Icons.logout, _logout),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([_fetchCategories(), _fetchProducts()]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar with live search & clear support
              HomeSearchBar(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                onSubmitted: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                onClear: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
              ),
              const SizedBox(height: 16),

              if (_searchQuery.trim().isNotEmpty) ...[
                // Search Results Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Search Results for "$_searchQuery"',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${_filteredProducts.length} items',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_filteredProducts.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.search_off_outlined,
                            size: 48,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No products found for "$_searchQuery"',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
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
              ] else ...[
                // Live Banner Slider from /slides API with Buy Now wired
                HomeBannerSlider(products: _products),
                const SizedBox(height: 16),

                // Categories Section from /categories API
                SectionHeader(
                  title: 'All Categories',
                  onSeeAllTap: widget.onNavigateToCategory,
                ),
                const SizedBox(height: 12),
                _buildCategoryList(),
                const SizedBox(height: 16),

                // Popular Products Section from /products API
                _buildProductSection(
                  title: 'Popular',
                  products: _products,
                ),
                const SizedBox(height: 16),

                // Special Products Section
                _buildProductSection(
                  title: 'Special',
                  products: _products.reversed.toList(),
                ),
                const SizedBox(height: 16),

                // New Products Section
                _buildProductSection(
                  title: 'New',
                  products: _products,
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    if (_isLoadingCategories) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Text(
        'No categories found',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }

    return SizedBox(
      height: 95,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
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

  Widget _buildProductSection({
    required String title,
    required List<ProductModel> products,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          onSeeAllTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductListByCategoryScreen(
                  categoryName: title,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        if (_isLoadingProducts)
          const SizedBox(
            height: 170,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (products.isEmpty)
          const Text(
            'No products available',
            style: TextStyle(color: AppColors.textSecondary),
          )
        else
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return SizedBox(
                  width: 135,
                  child: ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(product: product),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildActionIconButton(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: CircleAvatar(
        radius: 17,
        backgroundColor: AppColors.cardBg,
        child: IconButton(
          icon: Icon(icon, size: 18, color: AppColors.iconColor),
          onPressed: onTap,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
