import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui_utils/utils.dart';
import '../../services/auth_service.dart';

import '../Login_Scene/view.dart' as loginscene;
import '../Main_Scene/main.dart' as mainscene;

class View extends StatelessWidget {
  const View({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ViewModel(),
      child: Builder(
        builder: (context) {
          final vm = context.watch<ViewModel>();

          // Check if we should navigate
          if (vm.shouldNavigate && vm.navigationDestination != null) {
            // Use addPostFrameCallback to navigate after the current build is complete
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => vm.navigationDestination!,
                ),
              );
            });
          }

          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 240, 248, 255),
                    Color.fromARGB(255, 220, 238, 255),
                  ],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final deviceType =
                      ResponsiveUtils.getDeviceTypeFromConstraints(constraints);
                  final screenHeight = constraints.maxHeight;

                  return SafeArea(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              // Welcome text section
                              Expanded(
                                flex: 1, // Tighter flex in landscape
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        (deviceType != DeviceType.mobile)
                                        ? 48
                                        : (24), // Reduced padding in landscape
                                  ),
                                  child: AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: const Duration(
                                      milliseconds: 1500,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Welcome',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize:
                                                (deviceType !=
                                                    DeviceType.mobile)
                                                ? (42) // Smaller in landscape
                                                : (32), // Smaller in landscape
                                            fontWeight: FontWeight.w300,
                                            color: const Color.fromARGB(
                                              255,
                                              3,
                                              52,
                                              92,
                                            ),
                                            letterSpacing: 2.0,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 16,
                                        ), // Much tighter spacing
                                        Text(
                                          'Génie Télécoms et Réseaux',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize:
                                                (deviceType !=
                                                    DeviceType.mobile)
                                                ? (24) // Smaller in landscape
                                                : (18), // Smaller in landscape
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromARGB(
                                              255,
                                              3,
                                              52,
                                              92,
                                            ),
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Logo section
                              Expanded(
                                flex: 2, // Already tight, keep as is
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        (deviceType != DeviceType.mobile)
                                        ? 64
                                        : (32), // Reduced padding in landscape
                                  ),
                                  child: AnimatedScale(
                                    scale: vm.isLoading ? 0.9 : 1.0,
                                    duration: const Duration(
                                      milliseconds: 1200,
                                    ),
                                    curve: Curves.elasticOut,
                                    child: AnimatedOpacity(
                                      opacity: 1.0,
                                      duration: const Duration(
                                        milliseconds: 1500,
                                      ),
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth:
                                              (deviceType != DeviceType.mobile)
                                              ? 400
                                              : 300,
                                          maxHeight:
                                              (deviceType != DeviceType.mobile)
                                              ? (350) // Much smaller in landscape
                                              : (250), // Much smaller in landscape
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              spreadRadius: 5,
                                              blurRadius: 15,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: Image.asset(
                                            'lib/assets/gtr_logo.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Loading indicator section
                              Expanded(
                                flex: 2,
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        (deviceType != DeviceType.mobile)
                                        ? 48
                                        : 24,
                                  ),
                                  child: AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: const Duration(
                                      milliseconds: 1500,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (vm.isLoading) ...[
                                          // Progress indicator - using LinearProgressIndicator
                                          SizedBox(
                                            width:
                                                (deviceType !=
                                                    DeviceType.mobile)
                                                ? 200
                                                : 150,
                                            height: 6,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              child: LinearProgressIndicator(
                                                value: vm.loadingProgress,
                                                backgroundColor:
                                                    Colors.grey[300],
                                                valueColor:
                                                    const AlwaysStoppedAnimation<
                                                      Color
                                                    >(
                                                      Color.fromARGB(
                                                        255,
                                                        3,
                                                        52,
                                                        92,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height:
                                                20, // Much tighter in landscape
                                          ),
                                          Text(
                                            vm.loadingMessage,
                                            style: TextStyle(
                                              fontSize:
                                                  (deviceType !=
                                                      DeviceType.mobile)
                                                  ? (18)
                                                  : (16),
                                              fontWeight: FontWeight.w500,
                                              color: const Color.fromARGB(
                                                255,
                                                3,
                                                52,
                                                92,
                                              ),
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          SizedBox(
                                            height:
                                                12, // Much tighter in landscape
                                          ),
                                          Text(
                                            '${(vm.loadingProgress * 100).toInt()}%',
                                            style: TextStyle(
                                              fontSize:
                                                  (deviceType !=
                                                      DeviceType.mobile)
                                                  ? (16)
                                                  : (14),
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ] else ...[
                                          // Completion state
                                          Icon(
                                            Icons.check_circle,
                                            size:
                                                (deviceType !=
                                                    DeviceType.mobile)
                                                ? 60
                                                : (50),
                                            color: AppColors.success,
                                          ),
                                          SizedBox(
                                            height: 20, // Tighter in landscape
                                          ),
                                          Text(
                                            vm.loadingMessage,
                                            style: TextStyle(
                                              fontSize:
                                                  (deviceType !=
                                                      DeviceType.mobile)
                                                  ? (20)
                                                  : (18),
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.success,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Bottom spacing - much reduced in landscape
                              SizedBox(
                                height:
                                    screenHeight *
                                    (0.03), // Much tighter in landscape
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class ViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  double _loadingProgress = 0.0;
  String _loadingMessage = 'Loading...';
  Widget? _navigationDestination;

  bool get isLoading => _isLoading;
  double get loadingProgress => _loadingProgress;
  String get loadingMessage => _loadingMessage;
  Widget? get navigationDestination => _navigationDestination;

  ViewModel() {
    _startLoading();
  }

  void _startLoading() async {
    // Simulate loading process with auth check
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      _loadingProgress = i / 100;

      if (i < 30) {
        _loadingMessage = 'Initializing...';
      } else if (i < 60) {
        _loadingMessage = 'Checking authentication...';
      } else if (i < 90) {
        _loadingMessage = 'Almost ready...';
      } else {
        _loadingMessage = 'Complete!';
      }

      notifyListeners();
    }

    // Wait a bit more then mark as complete
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoading = false;

    // Check authentication status
    final user = _authService.currentUser;
    if (user != null) {
      _loadingMessage = 'Welcome back!';
      _navigationDestination = mainscene.View();
    } else {
      _loadingMessage = 'Please login';
      _navigationDestination = loginscene.View();
    }

    notifyListeners();

    // Auto-navigate after a brief delay to show completion
    await Future.delayed(const Duration(milliseconds: 1500));
    _navigateToNextScene();
  }

  void _navigateToNextScene() {
    _shouldNavigate = true;
    notifyListeners();
  }

  bool _shouldNavigate = false;
  bool get shouldNavigate => _shouldNavigate;

  void resetLoading() {
    _isLoading = true;
    _loadingProgress = 0.0;
    _loadingMessage = 'Loading...';
    _shouldNavigate = false;
    _navigationDestination = null;
    notifyListeners();
    _startLoading();
  }
}
