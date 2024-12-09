import 'package:get/get.dart';
import 'package:uas/services/api_service.dart';
import '../models/product.dart';

class POSController extends GetxController {
  final cartItems = <Product>[].obs;
  final total = 0.0.obs;

  void addToCart(Product product) {
    cartItems.add(product);
    calculateTotal();
  }

  void removeFromCart(int index) {
    cartItems.removeAt(index);
    calculateTotal();
  }

  void calculateTotal() {
    total.value = cartItems.fold(0, (sum, item) => sum + item.price);
  }

  Future<void> completeTransaction() async {
    if (cartItems.isEmpty) return;

    try {
      final transactionData = {
        'items': cartItems.map((item) => {
          'product_id': item.id,
          'price': item.price,
          'quantity': 1,
        }).toList(),
        'total': total.value,
      };

      await ApiService.saveTransaction(transactionData);
      cartItems.clear();
      total.value = 0;
      Get.snackbar('Success', 'Transaction completed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to complete transaction');
    }
  }
}