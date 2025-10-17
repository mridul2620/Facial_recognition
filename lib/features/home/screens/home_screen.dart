import 'package:facial_recognition/features/stats/models/statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../camera/screens/camera_screen.dart';
import '../../users/screens/users_list_screen.dart';
import '../../stats/providers/stats_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load stats when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(statsProvider.notifier).loadStats();
    });
  }

  Future<void> _refreshStats() async {
    await ref.read(statsProvider.notifier).loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final statsState = ref.watch(statsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshStats,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Header
                    _buildHeader(),

                    const SizedBox(height: 40),

                    // Action Buttons
                    _buildActionButtons(context),

                    const SizedBox(height: 32),

                    // Quick Stats Section
                    _buildQuickStats(statsState),

                    const SizedBox(height: 32),

                    // System Status
                    _buildSystemStatus(statsState),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Face Recognition',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Secure. Fast. Accurate.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(StatsState statsState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Stats',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (statsState.isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (statsState.errorMessage != null)
          _buildErrorCard(statsState.errorMessage!)
        else if (statsState.statistics != null)
          _buildStatsGrid(statsState.statistics!)
        else
          _buildStatsGrid(null), // Show placeholder
      ],
    );
  }

  Widget _buildStatsGrid(Statistics? stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          icon: Icons.people_rounded,
          label: 'Total Users',
          value: stats?.totalUsers.toString() ?? '--',
          color: AppColors.primary,
        ),
        _buildStatCard(
          icon: Icons.check_circle_rounded,
          label: 'Active Users',
          value: stats?.activeUsers.toString() ?? '--',
          color: AppColors.success,
        ),
        _buildStatCard(
          icon: Icons.fingerprint_rounded,
          label: 'Face Embeddings',
          value: stats?.totalEmbeddings.toString() ?? '--',
          color: AppColors.accent,
        ),
        _buildStatCard(
          icon: Icons.analytics_rounded,
          label: 'Average Confidence',
          value: stats != null
              ? '${(stats.avgConfidence * 100).toStringAsFixed(0)}%'
              : '--',
          color: const Color(0xFF667EEA),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          context: context,
          icon: Icons.person_add_rounded,
          label: 'Register New Face',
          gradient: AppColors.primaryGradient as LinearGradient,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CameraScreen(mode: 'register'),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          context: context,
          icon: Icons.face_rounded,
          label: 'Recognize Face',
          gradient: AppColors.accentGradient,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CameraScreen(mode: 'recognize'),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          context: context,
          icon: Icons.people_rounded,
          label: 'Manage Users',
          gradient: AppColors.purpleGradient,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const UsersListScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSystemStatus(StatsState statsState) {
    final isHealthy = statsState.statistics != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isHealthy ? AppColors.success : AppColors.error,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isHealthy ? AppColors.success : AppColors.error,
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isHealthy ? 'System Online' : 'System Offline',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _refreshStats,
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}