/*
* Main Page
* A total of 4 Menu Tabs
* - Phone Book List
* - Added Friend List
* - Setting
* - Call History : History Log
* */


import 'package:flutter/material.dart';
import './phone_list_page.dart';
import './friend_list.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Identino'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // 2열로 그리드 생성
          crossAxisSpacing: 10, // 박스 간의 수평 간격
          mainAxisSpacing: 10, // 박스 간의 수직 간격
          children: <Widget>[
            // 첫 번째 메뉴 박스
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PhoneListPage())
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone, size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text('Menu 1', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            // 두 번째 메뉴 박스
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FriendListPage())
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.tealAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people, size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text('Menu 2', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            // 세 번째 메뉴 박스
            GestureDetector(
              onTap: () {
                print('세 번째 메뉴 클릭');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey[600],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.settings, size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text('Settings', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            // 네 번째 메뉴 박스
            GestureDetector(
              onTap: () {
                print('네 번째 메뉴 클릭');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info, size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text('Call History', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
