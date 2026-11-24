/// Live Review model representing customer feedback from API: GET /reviews
class ReviewModel {
  final String id;
  final String authorName;
  final String reviewText;
  final double rating;

  const ReviewModel({
    required this.id,
    required this.authorName,
    required this.reviewText,
    this.rating = 5.0,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    String name = 'Customer';
    if (json['user'] is Map) {
      final user = json['user'] as Map;
      final first = user['first_name']?.toString() ?? '';
      final last = user['last_name']?.toString() ?? '';
      final full = '$first $last'.trim();
      if (full.isNotEmpty) name = full;
    }

    final rawRating = json['rating'];
    double parsedRating = 5.0;
    if (rawRating is num) {
      parsedRating = rawRating.toDouble();
    } else if (rawRating != null) {
      parsedRating = double.tryParse(rawRating.toString()) ?? 5.0;
    }

    return ReviewModel(
      id: json['_id']?.toString() ?? '',
      authorName: name,
      reviewText: json['comment']?.toString() ?? '',
      rating: parsedRating,
    );
  }
}
