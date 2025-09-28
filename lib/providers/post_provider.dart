import 'package:flutter/material.dart';
import '../data/models/post.dart';
import '../services/post_service.dart';

enum Status { initial, loading, success, error }

class PostProvider extends ChangeNotifier {
  final PostService _service = PostService();

  List<Post> posts = [];
  Status status = Status.initial;
  String? errorMessage;

  int _start = 0;
  final int _limit = 10;
  bool hasMore = true;
  bool isLoadingMore = false;

  int? filterUserId;
  String? filterTitleLength;

  Future<void> loadInitial() async {
    _start = 0;
    hasMore = true;
    posts = [];
    status = Status.loading;
    notifyListeners();

    try {
      final List<Post> initialPosts = await _service.fetchPosts(
        start: 0,
        limit: 50,
      );

      posts = initialPosts;
      _start = posts.length;
      hasMore = initialPosts.length >= 50;
      status = Status.success;
      errorMessage = null;
    } catch (e) {
      status = Status.error;
      errorMessage = "Error en loadInitial: $e";
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!hasMore) return;
    if (isLoadingMore) return;

    try {
      if (_start == 0) {
        status = Status.loading;
        notifyListeners();
      } else {
        isLoadingMore = true;
        notifyListeners();
      }

      final List<Post> newPosts = await _service.fetchPosts(
        start: _start,
        limit: _limit,
      );

      if (newPosts.isEmpty) {
        hasMore = false;
      } else {
        posts.addAll(newPosts);
        _start += newPosts.length;
      }

      status = Status.success;
      errorMessage = null;
    } catch (e) {
      status = Status.error;
      errorMessage = "Error en loadMore: $e";
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> addPost({
    required String title,
    required String body,
    int userId = 1,
  }) async {
    try {
      status = Status.loading;
      notifyListeners();
      final Post toCreate = Post(
        id: 0,
        userId: userId,
        title: title,
        body: body,
      );
      final Post created = await _service.createPost(toCreate);
      posts.insert(0, created);
      status = Status.success;
      notifyListeners();
    } catch (e) {
      status = Status.error;
      errorMessage = "Error creando post: $e";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> editPost({required Post post}) async {
    try {
      status = Status.loading;
      notifyListeners();

      try {
        final Post updated = await _service.updatePost(post);

        final idx = posts.indexWhere((p) => p.id == updated.id);
        if (idx != -1) {
          posts[idx] = updated;
        }
      } catch (apiError) {
        final idx = posts.indexWhere((p) => p.id == post.id);
        if (idx != -1) {
          posts[idx] = posts[idx].copyWith(title: post.title, body: post.body);
        }
      }

      status = Status.success;
      notifyListeners();
    } catch (e) {
      status = Status.error;
      errorMessage = "Error editando post: $e";
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removePost(int id) async {
    try {
      status = Status.loading;
      notifyListeners();
      await _service.deletePost(id);
      posts.removeWhere((p) => p.id == id);
      status = Status.success;
      notifyListeners();
    } catch (e) {
      status = Status.error;
      errorMessage = "Error eliminando post: $e";
      notifyListeners();
      rethrow;
    }
  }

  List<Post> get filteredPosts {
    var list = posts;

    if (filterUserId != null) {
      list = list.where((p) => p.userId == filterUserId).toList();
    }

    if (filterTitleLength != null) {
      switch (filterTitleLength) {
        case 'Corto':
          list = list.where((p) => p.title.length < 30).toList();
          break;
        case 'Medio':
          list = list
              .where((p) => p.title.length >= 30 && p.title.length < 60)
              .toList();
          break;
        case 'Largo':
          list = list.where((p) => p.title.length >= 60).toList();
          break;
      }
    }

    return list;
  }

  void setFilterUserId(int? userId) {
    filterUserId = userId;
    notifyListeners();
  }

  void setFilterTitleLength(String? length) {
    filterTitleLength = length;
    notifyListeners();
  }
}
