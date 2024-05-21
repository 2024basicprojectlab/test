import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:team_project_ui_6/Colors.dart';
import 'package:team_project_ui_6/ImageList.dart';
import 'package:team_project_ui_6/UI/login_ui.dart';
import 'package:team_project_ui_6/UI/serch_ui.dart';
import 'package:team_project_ui_6/UI/posting.dart';
import 'package:team_project_ui_6/UI/tagged_page.dart';
import 'package:team_project_ui_6/UI/my_page.dart';

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
          icon: Icon(Icons.account_circle),
          onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => My_Page())
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
            icon: Icon(Icons.search),
            onPressed: () {
              // Navigator -> Search
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Search()));
              print("Navigate Search\n");
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot> (
        stream: FirebaseFirestore.instance.collection('Text_info').snapshots(),
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

                    return ImageItem(imageUrl: imageUrl, title: title, tagList: tag_List);
                  }).toList(),
                ),
              );
          }
        },
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
        backgroundColor: Colors.black,
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // 우측 하단에 위치하도록 설정
    );
  }
}


class ImageItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final List<String> tagList;

  ImageItem({required this.imageUrl, required this.title, required this.tagList});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
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
                /*    게시글 댓글로 넘어갑니다.
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                );
                 */
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
