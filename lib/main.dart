import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart'; // 딥링크 관련 패키지
import './initapp.dart'; // 앱 초기화 관련
import './friend.dart'; // 친구 추가 관련
import './auth.dart'; // 인증 관련
import './main_page.dart'; // 메인 페이지
import './phone_list_page.dart'; // 전화번호 리스트 페이지
import './CallDialog.dart'; // 오버레이에서 사용할 다이얼로그
import 'package:flutter_overlay_window/flutter_overlay_window.dart'; // 오버레이 관련 패키지
import 'package:phone_state_background/phone_state_background.dart';
import 'package:permission_handler/permission_handler.dart';

// 전화 감지
@pragma('vm:entry-point')
/// Defines a callback that will handle all background incoming events
Future<void> phoneStateBackgroundCallbackHandler(
    PhoneStateBackgroundEvent event,
    String number,
    int duration,
    ) async {
  switch (event) {
    case PhoneStateBackgroundEvent.incomingstart:
      log('Incoming call start, number: $number, duration: $duration s');
      break;
    case PhoneStateBackgroundEvent.incomingmissed:
      log('Incoming call missed, number: $number, duration: $duration s');
      break;
    case PhoneStateBackgroundEvent.incomingreceived:
      log('Incoming call received, number: $number, duration: $duration s');
      break;
    case PhoneStateBackgroundEvent.incomingend:
      log('Incoming call ended, number: $number, duration $duration s');
      break;
    case PhoneStateBackgroundEvent.outgoingstart:
      log('Ougoing call start, number: $number, duration: $duration s');
      break;
    case PhoneStateBackgroundEvent.outgoingend:
      log('Ougoing call ended, number: $number, duration: $duration s');
      break;
  }
}
Future<void> startPhoneStateService() async {
  // 권한 요청
  var status = await Permission.phone.status;
  if (!status.isGranted) {
    status = await Permission.phone.request();
  }

  // 권한이 있을 경우만 초기화
  if (status.isGranted) {
    PhoneStateBackground.initialize(phoneStateBackgroundCallbackHandler);
  } else {
    log('Phone state permission not granted.');
  }
}


Future<void> startOverlay() async {
  bool? isGranted = await FlutterOverlayWindow.isPermissionGranted();

  if (isGranted != true) {
    print("Overlay permission not granted. Requesting permission...");
    await FlutterOverlayWindow.requestPermission();
  }

  // 권한이 부여되었는지 다시 확인
  isGranted = await FlutterOverlayWindow.isPermissionGranted();

  if (isGranted == true) {
    print("Permission granted. Starting overlay...");
    await FlutterOverlayWindow.showOverlay(
      height: 200,
      width: 300,
      alignment: OverlayAlignment.center,
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      enableDrag: true,
    );
    print("Overlay started.");
  } else {
    print("Overlay permission still not granted.");
  }
}

// 메인 함수, 앱의 시작점
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  startPhoneStateService();
  startOverlay();
  runApp(MyApp()); // 앱 실행

  Identino identino = Identino(); // DB와 관련된 클래스 초기화

  await identino.openDb(); // DB 열기
  try {
    await identino.insertMyData(); // 데이터 삽입
  } catch (e) {
    print(e); // 에러 처리
  }

  var table = await identino.getTableData(); // 테이블 데이터 가져오기
  print(table); // 테이블 데이터 출력
  Auth auth = Auth();
  await auth.getUrl('전화중인번호(상대방)'); // URL 가져오기
  await auth.getPrivKey(); // 개인 키 가져오기
}

// 오버레이의 진입점
@pragma("vm:entry-point")
void incallOverlay() {
  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(child: CallDialog()) // 오버레이로 CallDialog 사용
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late DeepLinkService _deepLinkService;
  late Friend _friend;

  @override
  void initState() {
    super.initState();

    startOverlay(); // 앱 실행과 동시에 오버레이 시작

    _deepLinkService = DeepLinkService(); // 딥링크 서비스 초기화
    _friend = Friend(); // 친구 추가 클래스 초기화

    // 딥 링크 처리
    _deepLinkService.initDeepLinks((Uri uri) async {
      // 딥 링크에서 쿼리 파라미터 추출 후 DB에 삽입
      Map<String, String?> queryParams = PhoneListPage().getQueryParam('$uri');
      if (queryParams != null) {
        String phoneNum = queryParams['phone_num'] ?? '';
        String pubkey = queryParams['pubkey'] ?? '';
        await _friend.addFriend(phoneNum, pubkey); // 친구 추가 메서드 호출
      } else {
        print('Query Parameter 받아오기 실패함');
      }
    });
  }

  @override
  void dispose() {
    _deepLinkService.dispose(); // 딥 링크 서비스 정리
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 앱의 메인 위젯을 반환
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: MainPage()), // 메인 페이지 표시
    );
  }
}

// 딥링크 서비스 클래스
class DeepLinkService {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  // 딥 링크 초기화
  Future<void> initDeepLinks(Function(Uri uri) onUriReceived) async {
    _appLinks = AppLinks();

    // 딥 링크 URI 스트림을 리슨
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      debugPrint('Received deep link: $uri');
      onUriReceived(uri); // 콜백을 통해 처리
    });
  }

  // 딥 링크 서비스 정리
  void dispose() {
    _linkSubscription?.cancel();
  }
}
