import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/post_provider.dart';
import 'presentation/screens/posts_list_screen.dart';
import 'presentation/screens/post_detail_screen.dart';
import 'presentation/screens/post_form_screen.dart';
import 'constants/routes.dart';
import 'themes/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Posts App',
        theme: appTheme,
        initialRoute: Routes.home,
        routes: {
          Routes.home: (_) => const PostsListScreen(),
          Routes.detail: (_) => const PostDetailScreen(),
          Routes.form: (_) => const PostFormScreen(),
        },
      ),
    );
  }
}
