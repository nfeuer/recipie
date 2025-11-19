import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.star,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unlock Premium Features',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Take your cooking experience to the next level',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Features List
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Premium Features',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    icon: Icons.import_export,
                    title: 'Recipe Import/Export',
                    description: 'Import from URLs, export to PDF',
                  ),
                  _buildFeatureItem(
                    icon: Icons.mic,
                    title: 'Hands-Free Voice Commands',
                    description: 'Control cooking mode with your voice',
                  ),
                  _buildFeatureItem(
                    icon: Icons.auto_awesome,
                    title: 'AI-Powered Recommendations',
                    description: 'Personalized recipe suggestions',
                  ),
                  _buildFeatureItem(
                    icon: Icons.history,
                    title: 'Recipe Version History',
                    description: 'Track and revert recipe changes',
                  ),
                  _buildFeatureItem(
                    icon: Icons.analytics,
                    title: 'Advanced Analytics',
                    description: 'Detailed insights into your cooking',
                  ),
                  _buildFeatureItem(
                    icon: Icons.filter_list,
                    title: 'Advanced Dietary Filters',
                    description: 'Custom allergen and preference filtering',
                  ),
                  _buildFeatureItem(
                    icon: Icons.cloud_off,
                    title: 'Offline Mode',
                    description: 'Access recipes without internet',
                  ),
                  _buildFeatureItem(
                    icon: Icons.ad_units_off,
                    title: 'Ad-Free Experience',
                    description: 'No advertisements or interruptions',
                  ),
                ],
              ),
            ),

            // Pricing Cards
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Column(
                children: [
                  Text(
                    'Choose Your Plan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildPricingCard(
                    context: context,
                    title: 'Monthly',
                    price: '\$4.99',
                    period: '/month',
                    features: [
                      'All premium features',
                      'Cancel anytime',
                      'Priority support',
                    ],
                    onTap: () => _handleSubscription(context, 'monthly'),
                  ),
                  const SizedBox(height: 16),
                  _buildPricingCard(
                    context: context,
                    title: 'Yearly',
                    price: '\$49.99',
                    period: '/year',
                    badge: 'SAVE 17%',
                    features: [
                      'All premium features',
                      'Save \$10/year',
                      'Priority support',
                      'Early access to new features',
                    ],
                    highlighted: true,
                    onTap: () => _handleSubscription(context, 'yearly'),
                  ),
                ],
              ),
            ),

            // Current subscription status
            currentUserAsync.when(
              data: (firebaseUser) {
                if (firebaseUser == null) return const SizedBox.shrink();

                final userProfileAsync = ref.watch(userProfileProvider(firebaseUser.uid));
                return userProfileAsync.when(
                  data: (userProfile) {
                    if (userProfile == null) return const SizedBox.shrink();

                    if (userProfile.hasPremiumAccess) {
                      return Container(
                        margin: const EdgeInsets.all(AppTheme.paddingLarge),
                        padding: const EdgeInsets.all(AppTheme.paddingMedium),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userProfile.isSuperAdmin
                                        ? 'Super Admin Access'
                                        : 'Premium Active',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[900],
                                    ),
                                  ),
                                  if (userProfile.subscriptionExpiresAt != null)
                                    Text(
                                      'Expires: ${_formatDate(userProfile.subscriptionExpiresAt!)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard({
    required BuildContext context,
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required VoidCallback onTap,
    String? badge,
    bool highlighted = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? AppTheme.primaryColor : Colors.grey[300]!,
          width: highlighted ? 2 : 1,
        ),
        color: highlighted ? AppTheme.primaryColor.withOpacity(0.05) : Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              children: [
                if (badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    Text(
                      period,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.check, color: Colors.green[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: highlighted
                          ? AppTheme.primaryColor
                          : Colors.grey[300],
                      foregroundColor: highlighted ? Colors.white : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Subscribe'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubscription(BuildContext context, String plan) {
    // TODO: Implement actual subscription logic with payment processor
    // For now, show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Subscription integration coming soon! Plan: $plan'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
