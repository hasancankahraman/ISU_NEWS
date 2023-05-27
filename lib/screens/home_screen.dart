// ignore_for_file: prefer_const_constructors, unnecessary_null_comparison, use_build_context_synchronously, avoid_print, non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import 'localizations/localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> news = [];
  bool loading = false;
  int current_page = 1;
  late ScrollController controller;
  List<int> favoriteIndexes = [];

  void toggleFavorite(int index) {
    setState(() {
      if (favoriteIndexes.contains(index)) {
        favoriteIndexes.remove(index);
      } else {
        favoriteIndexes.add(index);
      }
    });
  }

  comingNews({int page = 1}) async {
    setState(() {
      loading = true;
    });

    Dio dio = Dio();
    var response =
        await dio.get('https://www.nginx.com/wp-json/wp/v2/posts?page=$page');
    if (response.statusCode == 200) {
      print(response.data);
      if (page == 1) {
        news = response.data;
      } else {
        news.addAll(response.data);
      }
      current_page = page;
      loading = false;
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Habeler Yüklenirken Hata Oluştu . Lütfen Daha Sonra Tekrar Deneyiniz!'),
      ));
      setState(() {
        loading = false;
      });
    }
  }

  Widget getNews() {
    if (news != null) {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: news.length,
        itemBuilder: (context, index) {
          var haberler = news[index];
          bool isFavorite = favoriteIndexes.contains(index);
          return GestureDetector(
            onTap: () {},
            child: Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: haberler["yoast_head_json"]["twitter_image"] !=
                                null
                            ? Image.network(
                                haberler["yoast_head_json"]["twitter_image"],
                                fit: BoxFit.cover)
                            : Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/%C4%B0stinye_%C3%9Cniversitesi_logo.svg/2560px-%C4%B0stinye_%C3%9Cniversitesi_logo.svg.png',
                              ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      haberler["yoast_head_json"]["title"],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      haberler["yoast_head_json"]["description"],
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Iconsax.calendar,
                                size: 16, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              haberler["date"],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? Colors.red
                                : null, // Favori olduğunda rengi değiştir
                          ),
                          onPressed: () {
                            toggleFavorite(
                                index); // Favori düğmesine basıldığında toggleFavorite metodu çağrılıyor
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      return Text('Haberler Geliyor');
    }
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      comingNews(page: current_page + 1);
    }
    if (controller.offset <= controller.position.minScrollExtent &&
        !controller.position.outOfRange) {}
  }

  @override
  void initState() {
    super.initState();
    comingNews();
    controller = ScrollController();
    controller.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İSU NEWS'),
        actions: [
          IconButton(
            icon: Icon(Iconsax.filter),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      AppLocalizations.of(context).getTranslate('information'),
                    ),
                    content: Text(
                      AppLocalizations.of(context).getTranslate('filtering'),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          AppLocalizations.of(context).getTranslate('ok'),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Iconsax.setting_2),
            onPressed: () => GoRouter.of(context).go('/settings'),
          ),
          IconButton(
            icon: Icon(Iconsax.user),
            onPressed: () => GoRouter.of(context).go('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: controller,
        child: Column(
          children: [
            getNews(),
            loading ? CircularProgressIndicator() : SizedBox(),
          ],
        ),
      ),
    );
  }
}
