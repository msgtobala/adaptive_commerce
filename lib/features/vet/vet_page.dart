import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/core/widgets/shell_prompt_bar.dart';
import 'package:flutter/material.dart';

/// Veterinary finder flow (GenUI) — placeholder.
class VetPage extends StatelessWidget {
  const VetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellPageScaffold(
      body: Center(
        child: Text(
          AppStrings.navVeterinary,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
