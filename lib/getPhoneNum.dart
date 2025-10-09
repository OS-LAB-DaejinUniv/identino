import 'package:contacts_service/contacts_service.dart';
import 'package:get_phone_number/get_phone_number.dart';

class GetPhoneNum{

  GetPhoneNum();

  // 전화번호부 불러오기
  Future<List<Contact>> getNum() async {
    // List 형태로 contacts 변수에 전화 번호부 불러온 걸 담음.
    List<Contact> contacts = await ContactsService.getContacts();

    // contacts 변수에 전화번호부에 저장된 이름, 전화번호 불러옴.
    for (Contact c in contacts) {
      print('이름: ${c.displayName}');

      // 전화번호가 없을 경우를 처리
      if (c.phones != null && c.phones!.isNotEmpty) {
        print('폰넘: ${c.phones!.first.value}');
      } else {
        print('폰넘: No Phone Number');
      }
    }
    return contacts;
  }

  // 내 전화번호 불러오기
  Future<dynamic> getMyNum() async {
    String phonenumber = await GetPhoneNumber().get();
    print('폰 넘버: $phonenumber');
    return phonenumber;
  }
}
