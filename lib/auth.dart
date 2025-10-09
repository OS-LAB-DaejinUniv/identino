/*
* HTTP 통신 및 인증 관련
* 전화번호 담아서 보내고 pubkey, privkey 인증
* */


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:phone_state_background/phone_state_background.dart';
import './initapp.dart';

class Auth {

  Identino identino = Identino();
  // GET 요청을 위한 메서드
  Future<void> getUrl(String phoneNum) async {
    await identino.openDb(); // Ensure the database is initialized

    // 비동기 메서드를 사용하여 phoneNum을 가져옴
    // 전화 감지 -> 상대방 전화번호가 데이터에 담겨야함
    String? friendnum = await identino.getPhoneNumber(phoneNum);

    if (friendnum != null) {
      try {
        var response = await http.get(
            Uri.parse('http://192.168.0.63:3000/$friendnum')
        );
        print(response.body);
      } catch (e) {
        print('HTTP request error: $e');
      }
    } else {
      print('Phone number not found.');
    }
  }

  // is_me가 True인(내 정보) privateKey SELECT 해오기
  // 키 내꺼 가져오기
  Future<void> getPrivKey() async {
    final dbClient = await identino.openDb();
    var result = await dbClient!.rawQuery('''
      SELECT privkey FROM friend
      WHERE is_me = 1
    ''');
    print(result);
  }

  // POST 메서드
  // 내 pubkey 주고 상대방이 지 privkey로 풀어야됨
  Future<http.Response> postAuth() async {
    return http.post(
      Uri.parse('http://192.168.0.63:3000/postdata'),
      headers: <String,String> {
        'Content-Type' : 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String,String> {
        'key' : '상대방 전화번호(전화감지 필요)',
        'value' : '상대방이 받을 챌린지+랜덤 12자리 문자열'
      }),
    );
  }
}
