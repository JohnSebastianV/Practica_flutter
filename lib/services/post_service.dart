import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/post.dart';

class PostService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Post>> fetchPosts({int start = 0, int limit = 10}) async {
    try {
      final url = Uri.parse('$baseUrl/posts?_start=$start&_limit=$limit');
      final res = await http.get(url, headers: {
        'Accept': 'application/json',
      });

      if (res.statusCode == 200) {
        final List parsed = jsonDecode(res.body);
        return parsed.map((e) => Post.fromJson(e)).toList();
      } else if (res.statusCode == 403) {
        // fallback: traer todo si el server no permite paginación
        final fallbackUrl = Uri.parse('$baseUrl/posts');
        final fallbackRes = await http.get(fallbackUrl, headers: {
          'Accept': 'application/json',
        });
        if (fallbackRes.statusCode == 200) {
          final List parsed = jsonDecode(fallbackRes.body);
          return parsed.map((e) => Post.fromJson(e)).toList();
        }
        throw Exception('Error fetching posts (fallback): ${fallbackRes.statusCode}');
      } else {
        throw Exception('Error fetching posts: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception in fetchPosts: $e');
    }
  }

  Future<Post> fetchPost(int id) async {
    final url = Uri.parse('$baseUrl/posts/$id');
    final res = await http.get(url, headers: {
      'Accept': 'application/json',
    });
    if (res.statusCode == 200) {
      return Post.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Error fetching post $id: ${res.statusCode}');
    }
  }

  Future<Post> createPost(Post post) async {
    final url = Uri.parse('$baseUrl/posts');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        "title": post.title,
        "body": post.body,
        "userId": post.userId,
      }),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return Post.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Error creating post: ${res.statusCode}');
    }
  }

  Future<Post> updatePost(Post post) async {
    final url = Uri.parse('$baseUrl/posts/${post.id}');
    final res = await http.put(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        "id": post.id,
        "title": post.title,
        "body": post.body,
        "userId": post.userId,
      }),
    );
    if (res.statusCode == 200) {
      return Post.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Error updating post ${post.id}: ${res.statusCode}');
    }
  }

  Future<void> deletePost(int id) async {
    final url = Uri.parse('$baseUrl/posts/$id');
    final res = await http.delete(url, headers: {
      'Accept': 'application/json',
    });
    if (res.statusCode != 200) {
      throw Exception('Error deleting post $id: ${res.statusCode}');
    }
  }
}

