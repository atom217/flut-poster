import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/providers.dart';
import 'editor_screen.dart';

class QuoteListScreen extends ConsumerWidget {
  final Category category;

  const QuoteListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotes = ref.watch(quotesByCategoryProvider(category.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: ListView.builder(
        itemCount: quotes.length,
        itemBuilder: (context, index) {
          final quote = quotes[index];
          return Card(
            child: ListTile(
              title: Text(
                quote.text,
                style: const TextStyle(fontSize: 16),
              ),
              subtitle: Text('- ${quote.author}'),
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
