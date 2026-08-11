import 'package:flutter/material.dart';

import '../../../app/theme/fishtrace_colors.dart';
import '../../../app/theme/fishtrace_dimensions.dart';

class FishTraceTextField extends StatelessWidget {
  const FishTraceTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.required = false,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool required;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _FieldLabel(label: label, required: required),
      const SizedBox(height: FishTraceSpacing.xs),
      TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        readOnly: readOnly,
        maxLines: obscureText ? 1 : maxLines,
        onChanged: onChanged,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 19),
          suffixIcon: suffixIcon,
        ),
      ),
    ],
  );
}

class FishTraceDropdown<T> extends StatelessWidget {
  const FishTraceDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.required = false,
    this.validator,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?>? onChanged;
  final bool required;
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _FieldLabel(label: label, required: required),
      const SizedBox(height: FishTraceSpacing.xs),
      DropdownButtonFormField<T>(
        value: value,
        validator: validator,
        isExpanded: true,
        decoration: const InputDecoration(),
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    ],
  );
}

class FishTraceSearchField extends StatelessWidget {
  const FishTraceSearchField({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.onFilter,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilter;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: SizedBox(
          height: FishTraceSizes.touchTarget,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(Icons.search, size: 19),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
      if (onFilter != null) ...[
        const SizedBox(width: FishTraceSpacing.xs),
        SizedBox.square(
          dimension: FishTraceSizes.touchTarget,
          child: OutlinedButton(
            onPressed: onFilter,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              side: const BorderSide(color: FishTraceColors.border),
            ),
            child: const Icon(Icons.tune, size: 19),
          ),
        ),
      ],
    ],
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.required});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      text: label,
      children: [
        if (required)
          const TextSpan(
            text: ' *',
            style: TextStyle(color: FishTraceColors.error),
          ),
      ],
    ),
    style: Theme.of(context).textTheme.labelMedium,
  );
}
