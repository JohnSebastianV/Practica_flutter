import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/post.dart';
import '../../providers/post_provider.dart';
import '../../constants/routes.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Post postArg = ModalRoute.of(context)!.settings.arguments as Post;

    return Consumer<PostProvider>(
      builder: (context, provider, _) {
        final currentPost = provider.posts.firstWhere(
          (p) => p.id == postArg.id,
          orElse: () => postArg,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalle del Post'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pushNamed(context, Routes.form,
                      arguments: currentPost);
                },
                tooltip: 'Editar',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Eliminar post'),
                      content: const Text(
                          '¿Seguro que quieres eliminar este post?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    try {
                      await provider.removePost(currentPost.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post eliminado')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                tooltip: 'Eliminar',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentPost.title,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    Text(currentPost.body,
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 18),
                        const SizedBox(width: 6),
                        Text('User ID: ${currentPost.userId}'),
                        const SizedBox(width: 16),
                        const Icon(Icons.tag, size: 18),
                        const SizedBox(width: 6),
                        Text('Post ID: ${currentPost.id}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


