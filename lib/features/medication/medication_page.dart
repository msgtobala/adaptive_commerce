import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/core/widgets/shell_prompt_bar.dart';
import 'package:flutter/material.dart';

/// Medication / symptoms flow (GenUI) — placeholder.
class MedicationPage extends StatelessWidget {
  const MedicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellPageScaffold(
      body: Center(
        child: Text(
          AppStrings.navMedication,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
