import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Text('Failed to load profile'),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () {
                  ref.invalidate(profileProvider);
                  ref.invalidate(achievementsProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: Text(
                        (profile.name?.isNotEmpty == true)
                            ? profile.name![0].toUpperCase()
                            : '?',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name ?? 'User',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            profile.email ?? '',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // XP Wallet Card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'XP Wallet',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${profile.xpBalance}',
                      style:
                          Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer,
                      ),
                    ),
                    const Text('XP Available'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _showRedeemModal(context, ref, profile.xpBalance),
                      child: const Text('Redeem XP'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Level Progress
            achievementsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox(),
              data: (achievements) => _buildAchievementsSection(
                  context, ref, achievements),
            ),

            const SizedBox(height: 16),

            // Transaction History
            if (profile.recentTransactions.isNotEmpty) ...[
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...profile.recentTransactions.map((tx) {
                final amount = tx['amount'] as int? ?? 0;
                final desc = tx['description'] as String? ?? '';
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    amount >= 0
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: amount >= 0 ? Colors.green : Colors.red,
                  ),
                  title: Text(desc),
                  trailing: Text(
                    '${amount >= 0 ? '+' : ''}$amount XP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: amount >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(
      BuildContext context, WidgetRef ref, AchievementsData data) {
    final progress =
        ((data.totalXp % 100) / 100.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Level Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 35,
                  lineWidth: 6,
                  percent: progress,
                  center: Text(
                    'Lv${data.level}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  progressColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level ${data.level}',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${data.xpToNextLevel} XP to next level',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Achievements Grid
        Text(
          'Achievements',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: data.achievements.length,
          itemBuilder: (context, index) {
            final achievement = data.achievements[index];
            final unlocked = achievement['unlocked'] as bool? ?? false;
            return Card(
              color: unlocked
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      unlocked ? Icons.emoji_events : Icons.lock,
                      size: 28,
                      color: unlocked
                          ? Colors.amber
                          : Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement['title'] ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      achievement['description'] ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showRedeemModal(BuildContext context, WidgetRef ref, int balance) {
    final redeemItems = [
      {'id': '1', 'name': 'Food Delivery Coupon', 'price': 50},
      {'id': '2', 'name': 'Extra AC Usage Pass', 'price': 30},
      {'id': '3', 'name': 'Ride-Hailing Credit', 'price': 80},
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Redeem XP',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Balance: $balance XP'),
            const SizedBox(height: 16),
            ...redeemItems.map((item) => ListTile(
                  leading: const Icon(Icons.card_giftcard),
                  title: Text(item['name'] as String),
                  trailing: FilledButton.tonal(
                    onPressed: balance >= (item['price'] as int)
                        ? () async {
                            final success = await ref
                                .read(redeemProvider.notifier)
                                .redeemItems([item]);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success
                                      ? 'Redeemed successfully!'
                                      : 'Redemption failed'),
                                ),
                              );
                            }
                          }
                        : null,
                    child: Text('${item['price']} XP'),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
