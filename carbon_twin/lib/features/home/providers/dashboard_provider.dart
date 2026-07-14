import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api_client.dart';

class DashboardData {
  final double todayEmissions;
  final double totalEmissions;
  final Map<String, double> breakdown;
  final int xpBalance;
  final List<dynamic> recentActivities;

  DashboardData({
    required this.todayEmissions,
    required this.totalEmissions,
    required this.breakdown,
    required this.xpBalance,
    required this.recentActivities,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final rawBreakdown = json['breakdown'] as Map<String, dynamic>? ?? {};
    return DashboardData(
      todayEmissions: (json['todayEmissions'] as num?)?.toDouble() ?? 0.0,
      totalEmissions: (json['totalEmissions'] as num?)?.toDouble() ?? 0.0,
      breakdown: rawBreakdown.map((k, v) => MapEntry(k, (v as num).toDouble())),
      xpBalance: json['xpBalance'] as int? ?? 0,
      recentActivities: json['recentActivities'] as List<dynamic>? ?? [],
    );
  }
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/dashboard');
    return DashboardData.fromJson(response.data);
  } on DioException catch (e) {
    rethrow;
  }
});
