import 'package:flutter/material.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_env.dart';
import '../../../app/app_urls.dart';
import '../../../data/models/review_model.dart';
import '../../../data/services/network_caller.dart';
import 'create_review_screen.dart';

/// Live Product Reviews List Screen connected directly to senior's API: GET /reviews
class ReviewsScreen extends StatefulWidget {
  final String? productId;
  final List<ReviewModel> initialReviews;

  static final Map<String, List<ReviewModel>> localReviews = {};

  static void addLocalReview(String productId, ReviewModel review) {
    if (!localReviews.containsKey(productId)) {
      localReviews[productId] = [];
    }
    localReviews[productId]!.insert(0, review);
  }

  /// Fetches merged local + backend reviews safely.
  /// Falls back to configured catalog ID if [productId] is empty/non-ObjectId
  /// because `/reviews` strictly requires a 24-hex `product` query parameter.
  static Future<List<ReviewModel>> fetchProductReviews(String? productId) async {
    final cleanId = productId?.trim() ?? '';
    final local = cleanId.isNotEmpty
        ? (localReviews[cleanId] ?? const <ReviewModel>[])
        : const <ReviewModel>[];

    final fallbackId = AppEnv.fallbackReviewProductId;
    final isValidObjectId = RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(cleanId);
    final queryId = isValidObjectId ? cleanId : fallbackId;
    if (queryId.isEmpty) {
      return [...local];
    }

    var response = await NetworkCaller.getRequest(
      url: AppUrls.productReviews(queryId),
    );
    if ((!response.isSuccess || response.responseData == null) &&
        isValidObjectId &&
        fallbackId.isNotEmpty &&
        cleanId != fallbackId) {
      response = await NetworkCaller.getRequest(
        url: AppUrls.productReviews(fallbackId),
      );
    }

    final List<ReviewModel> serverList = [];
    if (response.isSuccess && response.responseData != null) {
      final data = response.responseData['data'];
      final List results = (data is Map && data['results'] is List) ? data['results'] : [];
      for (final item in results) {
        if (item is Map) {
          serverList.add(ReviewModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return [...local, ...serverList];
  }

  const ReviewsScreen({
    super.key,
    this.productId,
    this.initialReviews = const [],
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialReviews.isNotEmpty) {
      final cleanId = widget.productId?.trim() ?? '';
      final local = cleanId.isNotEmpty
          ? (ReviewsScreen.localReviews[cleanId] ?? const <ReviewModel>[])
          : const <ReviewModel>[];
      final seen = <String>{};
      _reviews = [
        for (final r in [...local, ...widget.initialReviews])
          if (seen.add('${r.id}:${r.reviewText}')) r,
      ];
      _isLoading = false;
    }
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    final fetched = await ReviewsScreen.fetchProductReviews(widget.productId);
    if (!mounted) return;
    setState(() {
      if (fetched.isNotEmpty || widget.initialReviews.isEmpty) {
        _reviews = fetched;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rate_review_outlined, size: 56, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      const Text(
                        'No reviews yet for this product',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateReviewScreen(productId: widget.productId),
                            ),
                          ).then((_) => _fetchReviews());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.rate_review, size: 18),
                        label: const Text(
                          'Write a Review',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppConstants.screenPadding),
                  itemCount: _reviews.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final review = _reviews[index];
                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.border, width: 0.8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.cardBg,
                                  child: Icon(
                                    Icons.person,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    review.authorName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 14, color: AppColors.accent),
                                    const SizedBox(width: 3),
                                    Text(
                                      review.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              review.reviewText,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      // Bottom Floating Add Review Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.screenPadding,
          vertical: 12,
        ),
        decoration: const BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Reviews (${_reviews.length})',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateReviewScreen(productId: widget.productId),
                  ),
                ).then((_) => _fetchReviews());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.rate_review, size: 16),
              label: const Text(
                'Write a Review',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
