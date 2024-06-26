import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:team_project_ui_6/Colors.dart';
import 'package:team_project_ui_6/ImageList.dart';
import 'package:team_project_ui_6/UI/login_ui.dart';
import 'package:team_project_ui_6/UI/post_page_ui.dart';
import 'package:team_project_ui_6/UI/search_ui.dart';
import 'package:team_project_ui_6/UI/posting.dart';
import 'package:team_project_ui_6/UI/tagged_page.dart';
import 'package:team_project_ui_6/UI/my_page.dart';

import 'comment.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: IconButton(
          icon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10), // 아이콘에 동일한 마진 추가
            child: Icon(Icons.account_circle),
          ),
          iconSize: 28,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => My_Page()),
            );
            print("Navigate My_page\n");
          },
        ),
        centerTitle: true,
        title: TextButton(
          child: const Text(
            "DOWAZO",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FeedScreen()),
            );
          },
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Icon(Icons.videogame_asset),
              ),
              iconSize: 28,
          ),
          IconButton(
            icon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10), // 아이콘에 동일한 마진 추가
              child: Icon(Icons.search),
            ),
            iconSize: 28,
            onPressed: () {
              // Navigator -> Search
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Search()));
              print("Navigate Search\n");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Text_info').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              // Firestore에서 문서 이름을 가져와서 리스트로 변환
              List<String> idList = snapshot.data!.docs.map((DocumentSnapshot document) {
                return document['text_id'] as String; // 문서 이름을 태그로 사용
              }).toList();

              List<String> titleList = snapshot.data!.docs.map((DocumentSnapshot document) {
                return document['title'] as String;
              }).toList();

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal, // 좌우 스크롤 가능하게 설정
                child: Row(
                  children: idList.map((text_id) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Comment_Page(text_id: text_id,)),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple, // 네모 컨테이너의 배경색 설정
                            borderRadius: BorderRadius.circular(10), // 네모에 둥근 모서리 설정
                          ),
                          child: Center(
                            child: Text(
                              titleList[idList.indexOf(text_id)],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot> (
              stream: FirebaseFirestore.instance.collection('Text_info').orderBy("data", descending: true).snapshots(),
              builder: (context, snapshot) {
                if(snapshot.hasError) {
                  return Text('Error ${snapshot.error}');
                }

                switch(snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    return SingleChildScrollView(
                      child: Column(
                        children: snapshot.data!.docs.map((DocumentSnapshot document) {
                          String imageUrl = document['image_url'];
                          String title = document['title'];
                          List<String> tag_List = List.from(document['tags']);
                          String text_id = document['text_id'];

                          return ImageItem(imageUrl: imageUrl, title: title, tagList: tag_List, text_id: text_id);
                        }).toList(),
                      ),
                    );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Posting()));
          // Navigate Posting
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat, // 우측 하단에 위치하도록 설정
    );
  }
}


class ImageItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String text_id;
  final List<String> tagList;

  ImageItem({required this.imageUrl, required this.title, required this.tagList, required this.text_id});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // 양옆 여백 추가
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10,),
          GestureDetector(
            child: Image.network(imageUrl),
            onTap: () {
              //    게시글 댓글로 넘어갑니다.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Comment_Page(text_id: text_id)),
              );
            },
          ),
          SizedBox(height: 10,),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: tagList.map((tag) => Chip(label:
            ButtonTheme(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Tagged_Page(tag_info: tag))
                  );
                },
                child: Text(tag),
              ),
            ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
