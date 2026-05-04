import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/providers.dart';
import '../utils/app_strings.dart';
import 'editor_screen.dart';

const int _quotesPageSize = 10;

class QuoteListScreen extends ConsumerStatefulWidget {
  final Category category;

  const QuoteListScreen({super.key, required this.category});

  @override
  ConsumerState<QuoteListScreen> createState() => _QuoteListScreenState();
}

class _QuoteListScreenState extends ConsumerState<QuoteListScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    // Reset page count when entering screen
    Future.microtask(() {
      ref.read(quotesPageCountProvider.notifier).state = _quotesPageSize;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final isLoading = ref.read(isLoadingMoreQuotesProvider);
    if (isLoading) return;

    ref.read(isLoadingMoreQuotesProvider.notifier).state = true;

    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 800));

    final currentCount = ref.read(quotesPageCountProvider);
    ref.read(quotesPageCountProvider.notifier).state = currentCount + _quotesPageSize;

    ref.read(isLoadingMoreQuotesProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final quotes = ref.watch(paginatedQuotesProvider(widget.category.id));
    final isLoading = ref.watch(isLoadingMoreQuotesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: quotes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.format_quote, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.noQuotesInCategory,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: quotes.length + 1,
              itemBuilder: (context, index) {
                // Last item is the loading indicator
                if (index == quotes.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const SizedBox.shrink(),
                    ),
                  );
                }

                final quote = quotes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(
                      quote.text,
                      style: const TextStyle(fontSize: 16),
                    ),
                    subtitle: Text('${AppStrings.quoteAuthorPrefix}${quote.author}'),
                    trailing: const Icon(Icons.edit),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditorScreen(quote: quote),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
