import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as mlkit;
import 'package:url_launcher/url_launcher.dart';
import '../../ui_utils/utils.dart';
import '../../ui_utils/button.dart';
import '../../ui_utils/color_size_style.dart';

class View extends StatefulWidget {
  const View({super.key});

  @override
  State<View> createState() => _ViewState();
}

/// Main state class for QR scanner with lifecycle management
class _ViewState extends State<View> {
  /// Check if the scanned data contains a valid link
  bool _isValidLink(String data) {
    return data.startsWith('http://') ||
        data.startsWith('https://') ||
        data.startsWith('www.') ||
        (data.contains('.') && data.contains('com'));
  }

  /// Build comprehensive QR scanning interface with camera and image upload
  /// Creates responsive layout with live scanner, results display, and action buttons
  @override
  Widget build(BuildContext context) {
    // Set up ChangeNotifierProvider for QR scanning state management
    return ChangeNotifierProvider(
      create: (_) =>
          ViewModel(), // Create ViewModel with barcode scanner initialization
      child: Builder(
        builder: (context) {
          // Watch ViewModel for state changes and reactive UI updates
          final vm = context.watch<ViewModel>();

          // Provide context to ViewModel for image picker and snackbar functionality
          vm.setContext(context);

          return Scaffold(
            // App Bar with QR scanner title and GTR theme
            appBar: UIHelpers.gtrAppBar(title: 'Scan QR', context: context),
            body: LayoutBuilder(
              builder: (context, constraints) {
                // Comprehensive responsive design detection
                final deviceType = ResponsiveUtils.getDeviceTypeFromConstraints(
                  constraints,
                );

                // Dynamic padding using ResponsiveUtils for consistent behavior
                final horizontalPaddingValue =
                    (deviceType == DeviceType.computer)
                    ? constraints.maxWidth * 0.12
                    : (deviceType != DeviceType.mobile)
                    ? constraints.maxWidth * 0.15
                    : 16.0;

                // Scanner dimensions optimized for different device types
                final scannerHeight = (deviceType == DeviceType.computer)
                    ? constraints.maxHeight *
                          0.35 // 35% height on computers
                    : (deviceType != DeviceType.mobile)
                    ? constraints.maxHeight *
                          0.4 // 40% height on tablets
                    : constraints.maxHeight * 0.5; // 50% height on phones

                final scannerWidth = (deviceType == DeviceType.computer)
                    ? constraints.maxWidth *
                          0.45 // 45% width on computers
                    : (deviceType != DeviceType.mobile)
                    ? constraints.maxWidth *
                          0.5 // 50% width on tablets
                    : constraints.maxWidth -
                          (horizontalPaddingValue *
                              2); // Full width minus padding

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPaddingValue,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      // User Instructions Section - Guide for proper scanning technique
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(
                            0.1,
                          ), // Light blue background
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(
                              0.3,
                            ), // Subtle blue border
                          ),
                        ),
                        child: Row(
                          children: [
                            // Info icon
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: (deviceType == DeviceType.computer)
                                  ? 32
                                  : ((deviceType != DeviceType.mobile)
                                        ? 28
                                        : 24),
                            ),
                            SizedBox(width: 12),
                            // Instruction text
                            Expanded(
                              child: Text(
                                'Point your camera at a QR code to scan it',
                                style: TextStyle(
                                  fontSize: (deviceType == DeviceType.computer)
                                      ? 18
                                      : ((deviceType != DeviceType.mobile)
                                            ? 16
                                            : 14),
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // QR Scanner Container - Live camera view with styling and error handling
                      Center(
                        child: Container(
                          width: scannerWidth,
                          height: scannerHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.blue,
                              width: 3,
                            ), // Blue border frame
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.3),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Scanner Content - Camera view or paused state
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: vm.isScanning
                                    ? MobileScanner(
                                        // Handle QR code detection from camera stream
                                        onDetect: (capture) {
                                          try {
                                            // Process detected barcodes
                                            for (final barcode
                                                in capture.barcodes) {
                                              if (barcode.rawValue != null &&
                                                  barcode
                                                      .rawValue!
                                                      .isNotEmpty) {
                                                vm.handleScannedCode(
                                                  barcode.rawValue!,
                                                );
                                                break; // Only process first valid barcode
                                              }
                                            }
                                          } catch (e) {
                                            // Error processing barcode
                                          }
                                        },
                                        fit: BoxFit.cover,
                                        // Error handling for camera issues
                                        errorBuilder: (context, error) {
                                          return Container(
                                            color: Colors.black,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.camera_alt_outlined,
                                                    color: Colors.white,
                                                    size: 64,
                                                  ),
                                                  SizedBox(height: 16),
                                                  Text(
                                                    'Camera Error',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'Please check camera permissions\nError: ${error.toString()}',
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(
                                                    height: AppSizes.spacingM,
                                                  ),
                                                  // Retry button for camera errors
                                                  GTRButton.primary(
                                                    text: 'Retry',
                                                    icon: Icons.refresh,
                                                    onPressed: () =>
                                                        vm.resumeScanning(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    :
                                      // Paused Scanner State - Show when scanning is temporarily stopped
                                      Container(
                                        color: Colors.black87,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.pause_circle_outline,
                                                color: Colors.white,
                                                size: 64,
                                              ),
                                              SizedBox(height: 16),
                                              Text(
                                                'Scanning Paused',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),

                              // Status Indicator Overlay - Shows scanning status
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Scanning...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 30),

                      // Scanned result display
                      if (vm.scannedData.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: AppColors.success,
                                    size: (deviceType == DeviceType.computer)
                                        ? 32
                                        : ((deviceType != DeviceType.mobile)
                                              ? 28
                                              : 24),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Scanned Successfully!',
                                    style: TextStyle(
                                      fontSize:
                                          (deviceType == DeviceType.computer)
                                          ? 20
                                          : ((deviceType != DeviceType.mobile)
                                                ? 18
                                                : 16),
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SelectableText(
                                  vm.scannedData,
                                  style: TextStyle(
                                    fontSize:
                                        (deviceType == DeviceType.computer)
                                        ? 16
                                        : ((deviceType != DeviceType.mobile)
                                              ? 14
                                              : 12),
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: GTRButton(
                                      text: 'Clear',
                                      icon: Icons.clear,
                                      onPressed: () => vm.clearScannedData(),
                                      style: AppButtonStyles.error(context),
                                    ),
                                  ),
                                  SizedBox(width: AppSizes.spacingS),
                                  Expanded(
                                    child: GTRButton(
                                      text: 'Scan Again',
                                      icon: Icons.qr_code_scanner,
                                      onPressed: () => vm.resumeScanning(),
                                      style: AppButtonStyles.warning(context),
                                    ),
                                  ),
                                  if (_isValidLink(vm.scannedData)) ...[
                                    SizedBox(width: AppSizes.spacingS),
                                    Expanded(
                                      child: GTRButton(
                                        text: 'Open Link',
                                        icon: Icons.open_in_new,
                                        onPressed: () =>
                                            vm.openUrlDirectly(vm.scannedData),
                                        style: AppButtonStyles.success(context),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: "upload",
                  onPressed: () => vm.pickImageAndScan(),
                  backgroundColor: AppColors.warning,
                  tooltip: 'Upload QR Image',
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ViewModel extends ChangeNotifier {
  String scannedData = '';
  bool isScanning = true;
  DateTime? lastScanTime;
  final ImagePicker _picker = ImagePicker();
  mlkit.BarcodeScanner? _barcodeScanner;
  BuildContext? _context;

  ViewModel() {
    _initializeBarcodeScanner();
  }

  void _initializeBarcodeScanner() {
    try {
      _barcodeScanner = mlkit.BarcodeScanner();
    } catch (e) {
      // Error initializing barcode scanner
    }
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  void handleScannedCode(String code) {
    // Prevent duplicate scans within 2 seconds
    final now = DateTime.now();
    if (lastScanTime != null &&
        now.difference(lastScanTime!).inSeconds < 2 &&
        scannedData == code) {
      return;
    }

    scannedData = code;
    lastScanTime = now;
    isScanning = false;
    notifyListeners();

    // Auto-resume scanning after 3 seconds for continuous scanning
    Future.delayed(Duration(seconds: 3), () {
      if (!isScanning) {
        resumeScanning();
      }
    });
  }

  Future<void> pickImageAndScan() async {
    if (_context == null) {
      scannedData = 'Error: App context not available. Please try again.';
      notifyListeners();
      return;
    }

    try {
      // Show options for camera or gallery
      final XFile? image = await showModalBottomSheet<XFile?>(
        context: _context!,
        builder: (context) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select QR Code Image',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppSizes.spacingL),
              Row(
                children: [
                  Expanded(
                    child: GTRButton(
                      text: 'Gallery',
                      icon: Icons.photo_library,
                      onPressed: () async {
                        try {
                          final image = await _picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 1024,
                            maxHeight: 1024,
                          );
                          Navigator.pop(context, image);
                        } catch (e) {
                          Navigator.pop(context, null);
                        }
                      },
                      style: AppButtonStyles.warning(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      if (image != null) {
        await _scanImageFile(image.path);
      }
    } catch (e) {
      scannedData = '''Image Upload Error

Could not access image picker. This might be due to:
• Missing app permissions
• Camera/storage not available
• System error

Try using the live camera scanner instead!

Error details: $e''';
      isScanning = false;
      notifyListeners();
    }
  }

  Future<void> _scanImageFile(String imagePath) async {
    if (_barcodeScanner == null) {
      scannedData =
          'Error: QR scanner not initialized. Please restart the app.';
      isScanning = false;
      notifyListeners();
      return;
    }

    try {
      final inputImage = mlkit.InputImage.fromFilePath(imagePath);
      final List<mlkit.Barcode> barcodes = await _barcodeScanner!.processImage(
        inputImage,
      );

      if (barcodes.isNotEmpty) {
        // Process the first detected barcode
        final barcode = barcodes.first;
        if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
          scannedData = barcode.rawValue!;
          isScanning = false;
          notifyListeners();

          // Show success message
          if (_context != null) {
            ScaffoldMessenger.of(_context!).showSnackBar(
              SnackBar(
                content: Text('QR Code detected successfully!'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          _showNoQRFoundMessage();
        }
      } else {
        _showNoQRFoundMessage();
      }
    } catch (e) {
      scannedData =
          'Error: Could not scan QR code from image. Please try a clearer image.';
      isScanning = false;
      notifyListeners();

      if (_context != null) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text('Error scanning image. Please try again.'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showNoQRFoundMessage() {
    scannedData = '''No QR Code Found

The selected image doesn't contain a detectable QR code.

Tips for better detection:
• Ensure the QR code is clearly visible
• Use good lighting when taking photos
• Keep the QR code straight and unobstructed
• Try a higher resolution image

Banking apps work best with clear, well-lit QR codes!

Tap "Scan Again" to try camera scanning.''';

    isScanning = false;
    notifyListeners();

    if (_context != null) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text('No QR code found in the selected image'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _barcodeScanner?.close();
    super.dispose();
  }

  void clearScannedData() {
    scannedData = '';
    resumeScanning();
  }

  void resumeScanning() {
    isScanning = true;
    notifyListeners();
  }

  void showLinkPanel(String url) {
    if (_context == null) return;

    showDialog(
      context: _context!,
      builder: (context) => LinkActionPanel(url: url),
    );
  }

  void openUrl(String url) {
    // Show panel instead of directly opening URL
    showLinkPanel(url);
  }

  Future<void> openUrlDirectly(String url) async {
    try {
      String finalUrl = url.trim(); // Remove whitespace

      // Enhanced URL normalization
      if (finalUrl.startsWith('www.')) {
        finalUrl = 'https://$finalUrl';
      } else if (finalUrl.startsWith('http://') ||
          finalUrl.startsWith('https://')) {
        // URL already has protocol, use as-is
        finalUrl = finalUrl;
      } else if (finalUrl.contains('.') &&
          (finalUrl.contains('.com') ||
              finalUrl.contains('.org') ||
              finalUrl.contains('.net') ||
              finalUrl.contains('.edu') ||
              finalUrl.contains('.gov') ||
              finalUrl.contains('.mil'))) {
        // Looks like a domain, add https://
        finalUrl = 'https://$finalUrl';
      } else {
        // Not a valid web URL, show error
        if (_context != null) {
          ScaffoldMessenger.of(_context!).showSnackBar(
            SnackBar(
              content: Text('Not a valid web URL: $url'),
              backgroundColor: AppColors.warning,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Parse and validate URL
      final uri = Uri.parse(finalUrl);

      // Check if URL can be launched
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        // Try to launch URL
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Show success message
        if (_context != null) {
          ScaffoldMessenger.of(_context!).showSnackBar(
            SnackBar(
              content: Text('Opening: $finalUrl'),
              backgroundColor: Theme.of(_context!).primaryColor,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // URL cannot be launched
        // Try with different launch mode
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);

          if (_context != null) {
            ScaffoldMessenger.of(_context!).showSnackBar(
              SnackBar(
                content: Text('Opening: $finalUrl'),
                backgroundColor: Theme.of(_context!).primaryColor,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (altError) {
          if (_context != null) {
            ScaffoldMessenger.of(_context!).showSnackBar(
              SnackBar(
                content: Text(
                  'Cannot open URL: $finalUrl\nTry copying and pasting in browser',
                ),
                backgroundColor: AppColors.error,
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
      }
    } catch (e) {
      // Enhanced error handling
      if (_context != null) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text('Error opening URL: $url\nDetails: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }
}

/// Link Action Panel - Interactive dialog for handling QR code links
/// Provides options to open, copy, or preview links with responsive design
class LinkActionPanel extends StatelessWidget {
  final String url;

  const LinkActionPanel({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveUtils.getDeviceTypeFromConstraints(
          constraints,
        );

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.link,
                color: Theme.of(context).primaryColor,
                size: (deviceType == DeviceType.computer)
                    ? 28
                    : ((deviceType != DeviceType.mobile) ? 24 : 20),
              ),
              SizedBox(width: 8),
              Text(
                'Link Detected',
                style: TextStyle(
                  fontSize: (deviceType == DeviceType.computer)
                      ? 20
                      : ((deviceType != DeviceType.mobile) ? 18 : 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Container(
            constraints: BoxConstraints(
              maxWidth: (deviceType == DeviceType.computer)
                  ? 500
                  : ((deviceType != DeviceType.mobile) ? 400 : 300),
              minWidth: (deviceType == DeviceType.computer)
                  ? 400
                  : ((deviceType != DeviceType.mobile) ? 300 : 250),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QR code contains a link:',
                  style: TextStyle(
                    fontSize: (deviceType == DeviceType.computer)
                        ? 16
                        : ((deviceType != DeviceType.mobile) ? 14 : 12),
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SelectableText(
                    url,
                    style: TextStyle(
                      fontSize: (deviceType == DeviceType.computer)
                          ? 14
                          : ((deviceType != DeviceType.mobile) ? 12 : 10),
                      fontFamily: 'monospace',
                      color: Colors.blue[800],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'What would you like to do?',
                  style: TextStyle(
                    fontSize: (deviceType == DeviceType.computer)
                        ? 16
                        : ((deviceType != DeviceType.mobile) ? 14 : 12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.close,
                size: (deviceType == DeviceType.computer) ? 20 : 16,
              ),
              label: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: (deviceType == DeviceType.computer) ? 14 : 12,
                ),
              ),
            ),
            GTRButton.primary(
              text: 'Copy Link',
              icon: Icons.copy,
              onPressed: () {
                _copyToClipboard(context, url);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link copied to clipboard'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
