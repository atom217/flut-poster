import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/providers.dart';
import '../utils/app_strings.dart';
import '../utils/dialogs.dart';
import '../utils/photo_utils.dart';
import '../screens/quote_list_screen.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final isUserPremium = ref.watch(isUserPremiumProvider);
    final categories = ref.watch(categoriesProvider);

    final hasValidPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;

    return Drawer(
      child: Column(
        children: [
          // Drawer Header with Profile
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: GestureDetector(
              onTap: () => pickAndSetProfilePhoto(ref, context),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.amber.shade100,
                        child: hasValidPhoto
                            ? null
                            : const Icon(Icons.person, size: 32, color: Colors.amber),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: const Icon(Icons.camera_alt, size: 12, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          user.subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text(AppStrings.drawerNavHome),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: const Text(AppStrings.drawerNavQuotesLibrary),
                  onTap: () {
                    Navigator.pop(context);
                    final allCategory = categories.firstWhere(
                      (c) => c.id == 'all',
                      orElse: () => categories.first,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuoteListScreen(category: allCategory),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text(AppStrings.drawerNavAbout),
                  onTap: () {
                    Navigator.pop(context);
                    showAboutDialog(
                      context: context,
                      applicationName: AppStrings.appTitle,
                      applicationVersion: '1.0.0',
                      children: [
                        const Text(AppStrings.aboutDescription),
                      ],
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text(AppStrings.drawerNavSettings),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(AppStrings.drawerSettingsComingSoon)),
                    );
                  },
                ),
              ],
            ),
          ),

          // Premium Section
          if (!isUserPremium)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    showUpgradeDialog(context, ref);
                  },
                  icon: const Icon(Icons.workspace_premium),
                  label: const Text(
                    AppStrings.drawerUpgradeSection,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.workspace_premium, color: Colors.amber),
                title: const Text(
                  AppStrings.drawerPremiumActive,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
