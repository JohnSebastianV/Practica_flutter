import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/post.dart';
import '../../providers/post_provider.dart';

class PostFormScreen extends StatefulWidget {
  const PostFormScreen({Key? key}) : super(key: key);

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _bodyCtrl = TextEditingController();
  bool _isEdit = false;
  Post? _editingPost;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_editingPost == null) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args != null && args is Post) {
        _editingPost = args;
        _isEdit = true;
        _titleCtrl.text = _editingPost!.title;
        _bodyCtrl.text = _editingPost!.body;
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<PostProvider>();
    if (!_formKey.currentState!.validate()) return;
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    try {
      if (_isEdit && _editingPost != null) {
        final updated = _editingPost!.copyWith(title: title, body: body);
        await provider.editPost(post: updated);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post actualizado')));
        Navigator.pop(context);
      } else {
        await provider.addPost(title: title, body: body, userId: 1);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post creado')));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit ? 'Editar Post' : 'Crear Post';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El título es obligatorio';
                  }
                  if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contenido',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 6,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El contenido es obligatorio';
                  }
                  if (v.trim().length < 5) return 'Mínimo 5 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Consumer<PostProvider>(
                builder: (context, provider, _) {
                  final loading = provider.status == Status.loading;
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: loading ? null : _save,
                      icon: loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: Text(_isEdit ? 'Actualizar' : 'Crear'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

