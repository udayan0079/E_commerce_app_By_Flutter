import 'dart:developer';
import 'package:flutter/material.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_urls.dart';
import '../../../data/models/review_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/network_caller.dart';
import '../../widgets/custom_text_field.dart';
import 'reviews_screen.dart';

/// Screen allowing the user to create and submit a product review.
class CreateReviewScreen extends StatefulWidget {
  final String? productId;

  const CreateReviewScreen({super.key, this.productId});

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double _rating = 5.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (AuthService.isLoggedIn && AuthService.userData != null) {
      _firstNameController.text = AuthService.userData?['first_name']?.toString() ?? '';
      _lastNameController.text = AuthService.userData?['last_name']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final fName = _firstNameController.text.trim();
    final lName = _lastNameController.text.trim();
    final authorName = '$fName $lName'.trim();

    final newReview = ReviewModel(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      authorName: authorName.isNotEmpty ? authorName : 'Customer',
      reviewText: _reviewController.text.trim(),
      rating: _rating,
    );

    // Add locally immediately so it never gets lost
    if (widget.productId != null) {
      ReviewsScreen.addLocalReview(widget.productId!, newReview);
    }

    // If authenticated, sync with live backend
    if (AuthService.isLoggedIn) {
      try {
        await NetworkCaller.postRequest(
          url: AppUrls.createReview,
          body: {
            'product': widget.productId ?? '',
            'comment': _reviewController.text.trim(),
            'rating': _rating.toInt(),
          },
          token: AuthService.token,
        );
      } catch (e) {
        log('Error submitting review to backend: $e');
      }
    }

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Review'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _firstNameController,
                hintText: 'First Name',
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Please enter first name' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _lastNameController,
                hintText: 'Last Name',
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Please enter last name' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Rating',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    icon: Icon(
                      starIndex <= _rating ? Icons.star : Icons.star_border,
                      color: AppColors.accent,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = starIndex.toDouble();
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),
              const Text(
                'Write Review',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _reviewController,
                hintText: 'Write Review',
                maxLines: 6,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Please write your review' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitReview,
                      child: const Text('Submit'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
