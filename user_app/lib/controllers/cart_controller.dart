import 'package:get/get.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
  });
}

class CartController extends GetxController {
  final RxList<CartItem> _items = <CartItem>[].obs;

  List<CartItem> get items => _items;

  double get totalPrice => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  void addItem(CartItem newItem) {
    int index = _items.indexWhere((item) => item.id == newItem.id);
    if (index != -1) {
      _items[index].quantity++;
      _items.refresh();
    } else {
      _items.add(newItem);
    }
    Get.snackbar('Cart', '${newItem.name} added to cart', snackPosition: SnackPosition.BOTTOM);
  }

  void removeItem(String id) {
    int index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
        _items.refresh();
      } else {
        _items.removeAt(index);
      }
    }
  }

  void clearCart() {
    _items.clear();
  }
}
