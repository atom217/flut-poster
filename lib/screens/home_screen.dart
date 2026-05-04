import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import '../services/providers.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/category_tabs.dart';
import '../widgets/poster_preview.dart';
import '../widgets/bottom_action_row.dart';
import '../widgets/profile_editor.dart';
import '../widgets/app_drawer.dart';
import '../utils/constants.dart';
import '../utils/app_strings.dart';
import '../utils/dialogs.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedCategoryIdProvider);
    final quotes = ref.watch(quotesByCategoryProvider(selectedId));
    final filteredTemplates = ref.watch(templatesByCategoryProvider(selectedId));
    final currentTemplate = ref.watch(selectedTemplateProvider);
    final isUserPremium = ref.watch(isUserPremiumProvider);

    // Listen to category changes to reset template if necessary
    ref.listen<String>(selectedCategoryIdProvider, (previous, next) {
      final templates = ref.read(templatesByCategoryProvider(next));
      if (templates.isNotEmpty) {
        // Try to find a free template first
        final freeTemplates = templates.where((t) => !t.isPremium).toList();
        if (freeTemplates.isNotEmpty) {
          ref.read(selectedTemplateProvider.notifier).state = freeTemplates[0];
        } else {
          // Fallback to the first template if all are premium (it will be locked)
          ref.read(selectedTemplateProvider.notifier).state = templates[0];
        }
      }
    });

    return Scaffold(
      appBar: const HomeAppBar(),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const CategoryTabs(),
              const SizedBox(height: 24),
              
              // Poster Preview Area
              Screenshot(
                controller: ref.watch(screenshotControllerProvider),
                child: SizedBox(
                  height: AppConstants.previewHeight,
                  child: quotes.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.format_quote, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(AppStrings.noQuotesInCategory, style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: PageView.builder(
                            key: ValueKey(selectedId),
                            itemCount: quotes.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Center(
                                  child: PosterPreview(quote: quotes[index]),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.selectDesign,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      AppStrings.seeAll,
                      style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              SizedBox(
                height: AppConstants.templateSelectorHeight,
                child: filteredTemplates.isEmpty
                    ? const Center(child: Text(AppStrings.noTemplatesForCategory, style: TextStyle(fontSize: 12, color: Colors.grey)))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredTemplates.length,
                        itemBuilder: (context, index) {
                          final template = filteredTemplates[index];
                          final isSelected = currentTemplate.id == template.id;
                          return GestureDetector(
                            onTap: () {
                              if (template.isPremium && !isUserPremium) {
                                showUpgradeDialog(context, ref);
                              } else {
                                ref.read(selectedTemplateProvider.notifier).state = template;
                              }
                            },
                            child: Stack(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: 70,
                                  margin: const EdgeInsets.only(right: 14, bottom: 10, top: 4),
                                  decoration: BoxDecoration(
                                    color: template.backgroundColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: isSelected
                                        ? Border.all(color: Colors.amber, width: 3)
                                        : Border.all(color: Colors.grey.shade200, width: 1),
                                    gradient: template.gradientColors != null
                                        ? LinearGradient(colors: template.gradientColors!)
                                        : null,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.amber.withValues(alpha: 0.4),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 4),
                                            )
                                          ]
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.05),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isSelected ? Icons.check_circle : Icons.palette_outlined,
                                      color: template.textColor.withValues(alpha: isSelected ? 1.0 : 0.4),
                                      size: 24,
                                      semanticLabel: isSelected ? 'Selected Template' : 'Design Template',
                                    ),
                                  ),
                                ),
                                if (template.isPremium)
                                  Positioned(
                                    top: 8,
                                    right: 18,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.amber,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.lock,
                                        size: 10,
                                        color: Colors.black,
                                        semanticLabel: 'Premium Locked',
                                      ),
                                    ),
                                  )
                                else
                                  Positioned(
                                    top: 8,
                                    right: 18,
                                    child: Icon(
                                      Icons.favorite_border,
                                      size: 14,
                                      color: template.textColor.withValues(alpha: 0.6),
                                      semanticLabel: 'Favorite Design',
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              
              const SizedBox(height: 12),
              const ProfileEditor(),
              const SizedBox(height: 12),
              const BottomActionRow(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
