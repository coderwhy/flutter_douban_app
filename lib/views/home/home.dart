import 'package:douban_app/models/home_model.dart';
import 'package:douban_app/network/home_request.dart';
import 'package:douban_app/views/home/childCpns/movie_list_item.dart';
import 'package:flutter/material.dart';

const COUNT = 20;

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("首页"),
      ),
      body: Center(
        child: HomeContent(),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // 初始化首页的网络请求对象
  HomeRequest homeRequest = HomeRequest();

  int _start = 0;
  List<MovieItem> movies = [];

  @override
  void initState() {
    super.initState();

    // 请求电影列表数据
    getMovieTopList(_start, COUNT);
  }

  void getMovieTopList(start, count) {
    homeRequest.getMovieTopList(start, count).then((result) {
      setState(() {
        movies.addAll(result);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: movies.length,
      itemBuilder: (BuildContext context, int index) {
        return MovieListItem(movies[index]);
      }
    );
  }
}

