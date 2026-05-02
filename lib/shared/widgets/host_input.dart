import 'package:flutter/material.dart';

import '../../core/i18n/app_strings.dart';

class HostInput extends StatelessWidget {
  const HostInput({
    required this.controller,
    this.label,
    super.key,
  });

  final TextEditingController controller;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return TextField(
      controller: controller,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: label ?? strings.enterHost,
        suffixIcon: IconButton(
          tooltip: strings.clear,
          icon: const Icon(Icons.cancel_rounded),
          onPressed: controller.clear,
        ),
      ),
    );
  }
}
