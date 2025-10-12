// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../widgets/action_card.dart';
import '../widgets/header_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header Section
              const SliverToBoxAdapter(
                child: HeaderSection(),
              ),

              // Main Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      // Title
                      Text(
                        'What would you like to do?',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),

                      const SizedBox(height: 24),

                      // Register Action Card
                      ActionCard(
                        icon: Icons.person_add_rounded,
                        title: 'Register New Face',
                        subtitle: 'Add a new person to the system',
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF6C63FF),
                            Color(0xFF5A52D5),
                          ],
                        ),
                        onTap: () {
                          // Navigate to camera with register mode
                          context.push('${AppRoutes.camera}?mode=register');
                        },
                      ),

                      const SizedBox(height: 20),

                      // Recognize Action Card
                      ActionCard(
                        icon: Icons.face_rounded,
                        title: 'Recognize Face',
                        subtitle: 'Identify a person from camera',
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF00D9FF),
                            Color(0xFF0099CC),
                          ],
                        ),
                        onTap: () {
                          // Navigate to camera with recognize mode
                          context.push('${AppRoutes.camera}?mode=recognize');
                        },
                      ),

                      const SizedBox(height: 40),

                      // Stats Section
                      _buildStatsSection(context),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                icon: Icons.people_rounded,
                label: 'Registered',
                value: '0',
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.primary.withOpacity(0.2),
              ),
              _buildStatItem(
                context,
                icon: Icons.history_rounded,
                label: 'Recognitions',
                value: '0',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}