import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api_client.dart';

class ProfileData {
  final String id;
  final String? name;
  final String? email;
  final String? image;
  final int xpBalance;
  final String joinedAt;
  final List<dynamic> recentTransactions;

  ProfileData({
    required this.id,
    this.name,
    this.email,
    this.image,
    required this.xpBalance,
    required this.joinedAt,
    required this.recentTransactions,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] ?? '',
      name: json['name'],
      email: json['email'],
      image: json['image'],
      xpBalance: json['xpBalance'] ?? 0,
      joinedAt: json['joinedAt'] ?? '',
      recentTransactions: json['recentTransactions'] ?? [],
    );
  }
}

class AchievementsData {
  final int level;
  final int xpToNextLevel;
  final int totalXp;
  final List<dynamic> achievements;

  AchievementsData({
    required this.level,
    required this.xpToNextLevel,
    required this.totalXp,
    required this.achievements,
  });

  factory AchievementsData.fromJson(Map<String, dynamic> json) {
    return AchievementsData(
      level: json['level'] ?? 1,
      xpToNextLevel: json['xpToNextLevel'] ?? 100,
      totalXp: json['totalXp'] ?? 0,
      achievements: json['achievements'] ?? [],
    );
  }
}

final profileProvider = FutureProvider<ProfileData>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/profile');
    return ProfileData.fromJson(response.data);
  } on DioException catch (e) {
    rethrow;
  }
});

final achievementsProvider = FutureProvider<AchievementsData>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/achievements');
    return AchievementsData.fromJson(response.data);
  } on DioException catch (e) {
    rethrow;
  }
});

// Redeem provider
class RedeemNotifier extends StateNotifier<AsyncValue<void>> {
  final Dio dio;
  final Ref ref;

  RedeemNotifier(this.dio, this.ref) : super(const AsyncData(null));

  Future<bool> redeemItems(List<Map<String, dynamic>> items) async {
    state = const AsyncLoading();
    try {
      await dio.post('/redeem', data: {'items': items});
      // Refresh profile after redemption
      ref.invalidate(profileProvider);
      ref.invalidate(achievementsProvider);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}

final redeemProvider =
    StateNotifierProvider<RedeemNotifier, AsyncValue<void>>((ref) {
  final dio = ref.watch(dioProvider);
  return RedeemNotifier(dio, ref);
});
