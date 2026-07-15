import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userProv = context.watch<UserProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Hi, ${auth.user?.name ?? 'Eco Warrior'}!', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: userProv.isLoading
              ? _buildLoadingState()
              : RefreshIndicator(
                  onRefresh: () => userProv.fetchDashboardData(),
                  child: ListView(
                    padding: const EdgeInsets.all(20.0),
                    children: [
                      _buildWalletCard(theme, userProv).animate().fade(duration: 500.ms).slideY(begin: -0.1),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.push('/create-order');
                          },
                          icon: const Icon(Icons.document_scanner_rounded, size: 28),
                          label: const Text('Scan & Recycle Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ).animate().fade(delay: 200.ms).scale(),
                      const SizedBox(height: 32),
                      Text(
                        'Recent Activity',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ).animate().fade(delay: 300.ms),
                      const SizedBox(height: 16),
                      if (userProv.orders.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                Icon(Icons.eco_rounded, size: 80, color: Colors.green.withOpacity(0.3)),
                                const SizedBox(height: 16),
                                Text('Start recycling today!', style: TextStyle(color: Colors.grey.shade600, fontSize: 18, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ).animate().fade(delay: 400.ms)
                      else
                        ...userProv.orders.asMap().entries.map((entry) {
                          final index = entry.key;
                          final order = entry.value;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 4,
                            shadowColor: Colors.black12,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.recycling_rounded, color: Colors.white, size: 30),
                              ),
                              title: Text(order.category ?? 'Mixed Waste', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text('${order.weightKg ?? 0} kg • ${order.status.toUpperCase()}', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('+ Rp ${order.totalPrice ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                                ],
                              ),
                            ),
                          ).animate().fade(delay: (400 + (index * 100)).ms).slideX(begin: 0.1);
                        }),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildWalletCard(ThemeData theme, UserProvider userProv) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0ba360), Color(0xFF3cba92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0ba360).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Wallet Balance',
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Rp ${userProv.wallet?.balance ?? 0}',
            style: theme.textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: -1),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.energy_savings_leaf_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Eco Points', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(
                        '${userProv.wallet?.ecoPoints ?? 0} pts',
                        style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0ba360),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Redeem', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        _buildShimmerBox(height: 200),
        const SizedBox(height: 32),
        _buildShimmerBox(height: 60),
        const SizedBox(height: 32),
        _buildShimmerBox(height: 30, width: 150),
        const SizedBox(height: 16),
        _buildShimmerBox(height: 90),
        const SizedBox(height: 16),
        _buildShimmerBox(height: 90),
      ],
    );
  }

  Widget _buildShimmerBox({required double height, double width = double.infinity}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
