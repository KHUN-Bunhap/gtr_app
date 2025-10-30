import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui_utils/utils.dart';

// Credits scene - project acknowledgments
class View extends StatelessWidget {
  const View({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider setup
    return ChangeNotifierProvider(
      create: (_) => ViewModel(),
      child: Builder(
        builder: (context) {
          // final vm = context.watch<ViewModel>();
          return Scaffold(
            // App bar
            appBar: UIHelpers.gtrAppBar(title: 'Credits', context: context),
            body: Stack(
              fit: StackFit.expand,
              children: [
                // Main content - full screen scrollable area
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),

                          // Project Supervisor Section
                          _buildCreditSection(
                            context: context,
                            role: 'PROJECT SUPERVISOR',
                            name: 'Dr. MUY Sengly',
                          ),

                          SizedBox(height: 40),

                          // Developer Section
                          _buildCreditSection(
                            context: context,
                            role: 'DEVELOPER',
                            name: 'KHUN Bunhap',
                          ),

                          SizedBox(height: 100), // Bottom spacing
                        ],
                      ),
                    ),
                  ),
                ),

                // Version info positioned at bottom right corner
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: IgnorePointer(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Version: Beta',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper method to build credit sections
  Widget _buildCreditSection({
    required BuildContext context,
    required String role,
    required String name,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Role/Title Text
        Text(
          role,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).primaryColor,
          ),
        ),

        SizedBox(height: 8),

        // Name Text
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}

// ViewModel for Credits functionality
class ViewModel extends ChangeNotifier {
  // Add any credit-related state management here if needed
}
