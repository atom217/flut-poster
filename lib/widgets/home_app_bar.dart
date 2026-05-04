import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/providers.dart';
import '../utils/app_strings.dart';
import '../utils/dialogs.dart';

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUserPremium = ref.watch(isUserPremiumProvider);

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: const Text(
        AppStrings.appBarTitle,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: isUserPremium
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.workspace_premium, size: 14, color: Colors.amber),
                        const SizedBox(width: 6),
                        Text(
                          AppStrings.drawerPremiumActive,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () => showUpgradeDialog(context, ref),
                  child: const Text(
                    AppStrings.getPremium,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
