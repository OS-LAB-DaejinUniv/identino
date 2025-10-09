/*
* Friend Database
* 수정해야함
* TO DO :
* 1. SQL Query 수정 => INSERT Query 추가(URL로 User가 in APP 하면 INSERT Query 실행)
*
* */

import 'dart:async';
import 'package:contacts_service/contacts_service.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import './initapp.dart';
import 'main.dart';

class Friend extends Identino {

  @override
  Future<Database?> openDb() {
    // TODO: implement openDb
    return super.openDb();
  }

  Future<void> addFriend(String phone_num, String pubkey) async {
    final dbClient = await openDb();
    try {
      var insertFriend = await dbClient!.rawInsert('''
      INSERT INTO friend (phone_num, pubkey)
      VALUES (?,?)
    ''',[phone_num,pubkey]);
      print('Insert Result: $insertFriend');
    }
    catch(e) {
      print('Insert Error : $e');
    }
  }

  // DB에서 phone_num SELECT 해옴
  Future<List<String>> getFriendPhoneNumbers() async {
    final dbClient = await openDb();
    try {
      List<Map<String, dynamic>> selectResult = await dbClient!.rawQuery('SELECT phone_num FROM friend');
      print('Select Result : $selectResult');

      // Extract phone numbers from query result
      List<String> phoneNumbers = selectResult.map((row) => row['phone_num'] as String).toList();
      print('Extracted Phone Numbers: $phoneNumbers');  // Log phone numbers

      return phoneNumbers;
    } catch (e) {
      print('Error retrieving friend phone numbers: $e');
      return [];  // Return an empty list in case of error
    }
  }

  // 전화번호부에서 Name 가지고 옴
  Future<List<Map<String, String>>> getContactsByPhoneNumbers(List<String> phoneNumbers) async {
    List<Map<String, String>> contactsList = [];
    Iterable<Contact> contacts = await ContactsService.getContacts();  // Get all contacts
    print('Contacts Retrieved: ${contacts.map((contact) => contact.phones)}');  // Log phone numbers of retrieved contacts

    for (var contact in contacts) {
      for (var phone in contact.phones!) {
        print('Checking phone: ${phone.value}');  // Log phone numbers from contacts
        if (phoneNumbers.contains(phone.value?.replaceAll(RegExp(r'\D'), ''))) {  // Remove non-digit characters for comparison
          contactsList.add({
            'name': contact.displayName ?? 'No Name',
            'phone': phone.value!,
          });
          print('Match Found: ${contact.displayName} - ${phone.value}');  // Log matches
          break;  // No need to check further if we found a match
        }
      }
    }

    print('Final Contacts List: $contactsList');  // Log final list of contacts
    return contactsList;
  }

}


