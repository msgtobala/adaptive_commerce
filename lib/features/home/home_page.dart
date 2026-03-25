import 'package:adaptive_commerce/core/icons/app_icons.dart';
import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:flutter/material.dart';

/// Landing / home screen (placeholder until navigation grows).
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() => _counter++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.pets_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const Text(AppStrings.homeCounterHint),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: AppStrings.homeFabIncrementTooltip,
        child: const Icon(Symbols.add_rounded),
      ),
    );
  }
}
