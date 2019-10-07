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
