import 'package:get/get.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  final isLoggedIn = false.obs;
  final username = ''.obs;

  Future<bool> login(String username, String password) async {
    try {
      final response = await ApiService.login(username, password);
      if (response['success']) {
        this.username.value = username;
        isLoggedIn.value = true;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    isLoggedIn.value = false;
    username.value = '';
    Get.offAllNamed('/login');
  }
}