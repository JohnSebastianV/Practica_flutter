import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../components/post_card.dart';
import '../../constants/routes.dart';
import '../../data/models/post.dart';

class PostsListScreen extends StatefulWidget {
  const PostsListScreen({Key? key}) : super(key: key);

  @override
  State<PostsListScreen> createState() => _PostsListScreenState();
}

class _PostsListScreenState extends State<PostsListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<PostProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.loadInitial();
    });

    _scrollController.addListener(() {
      final provider = context.read<PostProvider>();
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (provider.hasMore && !provider.isLoadingMore) {
          provider.loadMore();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goToForm({Post? post}) {
    Navigator.pushNamed(context, Routes.form, arguments: post);
  }

  void _goToDetail(Post post) {
    Navigator.pushNamed(context, Routes.detail, arguments: post);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Posts'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: provider.filterUserId,
                        decoration: const InputDecoration(
                          labelText: "Usuario",
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text("Todos"),
                          ),
                          ...List.generate(
                            10,
                            (i) => DropdownMenuItem(
                              value: i + 1,
                              child: Text("User ${i + 1}"),
                            ),
                          ),
                        ],
                        onChanged: (value) => provider.setFilterUserId(value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        value: provider.filterTitleLength,
                        decoration: const InputDecoration(
                          labelText: "Título",
                          prefixIcon: Icon(Icons.title),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text("Todos")),
                          DropdownMenuItem(
                            value: "Corto",
                            child: Text("Corto"),
                          ),
                          DropdownMenuItem(
                            value: "Medio",
                            child: Text("Medio"),
                          ),
                          DropdownMenuItem(
                            value: "Largo",
                            child: Text("Largo"),
                          ),
                        ],
                        onChanged: (value) =>
                            provider.setFilterTitleLength(value),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (provider.status == Status.loading &&
                        provider.posts.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (provider.status == Status.error &&
                        provider.posts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Error: ${provider.errorMessage ?? 'Desconocido'}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => provider.loadInitial(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }

                    final displayed = provider.filteredPosts;

                    if (displayed.isEmpty) {
                      return const Center(
                        child: Text(
                          'No se encontraron posts',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await provider.loadInitial();
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            displayed.length + (provider.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == displayed.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final post = displayed[index];
                          return PostCard(
                            post: post,
                            onTap: () => _goToDetail(post),
                            onDelete: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Confirmar eliminación'),
                                  content: const Text(
                                      '¿Seguro que quieres eliminar este post?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                try {
                                  await provider.removePost(post.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Post eliminado'),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _goToForm(),
            icon: const Icon(Icons.add),
            label: const Text("Nuevo"),
          ),
        );
      },
    );
  }
}
