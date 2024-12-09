import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cashier_controller.dart';
import '../models/product.dart';
import '../widgets/sidebar.dart';
import '../widgets/custom_input.dart';

class CashierView extends StatelessWidget {
  final CashierController controller = Get.put(CashierController());
  final TextEditingController quantityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _newProductFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(currentRoute: '/cashier'),
      appBar: AppBar(
        title: Text('Kasir'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              Card(
                margin: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Form(
                        key: _newProductFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Tambah Produk Baru',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            CustomInput(
                              label: 'Nama Produk',
                              controller: controller.productNameController,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Masukkan nama produk';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 8),
                            CustomInput(
                              label: 'Harga',
                              controller: controller.productPriceController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Masukkan harga';
                                }
                                if (double.tryParse(value!) == null) {
                                  return 'Masukkan harga yang valid';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                if (_newProductFormKey.currentState!
                                    .validate()) {
                                  final success =
                                      await controller.addNewProduct();
                                  if (success) {
                                    Get.snackbar(
                                      'Sukses',
                                      'Produk berhasil ditambahkan',
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                    );
                                  } else {
                                    Get.snackbar(
                                      'Error',
                                      'Gagal menambahkan produk',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                }
                              },
                              child: Text('Tambah Produk'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Daftar Produk',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: 200,
                      child: ListView.builder(
                        itemCount: controller.products.length,
                        itemBuilder: (context, index) {
                          final Product product = controller.products[index];
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text(
                              'Rp ${product.price.toStringAsFixed(2)}',
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                _showAddItemDialog(context, product);
                              },
                              child: Text('Tambah ke Keranjang'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                margin: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Transaksi Saat Ini',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: 200,
                      child: ListView.builder(
                        itemCount: controller.currentItems.length,
                        itemBuilder: (context, index) {
                          final item = controller.currentItems[index];
                          final product = controller.products.firstWhere(
                            (p) => p.id == item.productId,
                          );
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline),
                                  onPressed: () => controller
                                      .updateItemQuantity(index, false),
                                ),
                                Obx(() => Text(
                                      '${item.quantity}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    )),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline),
                                  onPressed: () => controller
                                      .updateItemQuantity(index, true),
                                ),
                                Text('x Rp ${item.price}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Obx(() => Text(
                                      'Rp ${(item.quantity.value * item.price).toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => controller.removeItem(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Obx(() => Text(
                                    'Rp ${controller.total.value.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  )),
                            ],
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: controller.currentItems.isEmpty
                                ? null
                                : () => _completeTransaction(context),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Selesaikan Transaksi',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showAddItemDialog(BuildContext context, Product product) {
    quantityController.text = '1';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah ${product.name}'),
        content: Form(
          key: _formKey,
          child: CustomInput(
            label: 'Quantity',
            controller: quantityController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter quantity';
              }
              if (int.tryParse(value) == null || int.parse(value) < 1) {
                return 'Please enter valid quantity';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                controller.addItem(
                  product,
                  int.parse(quantityController.text),
                );
                Get.back();
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _completeTransaction(BuildContext context) async {
    Get.dialog(
      AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Apakah Anda yakin ingin menyelesaikan transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await controller.completeTransaction();
              if (success) {
                Get.snackbar(
                  'Sukses',
                  'Transaksi berhasil diselesaikan',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: Duration(seconds: 3),
                );
              }
            },
            child: Text('Ya, Selesaikan'),
          ),
        ],
      ),
    );
  }
}
