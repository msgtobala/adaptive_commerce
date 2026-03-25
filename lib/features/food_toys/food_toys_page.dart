import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/core/widgets/shell_prompt_bar.dart';
import 'package:flutter/material.dart';

/// Food & toys flow (GenUI) — placeholder.
class FoodToysPage extends StatelessWidget {
  const FoodToysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellPageScaffold(
      body: Center(
        child: Text(
          AppStrings.navFoodToys,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
