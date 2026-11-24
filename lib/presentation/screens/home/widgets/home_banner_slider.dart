import 'package:flutter/material.dart';
import '../../../../app/app_colors.dart';
import '../../../../app/app_urls.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/models/slide_model.dart';
import '../../../../data/services/network_caller.dart';
import '../../../widgets/product_image_view.dart';
import '../../product/product_details_screen.dart';

/// Aesthetic, modern full-bleed promotional banner carousel slider.
/// Showcases crystal-clear, bright promotional banner images with sleek
/// bottom glassmorphic scrim, deal badge, and interactive Buy Now action.
/// Manual swipe & dot-tap only (auto-slide disabled).
class HomeBannerSlider extends StatefulWidget {
  final List<ProductModel> products;

  const HomeBannerSlider({
    super.key,
    this.products = const [],
  });

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  List<SlideModel> _slides = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSliders();
  }

  Future<void> _fetchSliders() async {
    final response = await NetworkCaller.getRequest(url: AppUrls.homeSliders);
    if (response.isSuccess && response.responseData != null) {
      final List results = response.responseData['data']['results'] ?? [];
      if (mounted) {
        setState(() {
          _slides = results.map((item) => SlideModel.fromJson(item)).toList();
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBuyNow(SlideModel slide) {
    ProductModel targetProduct;

    // Match slide with products in catalog
    final match = widget.products.where((p) {
      final pTitle = p.title.toLowerCase();
      final sDesc = slide.description.toLowerCase();
      return (sDesc.isNotEmpty && (pTitle.contains(sDesc) || sDesc.contains(pTitle))) ||
          (slide.productId != null && p.id == slide.productId);
    }).firstOrNull;

    if (match != null) {
      targetProduct = match;
    } else if (widget.products.isNotEmpty) {
      final sample = widget.products.first;
      targetProduct = ProductModel(
        id: slide.id,
        title: slide.description.isNotEmpty ? slide.description : sample.title,
        price: sample.price > 0 ? sample.price : 150.0,
        imageUrl: slide.photoUrl.isNotEmpty ? slide.photoUrl : sample.imageUrl,
        description:
            'Special promotional deal on ${slide.description}. Grab this exclusive offer on CraftyBay today!',
        availableColors: sample.availableColors,
        availableSizes: sample.availableSizes,
      );
    } else {
      targetProduct = ProductModel(
        id: slide.id,
        title: slide.description.isNotEmpty ? slide.description : 'Special Deal',
        price: 150.0,
        imageUrl: slide.photoUrl,
        description: 'Exclusive deal on ${slide.description}. Available on CraftyBay!',
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: targetProduct),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 170,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_slides.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => _onBuyNow(slide),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 1. Dark sleek fallback backdrop
                        Container(
                          color: const Color(0xFF1E293B),
                        ),

                        // 2. Full-bleed banner image - 100% visible, bright & prominent
                        Positioned.fill(
                          child: ProductImageView(
                            imageUrl: slide.photoUrl,
                            fit: BoxFit.cover,
                            placeholderIcon: Icons.shopping_bag_outlined,
                          ),
                        ),

                        // 3. Subtle bottom gradient scrim (covers only bottom 40% so picture remains crystal clear)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 75,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.75),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 4. Floating details and Buy Now action at bottom
                        Positioned(
                          left: 14,
                          right: 14,
                          bottom: 12,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Left: Deal badge & Title
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.flash_on,
                                            color: Colors.amber,
                                            size: 11,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            'SPECIAL DEAL',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      slide.description.isNotEmpty
                                          ? slide.description
                                          : 'Exclusive Deal',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.2,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black87,
                                            blurRadius: 6,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Right: Buy Now Pill Button
                              ElevatedButton(
                                onPressed: () => _onBuyNow(slide),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shadowColor: Colors.black38,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 7,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Buy Now',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Interactive dots indicator with animated capsule
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _slides.length,
            (index) => GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentIndex == index ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? AppColors.primary
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
