import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/data/models/recipe_model.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';
import 'package:recipe_app/presentation/providers/user_providers.dart';
import 'package:recipe_app/presentation/widgets/premium_feature_gate.dart';

class CookingModeScreen extends ConsumerStatefulWidget {
  final RecipeModel recipe;

  const CookingModeScreen({super.key, required this.recipe});

  @override
  ConsumerState<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends ConsumerState<CookingModeScreen> {
  late PageController _pageController;
  int _currentStep = 0;
  final Set<int> _completedSteps = {};
  final Map<int, Timer?> _stepTimers = {};
  final Map<int, int> _remainingSeconds = {};
  bool _voiceCommandsEnabled = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _enableWakeLock();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _disableWakeLock();
    _cancelAllTimers();
    super.dispose();
  }

  void _enableWakeLock() async {
    await WakelockPlus.enable();
  }

  void _disableWakeLock() async {
    await WakelockPlus.disable();
  }

  void _cancelAllTimers() {
    for (final timer in _stepTimers.values) {
      timer?.cancel();
    }
    _stepTimers.clear();
  }

  void _startTimer(int stepIndex, int seconds) {
    _cancelTimer(stepIndex);

    setState(() {
      _remainingSeconds[stepIndex] = seconds;
    });

    _stepTimers[stepIndex] = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) {
      setState(() {
        final remaining = _remainingSeconds[stepIndex]! - 1;
        if (remaining <= 0) {
          _cancelTimer(stepIndex);
          _showTimerComplete(stepIndex);
        } else {
          _remainingSeconds[stepIndex] = remaining;
        }
      });
    });
  }

  void _cancelTimer(int stepIndex) {
    _stepTimers[stepIndex]?.cancel();
    _stepTimers.remove(stepIndex);
    _remainingSeconds.remove(stepIndex);
  }

  void _showTimerComplete(int stepIndex) {
    if (!mounted) return;

    // Vibrate and show notification
    HapticFeedback.heavyImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Step ${stepIndex + 1} timer complete!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _toggleStepComplete(int stepIndex) {
    setState(() {
      if (_completedSteps.contains(stepIndex)) {
        _completedSteps.remove(stepIndex);
      } else {
        _completedSteps.add(stepIndex);
      }
    });
  }

  void _nextStep() {
    if (_currentStep < widget.recipe.steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.recipe.title,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          // Voice commands button (premium)
          IconButton(
            icon: Icon(
              _voiceCommandsEnabled ? Icons.mic : Icons.mic_off,
              color: _voiceCommandsEnabled ? Colors.green : Colors.white,
            ),
            onPressed: () {
              _showVoiceCommandsDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / widget.recipe.steps.length,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryColor,
            ),
          ),

          // Step counter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Step ${_currentStep + 1} of ${widget.recipe.steps.length}',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),

          // Step content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.recipe.steps.length,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              itemBuilder: (context, index) {
                final step = widget.recipe.steps[index];
                final isCompleted = _completedSteps.contains(index);
                final hasTimer = _remainingSeconds.containsKey(index);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step instruction
                      Text(
                        step.instruction,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Timer section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            if (hasTimer) ...[
                              Text(
                                _formatTime(_remainingSeconds[index]!),
                                style: TextStyle(
                                  color: _remainingSeconds[index]! <= 10
                                      ? Colors.red
                                      : Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _cancelTimer(index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Cancel Timer'),
                              ),
                            ] else ...[
                              const Text(
                                'Set a timer',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildTimerButton(index, 5 * 60, '5 min'),
                                  _buildTimerButton(index, 10 * 60, '10 min'),
                                  _buildTimerButton(index, 15 * 60, '15 min'),
                                  _buildTimerButton(index, 30 * 60, '30 min'),
                                  _buildTimerButton(index, 60 * 60, '1 hour'),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Complete checkbox
                      Container(
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green[900]
                              : Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CheckboxListTile(
                          title: Text(
                            'Mark as complete',
                            style: TextStyle(
                              color: isCompleted
                                  ? Colors.white
                                  : Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                          value: isCompleted,
                          onChanged: (_) => _toggleStepComplete(index),
                          activeColor: Colors.green,
                          checkColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentStep > 0 ? _previousStep : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                Text(
                  '${_completedSteps.length}/${widget.recipe.steps.length} completed',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                ElevatedButton.icon(
                  onPressed: _currentStep < widget.recipe.steps.length - 1
                      ? _nextStep
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerButton(int stepIndex, int seconds, String label) {
    return ElevatedButton(
      onPressed: () => _startTimer(stepIndex, seconds),
      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
      child: Text(label),
    );
  }

  void _showVoiceCommandsDialog() {
    final firebaseUser = ref.read(currentUserProvider).value;

    if (firebaseUser == null) {
      _showNeedPremiumDialog('Please sign in to use voice commands');
      return;
    }

    final userProfile = ref.read(userProfileProvider(firebaseUser.uid)).value;

    if (userProfile == null || !userProfile.hasPremiumAccess) {
      _showNeedPremiumDialog(null);
    } else {
      _showVoiceCommandsInfo();
    }
  }

  void _showNeedPremiumDialog(String? message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PremiumBadge(),
            const SizedBox(height: 16),
            Text(
              message ??
                  'Hands-free voice commands are a premium feature. Upgrade to Premium to unlock this feature!',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to premium screen
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _showVoiceCommandsInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Commands'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available voice commands:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• "Next step" - Go to next step'),
              Text('• "Previous step" - Go to previous step'),
              Text('• "Set timer 5 minutes" - Start a 5-minute timer'),
              Text('• "Complete step" - Mark current step as complete'),
              Text('• "Read step" - Read current step aloud'),
              SizedBox(height: 16),
              Text(
                'Note: Voice commands feature is coming soon!',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
