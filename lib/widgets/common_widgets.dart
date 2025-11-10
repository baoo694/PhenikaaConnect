import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color foregroundColor;
    Color? borderColor;
    
    switch (type) {
      case ButtonType.primary:
        backgroundColor = theme.colorScheme.primary;
        foregroundColor = theme.colorScheme.onPrimary;
        break;
      case ButtonType.secondary:
        backgroundColor = theme.colorScheme.secondary;
        foregroundColor = theme.colorScheme.onSecondary;
        break;
      case ButtonType.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = theme.colorScheme.primary;
        borderColor = theme.colorScheme.primary;
        break;
      case ButtonType.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = theme.colorScheme.onSurface;
        break;
      case ButtonType.error:
        backgroundColor = Colors.red;
        foregroundColor = Colors.white;
        break;
    }

    double height;
    double fontSize;
    EdgeInsets padding;
    
    switch (size) {
      case ButtonSize.small:
        height = 32;
        fontSize = 12;
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
        break;
      case ButtonSize.medium:
        height = 40;
        fontSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
        break;
      case ButtonSize.large:
        height = 48;
        fontSize = 16;
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
        break;
    }

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: borderColor != null ? BorderSide(color: borderColor) : null,
          elevation: 0,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: fontSize + 2),
                    if (text.isNotEmpty) const SizedBox(width: 8),
                  ],
                  if (text.isNotEmpty)
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

enum ButtonType { primary, secondary, outline, ghost, error }
enum ButtonSize { small, medium, large }

class CustomBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final BadgeSize size;

  const CustomBadge({
    super.key,
    required this.text,
    this.type = BadgeType.primary,
    this.size = BadgeSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;
    
    switch (type) {
      case BadgeType.primary:
        backgroundColor = theme.colorScheme.primary;
        textColor = theme.colorScheme.onPrimary;
        break;
      case BadgeType.secondary:
        backgroundColor = theme.colorScheme.secondary;
        textColor = theme.colorScheme.onSecondary;
        break;
      case BadgeType.success:
        backgroundColor = Colors.green;
        textColor = Colors.white;
        break;
      case BadgeType.warning:
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        break;
      case BadgeType.error:
        backgroundColor = Colors.red;
        textColor = Colors.white;
        break;
      case BadgeType.outline:
        backgroundColor = Colors.transparent;
        textColor = theme.colorScheme.primary;
        break;
    }

    double fontSize;
    EdgeInsets padding;
    
    switch (size) {
      case BadgeSize.small:
        fontSize = 10;
        padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
        break;
      case BadgeSize.medium:
        fontSize = 12;
        padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
        break;
      case BadgeSize.large:
        fontSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: type == BadgeType.outline
            ? Border.all(color: theme.colorScheme.primary)
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

enum BadgeType { primary, secondary, success, warning, error, outline }
enum BadgeSize { small, medium, large }

class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.radius = 20,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Text(
              initials ?? '?',
              style: TextStyle(
                color: textColor ?? theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.6,
              ),
            )
          : null,
    );
  }
}

class CustomInput extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool enabled;

  const CustomInput({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines ?? 1,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon),
                onPressed: onSuffixTap,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}
