// Import Flutter material design components for UI elements
import 'package:flutter/material.dart';
// Import Flutter Markdown package for rendering formatted text content
import 'package:flutter_markdown/flutter_markdown.dart';
// Import Provider package for state management and reactive programming
import 'package:provider/provider.dart';

import '../../ui_utils/utils.dart';

class View extends StatelessWidget {
  const View({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ViewModel(),
      child: Builder(
        builder: (context) {
          final vm = context.watch<ViewModel>();
          return Scaffold(
            appBar: UIHelpers.gtrAppBar(title: 'About', context: context),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final deviceType = ResponsiveUtils.getDeviceTypeFromConstraints(
                  constraints,
                );

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    // Ensure minimum height for proper content layout
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      // Responsive padding using ResponsiveUtils
                      padding: EdgeInsets.all(
                        ResponsiveUtils.responsiveScale(
                          mobile: 16.0,
                          deviceType: deviceType,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // GTR Logo and Branding Section - Department identification
                          Center(
                            child: Column(
                              children: [
                                SizedBox(height: 16),

                                // GTR Logo Container - with shadow and responsive sizing
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    // Subtle shadow for depth and visual appeal
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      'lib/assets/gtr_logo.png',
                                      width: (deviceType != DeviceType.mobile)
                                          ? 200
                                          : 150, // Tablet: larger logo
                                      height: (deviceType != DeviceType.mobile)
                                          ? 200
                                          : 150, // Phone: smaller logo
                                      fit: BoxFit.contain,
                                      // Error handling for missing logo file
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width:
                                                  (deviceType !=
                                                      DeviceType.mobile)
                                                  ? 200
                                                  : 150,
                                              height:
                                                  (deviceType !=
                                                      DeviceType.mobile)
                                                  ? 200
                                                  : 150,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.image_not_supported,
                                                size:
                                                    (deviceType !=
                                                        DeviceType.mobile)
                                                    ? 60
                                                    : 50,
                                                color: Colors.grey[600],
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),

                                SizedBox(height: 8),
                                // Department full name subtitle
                                Text(
                                  'Department of Telecommunications and Networks Engineering',
                                  style: TextStyle(
                                    fontSize: (deviceType != DeviceType.mobile)
                                        ? 14
                                        : 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 24),
                              ],
                            ),
                          ),

                          // Markdown Content Display Section - Rich formatted text content
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(
                              (deviceType != DeviceType.mobile) ? 20 : 16,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.white
                                  : Colors.grey[900],
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                              // Subtle elevation for card-like appearance
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Markdown(
                              data: vm
                                  .markdownContent, // Rich content from ViewModel
                              shrinkWrap: true, // Minimize height usage
                              physics:
                                  const NeverScrollableScrollPhysics(), // Disable internal scrolling
                              // Custom styling for markdown elements with GTR branding
                              styleSheet: MarkdownStyleSheet(
                                // Header styling with GTR brand color
                                h1: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: (deviceType != DeviceType.mobile)
                                      ? 24
                                      : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                h2: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: (deviceType != DeviceType.mobile)
                                      ? 20
                                      : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                h3: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: (deviceType != DeviceType.mobile)
                                      ? 18
                                      : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                // Body text styling with improved readability
                                p: TextStyle(
                                  fontSize: (deviceType != DeviceType.mobile)
                                      ? 16
                                      : 14,
                                  height:
                                      1.5, // Line height for better readability
                                ),
                                // Code styling for technical content
                                code: TextStyle(
                                  backgroundColor: Colors.grey[200],
                                  fontFamily: 'monospace',
                                  fontSize: (deviceType != DeviceType.mobile)
                                      ? 14
                                      : 12,
                                ),
                                codeblockDecoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                // Blockquote styling for emphasis
                                blockquote: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.grey[700]
                                      : Colors.grey[300],
                                  fontStyle: FontStyle.italic,
                                  fontSize: (deviceType != DeviceType.mobile)
                                      ? 16
                                      : 14,
                                ),
                                blockquoteDecoration: BoxDecoration(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.blue[50]
                                      : Colors.grey[800],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border(
                                    left: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 4,
                                    ),
                                  ),
                                ),
                                // List styling with brand colors
                                listBullet: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: (deviceType != DeviceType.mobile)
                                      ? 16
                                      : 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
}

class ViewModel extends ChangeNotifier {
  String get markdownContent => '''
# Welcome to GTR App!
## Version Beta

- Currently this app is still in Beta testing phase but fortunately, all main features are functional.
- The app is made exclusively for **I4 Students** only as of now.
- Everything should work as expected, but if you encounter any issues, please don't hesitate to reach out to me on Telegram.
- I recommend using your password like your ID for signing up as I don't have a server of my own yet.
- The *Post Scene* has **Markdown** and **Math Fork** support.
- The app will have more features and improvements in the future updates. (If I'm not lazy)
- Unfortunately for iOS users, it costs money to publish the app unlike Android which is free.
- iOS/Mac users will need to use Website version for now.
- Don't post images as the storage also cost money.
- Don't refresh feed too often.
- You can refresh by going to another tab and back.
- If you forgot your password and tried resetting it, the app will send the reset link to the email your email address. You can check it in your **Spam/Junk** folder if you don't see it in your inbox.

## Frontend
- This app is developed using **Flutter** framework which allows cross-platform compatibility.

## Backend
- Currently using **Firebase** services for authentication and data storage.

## Easter Egg
- Try tapping on the logo in the main scene and see what happens!

### AI Assistance
- Copilot
- Chat GPT

### Contact Information:
- **Telegram**: [https://t.me/Khunbunhap](https://t.me/Khunbunhap)
- **ITC**: [ITC Facebook Page](https://www.facebook.com/itckh/)
- **GTR**: [GTR Facebook Page](https://www.facebook.com/itcgtr/)

---
''';
}
