import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: SafeArea(
          child: adminProv.isLoading
              ? _buildLoadingState()
              : RefreshIndicator(
                  onRefresh: () => adminProv.fetchDashboardData(),
                  child: ListView(
                    padding: const EdgeInsets.all(20.0),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Total Users',
                              value: '${adminProv.statistics['total_users'] ?? 0}',
                              icon: Icons.people_alt_rounded,
                              colors: const [Color(0xFF4facfe), Color(0xFF00f2fe)],
                            ).animate().fade(duration: 500.ms).slideX(begin: -0.2),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              title: 'Total Orders',
                              value: '${adminProv.statistics['total_orders'] ?? 0}',
                              icon: Icons.shopping_bag_rounded,
                              colors: const [Color(0xFF43e97b), Color(0xFF38f9d7)],
                            ).animate().fade(duration: 500.ms, delay: 100.ms).slideX(begin: 0.2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                          onPressed: () async {
                            final success = await context.read<AdminProvider>().scrapePrices();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success ? 'Prices updated from web successfully!' : 'Scrape failed'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.sync_rounded),
                          label: const Text('Sync Latest Waste Prices', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ).animate().fade(delay: 200.ms).scale(),
                      const SizedBox(height: 32),
                      Text('Recent Users', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))
                          .animate().fade(delay: 300.ms),
                      const SizedBox(height: 16),
                      if (adminProv.users.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(Icons.group_off_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
                                const SizedBox(height: 16),
                                Text('No users yet', style: TextStyle(color: Colors.grey.shade600, fontSize: 18)),
                              ],
                            ),
                          ),
                        ).animate().fade(delay: 400.ms)
                      else
                        ...adminProv.users.asMap().entries.map((entry) {
                          final index = entry.key;
                          final user = entry.value;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 4,
                            shadowColor: Colors.black12,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: theme.colorScheme.primaryContainer,
                                child: Text(
                                  (user.name ?? user.email)[0].toUpperCase(),
                                  style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(user.name ?? user.email, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(user.email, style: TextStyle(color: Colors.grey.shade600)),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(user.role).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _getRoleColor(user.role).withOpacity(0.3)),
                                ),
                                child: Text(
                                  user.role.toUpperCase(),
                                  style: TextStyle(color: _getRoleColor(user.role), fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ).animate().fade(delay: (400 + (index * 100)).ms).slideY(begin: 0.1);
                        })
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'collector':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Row(
          children: [
            Expanded(child: _buildShimmerBox(height: 140)),
            const SizedBox(width: 16),
            Expanded(child: _buildShimmerBox(height: 140)),
          ],
        ),
        const SizedBox(height: 24),
        _buildShimmerBox(height: 56),
        const SizedBox(height: 32),
        _buildShimmerBox(height: 30, width: 150),
        const SizedBox(height: 16),
        _buildShimmerBox(height: 80),
        const SizedBox(height: 12),
        _buildShimmerBox(height: 80),
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
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> colors;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 20),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, height: 1)),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
