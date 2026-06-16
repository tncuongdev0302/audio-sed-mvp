import 'package:equatable/equatable.dart';

enum ProductIconType { pill, siro, spray, droplet }

class Product extends Equatable {
  final String name;
  final String brand;
  final String price;
  final String unit;
  final ProductIconType iconType;
  final String desc;
  final String? tag;
  final bool isWarningCard; // True if it is a warning for children/infants

  const Product({
    required this.name,
    required this.brand,
    required this.price,
    required this.unit,
    required this.iconType,
    required this.desc,
    this.tag,
    this.isWarningCard = false,
  });

  @override
  List<Object?> get props => [
        name,
        brand,
        price,
        unit,
        iconType,
        desc,
        tag,
        isWarningCard,
      ];

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] as String,
      brand: json['brand'] as String,
      price: json['price'] as String,
      unit: json['unit'] as String,
      iconType: _parseIconType(json['iconType'] as String?),
      desc: json['desc'] as String,
      tag: json['tag'] as String?,
      isWarningCard: json['isWarningCard'] as bool? ?? false,
    );
  }

  static ProductIconType _parseIconType(String? typeStr) {
    switch (typeStr) {
      case 'siro':
        return ProductIconType.siro;
      case 'spray':
        return ProductIconType.spray;
      case 'droplet':
        return ProductIconType.droplet;
      case 'pill':
      default:
        return ProductIconType.pill;
    }
  }
}
