// models/frame_models.dart
class FrameItem {
  final int id;
  final String name;
  final String neutral;
  final String black;
  final String brown;
  final String price;
  final String frameSize;
  

  FrameItem({
    required this.id,
    required this.name,
    required this.neutral,
    required this.black,
    required this.brown,
    required this.price,
    required this.frameSize,
  });

  factory FrameItem.fromJson(Map<String, dynamic> json) {
    return FrameItem(
      id: json['id'],
      name: json['name'],
      neutral: json['neutral'],
      black: json['black'],
      brown: json['brown'],
      price: json['price'],
      frameSize: json['frame_size'],
    );
  }

  String getImageUrl(String color) {
    switch (color.toLowerCase()) {
      case 'black':
        return black;
      case 'brown':
        return brown;
      default:
        return neutral;
    }
  }
}

class CartItem {
  final int productId;
  final String productName;
  final String productFrameColor;
  final String productPrice;
  final String productSize;
  final String productType;
  int productQuantity;
    final String imageUrl;   

  CartItem({
    required this.productId,
    required this.productName,
    required this.productFrameColor,
    required this.productPrice,
    required this.productSize,
    required this.productType,
    this.productQuantity = 1,
     required this.imageUrl,  
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productFrameColor': productFrameColor,
      'productPrice': productPrice,
      'productSize': productSize,
      'productQuantity': productQuantity,
      'productType': productType,
    };
  }

  double get totalPrice => double.parse(productPrice) * productQuantity;
}