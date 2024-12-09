import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uas/widgets/custom_text_field.dart';
import '../controllers/pos_controller.dart';
import '../widgets/sidebar.dart';
import '../models/product.dart';

class CashierView extends StatelessWidget {
  final POSController controller = Get.put(POSController());
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(),
      appBar: AppBar(
        title: Text('Kasir'),
      ),
      body: Row(
        children: [
          // Product Input Section
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  CustomTextField(
                    label: 'Product Name',
                    controller: productNameController,
                  ),
                  CustomTextField(
                    label: 'Price',
                    controller: priceController,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (productNameController.text.isEmpty || 
                          priceController.text.isEmpty) {
                        Get.snackbar('Error', 'Please fill all fields');
                        return;
                      }
                      
                      controller.addToCart(Product(
                        id: DateTime.now().millisecondsSinceEpoch,
                        name: productNameController.text,
                        price: double.parse(priceController.text),
                      ));
                      
                      productNameController.clear();
                      priceController.clear();
                    },
                    child: Text('Add Product'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Cart Section
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[100],
              child: Column(
                children: [
                  Expanded(
                    child: Obx(() => ListView.builder(
                      itemCount: controller.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = controller.cartItems[index];
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text('Rp. ${item.price}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => controller.removeFromCart(index),
                          ),
                        );
                      },
                    )),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Obx(() => Text(
                              'Rp. ${controller.total.value}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                          ],
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.completeTransaction(),
                          child: Text('Complete Transaction'),
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
          ),
        ],
      ),
    );
  }
}