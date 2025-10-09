import 'package:fast_rsa/fast_rsa.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'getPhoneNum.dart';

class Identino {
  final int version = 1;
  Database? db;

  Identino();

  // Database 생성할 경로 지정
  Future<String> getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Database 열고 Table 생성
  Future<Database?> openDb() async {
    if (db == null) {
      db = await openDatabase(
        join(await getDatabasesPath(), 'friend.db'),
        onCreate: (database, version) {
          database.execute('''
            CREATE TABLE friend(
              phone_num TEXT PRIMARY KEY UNIQUE NOT NULL,
              pubkey TEXT UNIQUE NOT NULL,
              privkey TEXT UNIQUE,
              is_me INTEGER
            )
          ''');
        },
        version: version,
      );
    }
    return db;
  }

  // 나에 대한 정보 DB 최초 삽입
  Future<void> insertMyData() async {
    GetPhoneNum getMyNum = GetPhoneNum();
    String myPhoneNumber = await getMyNum.getMyNum(); // 전화번호 비동기적으로 받아오기

    var result = await RSA.generate(2048);
    final dbClient = await openDb();

    var existingData = await dbClient!.rawQuery('SELECT * FROM friend WHERE is_me = 1');
    print('Existing data: $existingData');

    if (existingData.isEmpty) {
      try {
        int insertResult = await dbClient.rawInsert('''
        INSERT INTO friend (phone_num, pubkey, privkey, is_me) 
        VALUES (?, ?, ?, ?)
      ''', [myPhoneNumber, result.publicKey, result.privateKey, 1]);

        print('Insert result: $insertResult');
      } catch (e) {
        print('Error inserting data: $e');
      }
    } else {
      print('Data already exists');
    }
  }

  Future<String?> getMyPubKey() async {
    final dbClient = await openDb();
    final List<Map<String, dynamic>> result = await dbClient!.rawQuery('''
      SELECT pubkey FROM friend
      WHERE is_me = 1
    ''');
    // SELECT한 데이터가 비어있지 않으면 pubeky(result) 반환
    if(result.isNotEmpty) {
      return result.first['pubkey'] as String?;
    }

    return null;
  }


  Future<String?> getPhoneNumber(String phoneNum) async {
    final dbClient = await openDb();
    final List<Map<String, dynamic>> result = await dbClient!.rawQuery('''
      SELECT phone_num FROM friend
      WHERE phone_num = ?
    ''', [phoneNum]);

    if (result.isNotEmpty) {
      return result.first['phone_num'] as String?;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getTableData() async {
    final dbClient = await openDb(); // 데이터베이스를 열어줍니다.

    if (dbClient != null) {
      var result = await dbClient.rawQuery('SELECT * FROM friend'); // 모든 컬럼을 조회합니다.
      print('Table data: $result'); // 결과를 로그로 출력합니다.
      return result;
    } else {
      print('Database is null');
      return []; // 만약 dbClient가 null이라면 빈 리스트를 반환합니다.
    }
  }


}
