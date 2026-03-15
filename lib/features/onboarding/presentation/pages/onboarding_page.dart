import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/route_names.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Privacy by Default, With Zero Ads or Hidden Tracking',
      'subtitle': 'No ads. No trackers. No third-party analytics.',
    },
    {
      'title': 'Insights That Help You Spend Better Without Complexity',
      'subtitle': 'See category-wise spending, recent activity.',
    },
    {
      'title': 'Local-First Tracking That Stays Fully On Your Device',
      'subtitle': 'Your finances stay on your phone.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onSkip();
    }
  }

  void _onBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _onSkip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.kOnboardingComplete, true);
    if (mounted) context.go(RouteNames.phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboard_background.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Gradient Overlay for "Fading to Black" look
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.black.withValues(alpha: 0.1),
                    AppColors.black.withValues(alpha: 0.4),
                    AppColors.black.withValues(alpha: 0.9),
                    AppColors.black,
                  ],
                  stops: const [0.0, 0.3, 0.8, 1.0],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Skip Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_currentPage < 2)
                        TextButton(
                          onPressed: _onSkip,
                          child: const Text(
                            'SKIP',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 48), // maintain height
                    ],
                  ),
                ),
                
                // Fullscreen swipeable area
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Page Indicators
                            Row(
                              children: List.generate(_pages.length, (dotIndex) {
                                return Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      right: dotIndex < _pages.length - 1 ? 12.0 : 0,
                                    ),
                                    height: 2.5,
                                    decoration: BoxDecoration(
                                      color: _currentPage == dotIndex 
                                          ? AppColors.white 
                                          : AppColors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 40),
                            
                            Text(
                              _pages[index]['title']!,
                              style: AppTextStyles.onboardingTitle,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _pages[index]['subtitle']!,
                              style: AppTextStyles.onboardingBody.copyWith(
                                color: AppColors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 140), // space for buttons
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Bottom Navigation Buttons
          Positioned(
            left: 24,
            right: 24,
            bottom: 24 + MediaQuery.of(context).padding.bottom,
            child: Row(
              children: [
                if (_currentPage > 0) ...[
                  GestureDetector(
                    onTap: _onBack,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white.withValues(alpha: 0.5), width: 1.5),
                      ),
                      child: const Icon(Icons.arrow_back, color: AppColors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.onboardingBlue,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(double.infinity, 56),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _onNext,
                    child: Text(
                      _currentPage == 2 ? 'Get Started' : 'Next',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
}
