import 'package:flutter/material.dart';
import './friend.dart';

class FriendListPage extends StatelessWidget {
  const FriendListPage({Key? key}) : super(key: key);

  Future<List<Map<String, String>>> _getFriendsWithNames() async {
    Friend friend = Friend();
    List<String> phoneNumbers = await friend.getFriendPhoneNumbers();  // Get phone numbers from DB
    print('Phone Numbers for Matching: $phoneNumbers');  // Log phone numbers

    List<Map<String, String>> contacts = await friend.getContactsByPhoneNumbers(phoneNumbers);  // Get names from phonebook
    print('Contacts with Names: $contacts');  // Log contacts
    return contacts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend List'),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _getFriendsWithNames(),  // Friends with names Future
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, String>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());  // 로딩 중일 때
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));  // 에러 처리
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Friends found.'));  // 친구가 없는 경우
          } else {
            List<Map<String, String>> friends = snapshot.data!;

            return ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                Map<String, String> friend = friends[index];
                String name = friend['name'] ?? 'No Name';  // 친구 이름
                String phoneNumber = friend['phone'] ?? 'No Phone Number';  // 전화번호

                return Column(
                  children: [
                    ListTile(
                      title: Text(name, style: TextStyle(color: Colors.amber, fontSize: 20)),
                      subtitle: Text(phoneNumber),  // 존재하는 전화번호 출력
                    ),
                    Divider(),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
