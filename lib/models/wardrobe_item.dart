// lib/models/wardrobe_item.dart
class WardrobeItem {
  final String id;
  final String filename;
  final String filepath;
  final String category;
  final String color;
  final String season;
  final String occasion;
  final String? brand;
  final String? purchaseDate;
  final int price;
  final int timesWorn;
  final String? lastWorn;
  final String uploadDate;

  WardrobeItem({
    required this.id,
    required this.filename,
    required this.filepath,
    required this.category,
    required this.color,
    required this.season,
    required this.occasion,
    this.brand,
    this.purchaseDate,
    required this.price,
    required this.timesWorn,
    this.lastWorn,
    required this.uploadDate,
  });

  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      id: json['id'] ?? '',
      filename: json['filename'] ?? '',
      filepath: json['filepath'] ?? '',
      category: json['category'] ?? '',
      color: json['color'] ?? '',
      season: json['season'] ?? 'all-season',
      occasion: json['occasion'] ?? 'casual',
      brand: json['brand'],
      purchaseDate: json['purchase_date'],
      price: json['price'] ?? 0,
      timesWorn: json['times_worn'] ?? 0,
      lastWorn: json['last_worn'],
      uploadDate: json['upload_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'filepath': filepath,
      'category': category,
      'color': color,
      'season': season,
      'occasion': occasion,
      'brand': brand,
      'purchase_date': purchaseDate,
      'price': price,
      'times_worn': timesWorn,
      'last_worn': lastWorn,
      'upload_date': uploadDate,
    };
  }
}

