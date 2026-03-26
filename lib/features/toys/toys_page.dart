import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/core/widgets/shell_prompt_bar.dart';
import 'package:flutter/material.dart';

/// Toys flow — placeholder (GenUI can be added later).
class ToysPage extends StatelessWidget {
  const ToysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellPageScaffold(
      body: Center(
        child: Text(
          AppStrings.navToys,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
