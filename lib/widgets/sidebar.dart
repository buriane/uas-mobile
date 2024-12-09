import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class Sidebar extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Obx(() => Text(
              'Welcome, ${authController.username}',
              style: TextStyle(color: Colors.white, fontSize: 24),
            )),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () => Get.toNamed('/dashboard'),
          ),
          ListTile(
            leading: Icon(Icons.point_of_sale),
            title: Text('Kasir'),
            onTap: () => Get.toNamed('/cashier'),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => authController.logout(),
          ),
        ],
      ),
    );
  }
}