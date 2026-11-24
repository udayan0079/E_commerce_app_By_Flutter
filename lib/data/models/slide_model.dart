/// Live Slider model from API /slides
class SlideModel {
  final String id;
  final String photoUrl;
  final String description;
  final String? productId;

  SlideModel({
    required this.id,
    required this.photoUrl,
    required this.description,
    this.productId,
  });

  factory SlideModel.fromJson(Map<String, dynamic> json) {
    return SlideModel(
      id: json['_id'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      description: json['description'] ?? '',
      productId: json['product']?.toString(),
    );
  }
}
