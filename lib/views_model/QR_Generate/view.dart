import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

// App utilities
import '../../ui_utils/utils.dart';
import '../../ui_utils/button.dart';
import '../../ui_utils/color_size_style.dart';

// QR generator scene - creates QR codes
class View extends StatelessWidget {
  const View({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider setup
    return ChangeNotifierProvider(
      create: (_) => ViewModel(),
      child: Builder(
        builder: (context) {
          final vm = context.watch<ViewModel>();
          return Scaffold(
            // App bar
            appBar: AppBar(title: const Text('QR Code Generator')),
            body: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive design
                final deviceType = ResponsiveUtils.getDeviceTypeFromConstraints(
                  constraints,
                );

                double horizontalPadding = ResponsiveUtils.responsiveScale(
                  mobile: 16.0,
                  deviceType: deviceType,
                );

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 20,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // QR Generator Options Section - Interactive selection cards

                        // Custom QR Generator Card - User input based QR creation
                        _buildQRCard(
                          context: context,
                          isLargeScreen: (deviceType != DeviceType.mobile),
                          title: 'Generate Custom QR',
                          subtitle: 'Create QR code from any text',
                          icon: Icons.qr_code,
                          color: Theme.of(context).primaryColor,
                          onTap: () => vm.setSelectedCard(
                            1,
                          ), // Activate custom generator
                        ),

                        SizedBox(height: 10),

                        // Predefined Company Website QR Card
                        _buildPreGeneratedQRCard(
                          context: context,
                          isLargeScreen: (deviceType != DeviceType.mobile),
                          title: 'Company Website',
                          name: 'Company Website QR',
                          description:
                              'Scan to visit Flutter Navigation Basics',
                          subtitle: 'https://flutter.dev',
                          icon: Icons.business,
                          color: AppColors.success,
                          qrData:
                              "https://docs.flutter.dev/cookbook/navigation/navigation-basics",
                          onTap: () => vm.setSelectedQR(
                            2, // Card ID
                            "https://docs.flutter.dev/cookbook/navigation/navigation-basics", // QR data
                            "Company Website QR", // Display name
                            "Scan to visit Flutter Navigation Basics", // Description
                          ),
                        ),

                        SizedBox(height: 10),

                        // Predefined YouTube QR Card
                        _buildPreGeneratedQRCard(
                          context: context,
                          isLargeScreen: (deviceType != DeviceType.mobile),
                          title: 'YouTube',
                          name: 'YouTube QR',
                          description: 'Scan to go to YouTube',
                          subtitle: 'https://www.youtube.com',
                          icon: Icons.video_library,
                          color: AppColors.error,
                          qrData: "https://www.youtube.com/",
                          onTap: () => vm.setSelectedQR(
                            3, // Card ID
                            "https://www.youtube.com/", // QR data
                            "YouTube QR", // Display name
                            "Scan to go to YouTube", // Description
                          ),
                        ),

                        SizedBox(height: 30),

                        // Dynamic QR Display Section - Shows selected generator interface

                        // Custom QR Generator Interface - Text input with live preview
                        if (vm.selectedCard == 1)
                          _buildCustomQRGenerator(
                            context,
                            vm,
                            (deviceType != DeviceType.mobile),
                            constraints,
                          ),

                        // Predefined QR Display Interface - Shows selected QR with info
                        if (vm.selectedCard > 1)
                          _buildPreGeneratedQRDisplay(
                            context,
                            vm,
                            (deviceType != DeviceType.mobile),
                            constraints,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildQRCard({
    required BuildContext context,
    required bool isLargeScreen,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4, // Shadow depth for material design
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap, // Handle card selection
        borderRadius: BorderRadius.circular(12), // Match card border radius
        child: Container(
          padding: EdgeInsets.all(
            isLargeScreen ? 20 : 16,
          ), // Responsive padding
          child: Row(
            children: [
              // Icon Container - Themed background with generator icon
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.1,
                  ), // Light tinted background
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: isLargeScreen ? 32 : 28),
              ),
              SizedBox(width: 16),

              // Text Content - Title and subtitle with responsive typography
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main title
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    // Subtitle description
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 14 : 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow Icon - Indicates interactivity
              Icon(
                Icons.arrow_forward_ios,
                size: isLargeScreen ? 20 : 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build custom QR code generator interface with text input and live preview
  Widget _buildCustomQRGenerator(
    BuildContext context,
    ViewModel vm,
    bool isLargeScreen,
    BoxConstraints constraints,
  ) {
    double qrSize = isLargeScreen
        ? (constraints.maxWidth * 0.3).clamp(200, 300)
        : (constraints.maxWidth * 0.6).clamp(200, 280);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).primaryColor.withValues(alpha: 0.05), // Light blue tinted background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        ), // Subtle blue border
      ),
      child: Column(
        children: [
          // Section Header
          Text(
            'Custom QR Generator',
            style: TextStyle(
              fontSize: isLargeScreen ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor, // Blue theme consistency
            ),
          ),
          SizedBox(height: 20),

          // Text Input Field - Real-time QR code generation
          TextField(
            decoration: InputDecoration(
              labelText: 'Enter any text',
              hintText: 'Type your message here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(
                context,
              ).cardColor, // White background for contrast
            ),
            onChanged: (value) =>
                vm.updateCustomText(value), // Live update QR code
          ),
          SizedBox(height: 20),

          // QR Code Display Container - Styled preview with shadow
          Container(
            width: qrSize,
            height: qrSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              // Material design shadow for depth
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(16), // Inner padding for QR code
            child: QrImageView(
              // Display user text or default message
              data: vm.customText.isEmpty ? 'Enter text above' : vm.customText,
              version: QrVersions.auto, // Automatic version selection
              size: qrSize - 32, // Account for container padding
              backgroundColor: Colors
                  .white, // QR code background - always white for readability
            ),
          ),

          SizedBox(height: AppSizes.spacingL),

          // Clear Selection Button - Reset generator state
          GTRButton(
            text: 'Clear Selection',
            onPressed: () => vm.clearSelection(),
            style: AppButtonStyles.error(context),
          ),
        ],
      ),
    );
  }

  /// Build predefined QR card for common services and websites
  Widget _buildPreGeneratedQRCard({
    required BuildContext context,
    required bool isLargeScreen,
    required String title,
    required String name,
    required String description,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String qrData,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4, // Material design shadow
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap, // Handle QR selection
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(
            isLargeScreen ? 20 : 16,
          ), // Responsive padding
          child: Row(
            children: [
              // Service Icon Container - Branded background
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(
                    0.1,
                  ), // Light service color background
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: isLargeScreen ? 32 : 28),
              ),
              SizedBox(width: 16),

              // Service Information - Title and URL/identifier
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service title
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    // URL or service identifier with text overflow handling
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 14 : 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2, // Limit to 2 lines
                      overflow:
                          TextOverflow.ellipsis, // Show ellipsis for long URLs
                    ),
                  ],
                ),
              ),

              // Selection Arrow - Visual indicator of interactivity
              Icon(
                Icons.arrow_forward_ios,
                size: isLargeScreen ? 20 : 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build display interface for selected predefined QR codes
  Widget _buildPreGeneratedQRDisplay(
    BuildContext context,
    ViewModel vm,
    bool isLargeScreen,
    BoxConstraints constraints,
  ) {
    // Calculate responsive QR code size based on screen dimensions
    // Same sizing logic as custom generator for consistency
    double qrSize = isLargeScreen
        ? (constraints.maxWidth * 0.3).clamp(200, 300)
        : (constraints.maxWidth * 0.6).clamp(200, 280);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(
          0.05,
        ), // Light green background for predefined QR
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
        ), // Green border theme
      ),
      child: Column(
        children: [
          // QR Code Title - Service name or generic title
          Text(
            vm.selectedQRName.isEmpty ? 'Generated QR Code' : vm.selectedQRName,
            style: TextStyle(
              fontSize: isLargeScreen ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: AppColors.success, // Green theme for predefined content
            ),
          ),
          SizedBox(height: 20),

          // QR Code Display Container - Styled with shadow and padding
          Container(
            width: qrSize,
            height: qrSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              // Material design elevation shadow
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(16), // Inner padding around QR code
            child: QrImageView(
              data: vm.selectedQRData, // Data from selected predefined QR
              version: QrVersions.auto, // Automatic QR version detection
              size: qrSize - 32, // Account for container padding
              backgroundColor:
                  Colors.white, // QR background - always white for readability
            ),
          ),

          SizedBox(height: 15),

          // QR Code Description - Instructions for user
          Text(
            vm.selectedQRDescription.isEmpty
                ? 'Scan to access content' // Generic fallback description
                : vm.selectedQRDescription, // Service-specific description
            style: TextStyle(
              fontSize: isLargeScreen ? 16 : 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSizes.spacingL),

          // Clear Selection Button - Return to selection interface
          GTRButton(
            text: 'Clear Selection',
            onPressed: () => vm.clearSelection(),
            style: AppButtonStyles.error(context),
          ),
        ],
      ),
    );
  }
}

class ViewModel extends ChangeNotifier {
  // Selection State Management - Tracks which QR generator is active
  dynamic selectedCard = 0; // 0=none, 1=custom, 2+=predefined QR IDs

  // Custom QR Generation - User input text for generating personalized QR codes
  dynamic customText = 'Hello World!'; // Default text for custom QR generation

  // Legacy Properties - Maintained for backwards compatibility
  dynamic linkText = ''; // Reserved for future link-specific QR generation
  dynamic text = 'apple'; // Legacy text property for older code compatibility

  // Selected QR Information - Data for currently displayed predefined QR
  dynamic selectedQRData = ''; // The actual data/URL encoded in the QR code
  dynamic selectedQRName = ''; // Display name for the selected QR code
  dynamic selectedQRDescription = ''; // User instruction for what scanning does

  void setSelectedCard(int cardNumber) {
    selectedCard = cardNumber; // Update active generator
    notifyListeners(); // Trigger UI rebuild
  }

  void setSelectedQR(
    int cardNumber,
    String qrData,
    String name,
    String description,
  ) {
    selectedCard = cardNumber; // Set active card
    selectedQRData = qrData; // Store QR data/URL
    selectedQRName = name; // Store display name
    selectedQRDescription = description; // Store user instructions
    notifyListeners(); // Update UI with new selection
  }

  void updateCustomText(String newText) {
    customText = newText; // Store new text
    notifyListeners(); // Trigger QR code regeneration in UI
  }

  void updateLinkText(String newText) {
    linkText = newText; // Store link text
    notifyListeners(); // Update reactive UI
  }

  void updateText(String newText) {
    text = newText; // Update legacy text
    notifyListeners(); // Trigger UI updates
  }

  void clearSelection() {
    selectedCard = 0; // Clear active selection
    selectedQRData = ''; // Clear QR data
    selectedQRName = ''; // Clear display name
    selectedQRDescription = ''; // Clear description
    notifyListeners(); // Return UI to selection state
  }
}
