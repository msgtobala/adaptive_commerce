import 'package:adaptive_commerce/core/widgets/app_brand_header.dart';
import 'package:adaptive_commerce/core/widgets/floating_pill_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App tab layout: [AppBrandHeader] + [FloatingPillTabBar] + tab content.
class MainLayout extends StatelessWidget {
  const MainLayout({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppBrandHeader(showPetProfileAction: true),
                FloatingPillTabBar(
                  currentIndex: navigationShell.currentIndex,
                  onItemSelected: (index) => navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
