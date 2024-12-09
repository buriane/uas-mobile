import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardController extends GetxController {
  final RxDouble todaySales = 0.0.obs;
  final RxInt transactionCount = 0.obs;
  final RxList<Map<String, dynamic>> weeklySales = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('http://192.168.128.10/api/dashboard.php'),
      );

      final data = json.decode(response.body);
      
      if (data['success']) {
        todaySales.value = double.parse(data['today_stats']['total_sales'] ?? '0');
        transactionCount.value = int.parse(data['today_stats']['transaction_count'] ?? '0');
        weeklySales.value = List<Map<String, dynamic>>.from(data['weekly_sales']);
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}