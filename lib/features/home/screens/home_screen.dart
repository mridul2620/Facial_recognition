// ignore_for_file: deprecated_member_use
import 'package:facial_recognition/features/camera/screens/camera_screen.dart';
import '../../users/screens/users_list_screen.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/header_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    
    // Minimum height threshold (6 inches ≈ 640 logical pixels for most phones)
    const minHeightThreshold = 640.0;
    final enableScroll = height < minHeightThreshold;
    
    // Responsive padding based on screen width
    final horizontalPadding = width * 0.06; // 6% of screen width
    final verticalSpacing = enableScroll ? height * 0.025 : height * 0.02;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: enableScroll
              ? _buildScrollableContent(context, horizontalPadding, verticalSpacing)
              : _buildFitContent(context, horizontalPadding, verticalSpacing),
        ),
      ),
    );
  }

  Widget _buildScrollableContent(BuildContext context, double horizontalPadding, double verticalSpacing) {
    // ignore: unused_local_variable
    final width = MediaQuery.of(context).size.width;
    
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: HeaderSection(),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverToBoxAdapter(
            child: _buildMainContent(context, verticalSpacing),
          ),
        ),
      ],
    );
  }

  Widget _buildFitContent(BuildContext context, double horizontalPadding, double verticalSpacing) {
    return Column(
      children: [
        const HeaderSection(),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: _buildMainContent(context, verticalSpacing),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, double verticalSpacing) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(height: verticalSpacing),

        // Title
        Text(
          'What would you like to do?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondary,
                fontSize: width * 0.055,
              ),
        ),

        SizedBox(height: verticalSpacing * 0.5),

        // Action Buttons
        Column(
          children: [
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
            SizedBox(height: height * 0.015),
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
            SizedBox(height: height * 0.015),
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
        ),

        SizedBox(height: verticalSpacing * 0.5),

        // Stats Section
        _buildStatsSection(context),

        SizedBox(height: verticalSpacing),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    
    return Container(
      padding: EdgeInsets.all(width * 0.06),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(width * 0.05),
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: width * 0.055,
            ),
          ),
          SizedBox(height: height * 0.025),
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
                height: height * 0.05,
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
    final width = MediaQuery.of(context).size.width;
    
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: width * 0.08, // Responsive icon size
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: width * 0.08,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: width * 0.035,
          ),
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(width * 0.05),
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
          borderRadius: BorderRadius.circular(width * 0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: height * 0.025,
              horizontal: width * 0.06,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(width * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: width * 0.07,
                  ),
                ),
                SizedBox(width: width * 0.04),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: width * 0.05,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}