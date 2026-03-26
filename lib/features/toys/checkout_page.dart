import 'package:adaptive_commerce/core/resources/app_strings.dart';
import 'package:adaptive_commerce/theme/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Mock checkout: confirms placement only (no payment).
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({
    super.key,
    required this.productName,
    required this.price,
    required this.seller,
    required this.productUrl,
  });

  final String productName;
  final String price;
  final String seller;
  final String productUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.checkoutTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 64,
                color: Colors.green.shade700,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.checkoutOrderPlaced,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.headline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              if (productName.isNotEmpty)
                Text(
                  productName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.deepBrown,
                  ),
                ),
              if (price.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(price, style: theme.textTheme.bodyLarge),
              ],
              if (seller.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  seller,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
              ],
              if (productUrl.isNotEmpty) ...[
                const SizedBox(height: 12),
                SelectableText(
                  productUrl,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text(AppStrings.checkoutBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
