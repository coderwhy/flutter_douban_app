# 高仿豆瓣页面

> **更新地点：** 首发于公众号，第二天更新于掘金、思否、开发者头条等地方；
>
> **更多交流：** 可以添加我的微信 372623326，关注我的微博：coderwhy

> 时间问题，没有非常详细说明每个步骤，后续希望可以更新一个视频为大家讲解。

![image-20191002160439302](https://tva1.sinaimg.cn/large/006y8mN6gy1g7jx2csputj31h80u01kx.jpg)

## 一. 数据请求和转化

### 1.1. 网络请求简单封装

目前我还没有详细讲解网络请求相关的知识，开发中我们更多选择地方的dio。

后面我会详细讲解网络请求的几种方式，我这里基于dio进行了一个简单工具的封装：

配置文件存放：http_config.dart

```dart
const baseURL = "http://123.207.32.32:8000";
const timeout = 5000;
```

网络请求工具文件：http_request.dart

- 目前只是封装了一个方法，更多细节后续再补充

```dart
import 'package:dio/dio.dart';
import 'http_config.dart';

class HttpRequest {
  // 1.创建实例对象
  static BaseOptions baseOptions = BaseOptions(connectTimeout: timeout);
  static Dio dio = Dio(baseOptions);

  static Future<T> request<T>(String url, {String method = "get",Map<String, dynamic> params}) async {
    // 1.单独相关的设置
    Options options = Options();
    options.method = method;

    // 2.发送网络请求
    try {
      Response response = await dio.request<T>(url, queryParameters: params, options: options);
      return response.data;
    } on DioError catch (e) {
      throw e;
    }
  }
}
```



### 1.2. 首页数据请求转化

**豆瓣数据的获取**

这里我使用豆瓣的API接口来请求数据：

- https://douban.uieee.com/v2/movie/top250?start=0&count=20

![image-20191002155619948](https://tva1.sinaimg.cn/large/006y8mN6gy1g7jwtr0lm0j31650u0dml.jpg)

**模型对象的封装**

在面向对象的开发中，数据请求下来并不会像前端那样直接使用，而是封装成模型对象：

- 前端开发者很容易没有面向对象的思维或者类型的思维。
- 但是目前前端开发正在向TypeScript发展，也在帮助我们强化这种思维方式。

为了方便之后使用请求下来的数据，我将数据划分成了如下的模型：

Person、Actor、Director模型：它们会被使用到MovieItem中

```dart
class Person {
  String name;
  String avatarURL;

  Person.fromMap(Map<String, dynamic> json) {
    this.name = json["name"];
    this.avatarURL = json["avatars"]["medium"];
  }
}

class Actor extends Person {
  Actor.fromMap(Map<String, dynamic> json): super.fromMap(json);
}

class Director extends Person {
  Director.fromMap(Map<String, dynamic> json): super.fromMap(json);
}
```

MovieItem模型：

```dart
int counter = 1;

class MovieItem {
  int rank;
  String imageURL;
  String title;
  String playDate;
  double rating;
  List<String> genres;
  List<Actor> casts;
  Director director;
  String originalTitle;

  MovieItem.fromMap(Map<String, dynamic> json) {
    this.rank = counter++;
    this.imageURL = json["images"]["medium"];
    this.title = json["title"];
    this.playDate = json["year"];
    this.rating = json["rating"]["average"];
    this.genres = json["genres"].cast<String>();
    this.casts = (json["casts"] as List<dynamic>).map((item) {
      return Actor.fromMap(item);
    }).toList();
    this.director = Director.fromMap(json["directors"][0]);
    this.originalTitle = json["original_title"];
  }
}
```

**首页数据请求封装以及模型转化**

这里我封装了一个专门的类，用于请求首页的数据，这样让我们的请求代码更加规范的管理：HomeRequest

- 目前类中只有一个方法getMovieTopList；
- 后续有其他首页数据需要请求，就继续在这里封装请求的方法；

```dart
import 'package:douban_app/models/home_model.dart';
import 'http_request.dart';

class HomeRequest {
  Future<List<MovieItem>> getMovieTopList(int start, int count) async {
    // 1.拼接URL
    final url = "https://douban.uieee.com/v2/movie/top250?start=$start&count=$count";

    // 2.发送请求
    final result = await HttpRequest.request(url);

    // 3.转成模型对象
    final subjects = result["subjects"];
    List<MovieItem> movies = [];
    for (var sub in subjects) {
      movies.add(MovieItem.fromMap(sub));
    }

    return movies;
  }
}
```

**在home.dart文件中请求数据**

![image-20191002160439302](https://tva1.sinaimg.cn/large/006y8mN6gy1g7jx2csputj31h80u01kx.jpg)



## 二. 界面效果实现

### 2.1. 首页整体代码

首页整体布局非常简单，使用一个ListView即可

```dart
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
```



### 2.2. 单独Item局部

下面是针对界面结构的分析：

![image-20191002163853864](https://tva1.sinaimg.cn/large/006y8mN6gy1g7jy1zd5z8j31cz0u0qv6.jpg)

大家按照对应的结构，实现代码即可：

```dart
import 'package:douban_app/components/dash_line.dart';
import 'package:flutter/material.dart';

import 'package:douban_app/models/home_model.dart';
import 'package:douban_app/components/star_rating.dart';

class MovieListItem extends StatelessWidget {
  final MovieItem movie;

  MovieListItem(this.movie);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 10, color: Color(0xffe2e2e2)))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1.电影排名
          getMovieRankWidget(),
          SizedBox(height: 12),
          // 2.具体内容
          getMovieContentWidget(),
          SizedBox(height: 12),
          // 3.电影简介
          getMovieIntroduceWidget(),
          SizedBox(height: 12,)
        ],
      ),
    );
  }

  // 电影排名
  Widget getMovieRankWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(9, 4, 9, 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: Color.fromARGB(255, 238, 205, 144)
      ),
      child: Text(
        "No.${movie.rank}",
        style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 131, 95, 36)),
      )
    );
  }

  // 具体内容
  Widget getMovieContentWidget() {
    return Container(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          getContentImage(),
          getContentDesc(),
          getDashLine(),
          getContentWish()
        ],
      ),
    );
  }

  Widget getContentImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Image.network(movie.imageURL)
    );
  }

  Widget getContentDesc() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            getTitleWidget(),
            SizedBox(height: 3,),
            getRatingWidget(),
            SizedBox(height: 3,),
            getInfoWidget()
          ],
        ),
      ),
    );
  }

  Widget getDashLine() {
    return Container(
      width: 1,
      height: 100,
      child: DashedLine(
        axis: Axis.vertical,
        dashedHeight: 6,
        dashedWidth: .5,
        count: 12,
      ),
    );
  }

  Widget getTitleWidget() {
    return Stack(
      children: <Widget>[
        Icon(Icons.play_circle_outline, color: Colors.redAccent,),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "     " + movie.title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                )
              ),
              TextSpan(
                text: "(${movie.playDate})",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54
                ),
              )
            ]
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget getRatingWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        StarRating(rating: movie.rating, size: 18,),
        SizedBox(width: 5),
        Text("${movie.rating}")
      ],
    );
  }

  Widget getInfoWidget() {
    // 1.获取种类字符串
    final genres = movie.genres.join(" ");
    final director = movie.director.name;
    var castString = "";
    for (final cast in movie.casts) {
      castString += cast.name + " ";
    }

    // 2.创建Widget
    return Text(
      "$genres / $director / $castString",
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 16),
    );
  }

  Widget getContentWish() {
    return Container(
      width: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20,),
          Image.asset("assets/images/home/wish.png", width: 30,),
          SizedBox(height: 5,),
          Text(
            "想看",
            style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 235, 170, 60)),
          )
        ],
      ),
    );
  }

  // 电影简介（原生名称）
  Widget getMovieIntroduceWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xfff2f2f2),
        borderRadius: BorderRadius.circular(5)
      ),
      child: Text(movie.originalTitle, style: TextStyle(fontSize: 18, color: Colors.black54),),
    );
  }
}
```



> 备注：所有内容首发于公众号，之后除了Flutter也会更新其他技术文章，TypeScript、React、Node、uniapp、mpvue、数据结构与算法等等，也会更新一些自己的学习心得等，欢迎大家关注

![公众号](https://tva1.sinaimg.cn/large/006y8mN6gy1g6gqxq4tvbj30rx0wcgqt.jpg)