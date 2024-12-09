import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';
import '../models/transaction.dart';

class CashierController extends GetxController {
  final RxList<Product> products = <Product>[].obs;
  final RxList<TransactionItem> currentItems = <TransactionItem>[].obs;
  final RxDouble total = 0.0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('http://192.168.128.10/api/products.php'),
      );

      final data = json.decode(response.body);
      
      if (data['success']) {
        products.value = List<Product>.from(
          data['products'].map((x) => Product.fromJson(x))
        );
      }
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void addItem(Product product, int quantity) {
    currentItems.add(TransactionItem(
      productId: product.id,
      quantity: quantity,
      price: product.price,
    ));
    calculateTotal();
  }

  void removeItem(int index) {
    currentItems.removeAt(index);
    calculateTotal();
  }

  void calculateTotal() {
    total.value = currentItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  Future<bool> completeTransaction() async {
    try {
      isLoading.value = true;
      
      final transactionData = {
        'total_amount': total.value,
        'items': currentItems.map((item) => {
          'productId': item.productId,
          'quantity': item.quantity,
          'price': item.price,
        }).toList(),
      };

      print('Sending transaction data: ${json.encode(transactionData)}');

      final response = await http.post(
        Uri.parse('http://192.168.128.10/api/transactions.php'),
        body: json.encode(transactionData),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = json.decode(response.body);
      
      if (data['success']) {
        currentItems.clear();
        total.value = 0;
        return true;
      } else {
        throw Exception(data['message'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      print('Error completing transaction: $e'); 
      Get.snackbar(
        'Error',
        'Failed to complete transaction: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  final productNameController = TextEditingController();
  final productPriceController = TextEditingController();

  Future<bool> addNewProduct() async {
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse('http://192.168.128.10/api/products.php'),
        body: json.encode({
          'name': productNameController.text,
          'price': double.parse(productPriceController.text),
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      
      if (data['success']) {
        await fetchProducts();
        productNameController.clear();
        productPriceController.clear();
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding new product: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    productNameController.dispose();
    productPriceController.dispose();
    super.onClose();
  }
}