import 'package:flutter/material.dart';
import 'color_size_style.dart';
import 'device_font.dart';

/// Customizable text field component with GTR styling and validation
class GTRTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isValid;
  final String? validMessage;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool enabled;
  final String? hintText;
  final int? maxLines;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final Widget? suffixIcon;

  const GTRTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.isValid = false,
    this.validMessage,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.enabled = true,
    this.hintText,
    this.maxLines = 1,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveUtils.getDeviceTypeFromConstraints(
          constraints,
        );

        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: controller,
                validator: validator,
                obscureText: obscureText,
                keyboardType: keyboardType,
                enabled: enabled,
                maxLines: maxLines,
                onChanged: onChanged,
                onTap: onTap,
                readOnly: readOnly,
                style: TextStyle(
                  fontSize: deviceType != DeviceType.mobile ? 16 : 14,
                  color: enabled
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hintText,
                  prefixIcon: icon != null
                      ? Icon(
                          icon,
                          color: isValid
                              ? AppColors.success
                              : Theme.of(context).primaryColor,
                          size: deviceType != DeviceType.mobile ? 24 : 20,
                        )
                      : null,
                  suffixIcon: suffixIcon,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: BorderSide(
                      color: isValid
                          ? AppColors.success
                          : Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: BorderSide(
                      color: isValid
                          ? AppColors.success
                          : Theme.of(context).primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: BorderSide(color: AppColors.error, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: BorderSide(color: AppColors.error, width: 2),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: BorderSide(
                      color: Theme.of(context).disabledColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingM,
                    vertical: deviceType != DeviceType.mobile ? 18 : 16,
                  ),
                  labelStyle: TextStyle(
                    fontSize: deviceType != DeviceType.mobile ? 16 : 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  hintStyle: TextStyle(
                    fontSize: deviceType != DeviceType.mobile ? 16 : 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
              if (isValid && validMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSizes.spacingS),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 16,
                      ),
                      SizedBox(width: AppSizes.spacingS),
                      Expanded(
                        child: Text(
                          validMessage!,
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Common text field styles for specific use cases
class GTRTextFieldVariants {
  /// Email input field with validation styling
  static Widget email({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool isValid = false,
    String? validMessage,
    void Function(String)? onChanged,
  }) {
    return GTRTextField(
      label: label,
      controller: controller,
      validator: validator,
      isValid: isValid,
      validMessage: validMessage,
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
    );
  }

  /// Password input field with visibility toggle
  static Widget password({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool isValid = false,
    String? validMessage,
    bool obscureText = true,
    void Function()? onVisibilityToggle,
    void Function(String)? onChanged,
  }) {
    return Builder(
      builder: (context) {
        return GTRTextField(
          label: label,
          controller: controller,
          validator: validator,
          isValid: isValid,
          validMessage: validMessage,
          icon: Icons.lock_outlined,
          obscureText: obscureText,
          onChanged: onChanged,
          suffixIcon: onVisibilityToggle != null
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
        );
      },
    );
  }

  /// Phone number input field
  static Widget phone({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool isValid = false,
    String? validMessage,
    void Function(String)? onChanged,
  }) {
    return GTRTextField(
      label: label,
      controller: controller,
      validator: validator,
      isValid: isValid,
      validMessage: validMessage,
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      onChanged: onChanged,
    );
  }

  /// Search input field
  static Widget search({
    required String label,
    required TextEditingController controller,
    void Function(String)? onChanged,
    void Function()? onClear,
  }) {
    return GTRTextField(
      label: label,
      controller: controller,
      icon: Icons.search_outlined,
      onChanged: onChanged,
      suffixIcon: onClear != null
          ? Builder(
              builder: (context) => IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: onClear,
              ),
            )
          : null,
    );
  }
}
