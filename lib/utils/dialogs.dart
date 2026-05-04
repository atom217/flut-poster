import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/providers.dart';
import 'app_strings.dart';

void showUpgradeDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.stars, color: Colors.amber, semanticLabel: 'Premium Star'),
          SizedBox(width: 10),
          Text(AppStrings.goPremium),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.unlockExclusiveFeatures),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 18),
              SizedBox(width: 8),
              Text(AppStrings.premiumFeatureTemplates),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 18),
              SizedBox(width: 8),
              Text(AppStrings.premiumFeatureNoAds),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 18),
              SizedBox(width: 8),
              Text(AppStrings.premiumFeatureHighRes),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.maybeLater),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
            ref.read(isUserPremiumProvider.notifier).state = true;
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.upgradeSuccessDemo)),
              );
            }
          },
          child: const Text(AppStrings.upgradeNow),
        ),
      ],
    ),
  );
}
