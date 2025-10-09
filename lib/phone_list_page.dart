import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import './getPhoneNum.dart';
import 'package:permission_handler/permission_handler.dart';// 권한 요청을 위한 패키지
import './initapp.dart';


class PhoneListPage extends StatelessWidget {
  const PhoneListPage({super.key});

  // 비동기적으로 전화번호와 공개키 가져오기
  Future<Map<String, String>> _getPhoneAndPubKey() async {

    GetPhoneNum getphonenum = GetPhoneNum();
    Identino getMyPubKey = Identino();

    String phone_num = await getphonenum.getMyNum();  // 비동기 전화번호 가져오기
    String? pubkey = await getMyPubKey.getMyPubKey();    // 비동기 공개키 가져오기

    return {
      'phone_num':  phone_num,
      'pubkey': pubkey ?? 'No pubkey',
    };
  }

  // Query Parameter URL INSERT (phone_num, pubkey)
  Map<String,String?> getQueryParam(String url) {
    Uri uri = Uri.parse(url);

    String? phoneNum = uri.queryParameters['phone_num'];
    String? base64PubKey = uri.queryParameters['pubkey'];

    if (phoneNum != null && base64PubKey != null) {
      String pubkey = utf8.decode(base64.decode(base64PubKey)); // base64 디코딩
      print('Decoded pubkey : $pubkey, Phone number: $phoneNum');
      return {'phone_num': phoneNum, 'pubkey': pubkey}; // Map 형식으로 반환
    } else {
      print('No Decoded');
      return {}; // 빈 맵 반환
    }

  }

  @override
  Widget build(BuildContext context) {
    requestPermissions();  // 전화번호부 접근 권한 요청

    return Scaffold(
      appBar: AppBar(
        title: Text('Phone List'),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _getPhoneAndPubKey(),  // 전화번호와 공개키를 가져오는 Future
        builder: (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());  // 로딩 중일 때
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));  // 에러 처리
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));  // 데이터가 없는 경우
          } else {
            // 비동기 작업이 완료되어 전화번호와 공개키 데이터를 받음
            String phone_num = snapshot.data!['phone_num']!;
            String pubkey = snapshot.data!['pubkey']!;

            return FutureBuilder<List<Contact>>(
              future: GetPhoneNum().getNum(),  // 전화번호부 가져오기
              builder: (BuildContext context, AsyncSnapshot<List<Contact>> contactSnapshot) {
                if (contactSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());  // 로딩 중일 때
                } else if (contactSnapshot.hasError) {
                  return Center(child: Text('Error: ${contactSnapshot.error}'));  // 에러 처리
                } else if (!contactSnapshot.hasData || contactSnapshot.data!.isEmpty) {
                  return Center(child: Text('No Contacts found.'));  // 연락처가 없는 경우
                } else {
                  List<Contact> contacts = contactSnapshot.data!;
                  return ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      Contact contact = contacts[index];

                      // 연락처가 없거나 빈 경우 처리
                      String displayName = contact.displayName ?? 'No Name';
                      // 전화번호 목록이 비어 있으면 기본값을 'No Phone Number'로 설정
                      String phoneNumber = (contact.phones != null && contact.phones!.isNotEmpty)
                          ? contact.phones!.first.value ?? 'No Phone Number'
                          : 'No Phone Number';

                      return Column(
                        children: [
                          ListTile(
                            title: Text(displayName, style: TextStyle(color: Colors.amber, fontSize: 20)),
                            subtitle: Text(phoneNumber),  // 존재하는 전화번호 출력
                            trailing: TextButton(
                              onPressed: () async {
                                // 공개키를 Base64로 인코딩 후 URL 생성
                                String base64PubKey = base64.encode(utf8.encode(pubkey));
                                String url = 'https://os-lab-daejinuniv.github.io/identino/?phone_num=$phone_num&pubkey=$base64PubKey';

                                // 공유하기
                                Share.share(url);
                              },
                              child: Icon(Icons.group_add),
                            ),
                          ),
                          Divider(),
                        ],
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
  // 전화번호부 접근 권한 요청
  Future<void> requestPermissions() async {
    PermissionStatus status = await Permission.contacts.status;
    if (!status.isGranted) {
      await Permission.contacts.request();
    }
  }
}

