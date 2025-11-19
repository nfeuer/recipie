import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';
import 'package:recipe_app/presentation/providers/user_providers.dart';
import 'package:recipe_app/presentation/screens/premium/premium_screen.dart';

/// Widget that gates premium features behind subscription check
class PremiumFeatureGate extends ConsumerWidget {
  final Widget child;
  final String featureName;
  final String? featureDescription;
  final VoidCallback? onUpgradePressed;

  const PremiumFeatureGate({
    super.key,
    required this.child,
    required this.featureName,
    this.featureDescription,
    this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      data: (firebaseUser) {
        if (firebaseUser == null) {
          return _buildLockedFeature(
            context,
            'Please sign in to access this feature',
          );
        }

        final userProfileAsync = ref.watch(
          userProfileProvider(firebaseUser.uid),
        );
        return userProfileAsync.when(
          data: (userProfile) {
            if (userProfile == null) {
              return _buildLockedFeature(context, 'User profile not found');
            }

            // Check if user has premium access
            if (userProfile.hasPremiumAccess) {
              return child;
            }

            // Show locked feature UI
            return _buildLockedFeature(context, null);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) =>
              _buildLockedFeature(context, 'Error loading user profile'),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildLockedFeature(context, 'Error loading user'),
    );
  }

  Widget _buildLockedFeature(BuildContext context, String? errorMessage) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock,
            size: 64,
            color: AppTheme.primaryColor.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'Premium Feature',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            featureDescription ?? 'Upgrade to Premium to unlock $featureName',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (errorMessage == null)
            ElevatedButton.icon(
              onPressed:
                  onUpgradePressed ??
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PremiumScreen()),
                    );
                  },
              icon: const Icon(Icons.upgrade),
              label: const Text('Upgrade to Premium'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A simpler inline premium badge that can be used in lists
class PremiumBadge extends StatelessWidget {
  final bool small;

  const PremiumBadge({super.key, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[700]!, Colors.amber[500]!],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: small ? 12 : 16, color: Colors.white),
          SizedBox(width: small ? 2 : 4),
          Text(
            'PREMIUM',
            style: TextStyle(
              color: Colors.white,
              fontSize: small ? 10 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
