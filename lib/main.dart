import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;
// import 'package:fluwx/fluwx.dart' as fluwx;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// StreamController<BaseWeChatResponse> _weChatResponseEventHandlerController =
//     new StreamController.broadcast();
//
// Future _methodHandler(MethodCall methodCall) {
//   var response =
//       BaseWeChatResponse.create(methodCall.method, methodCall.arguments);
//   _weChatResponseEventHandlerController.add(response);
//   return Future.value();
// }

class _MyHomePageState extends State<MyHomePage> {
  // final _storage = FlutterSecureStorage();

  /// Response answers from WeChat after sharing, payment etc.
  // Stream<BaseWeChatResponse> get weChatResponseEventHandler =>
  //     _weChatResponseEventHandlerController.stream;

  // MethodChannel _channel = MethodChannel('com.jarvanmo/fluwx')
  //   ..setMethodCallHandler(_methodHandler);

  ///just open WeChat, noting to do.
  // _openWeChatApp() async {
  //   print('Wechat Login Button Tapped!');
  //   fluwx
  //       .sendWeChatAuth(scope: "snsapi_userinfo", state: "wechat_sdk_demo_test")
  //       .then((data) => print('Wechat auth data'));
  //   // return await _channel.invokeMethod("openWXApp");
  // }

  // Future<bool> handleOpenWeChatApp() async {
  //   // return await _channel.invokeMethod("openWXApp");
  //   return await
  // }

  String _result = "无";

  @override
  void initState() {
    print('init state called');
    // fluwx.weChatResponseEventHandler.distinct((a, b) => a == b).listen((res) {
    //   if (res is fluwx.WeChatAuthResponse) {
    //     setState(() {
    //       _result = "state :${res.state} \n code:${res.code}";
    //     });
    //   }
    // });
    super.initState();
    // Login with WeChat to get Code
    // fluwx.weChatResponseEventHandler.distinct((a, b) => a == b).listen((res) {
    //   if (res is fluwx.WeChatAuthResponse) {
    //     setState(() {
    //       print("sate: ${res.state} \n code: ${res.code}");
    //       _result = "sate: ${res.state} \n code: ${res.code}";
    //     });
    //   }
    // });
    //
    // // Register app to WeChat
    // _initFluwx();
  }

  // _initFluwx() async {
  //   await fluwx.registerWxApi(
  //       appId: "wx276777ea9268832c",
  //       universalLink: "https://konfulononline.com");
  //   var result = fluwx.isWeChatInstalled;
  //   print("isInstalled $result");
  // }

  // void _loginWX() {
  //   print("Login with WeChat Tapped");
  //   fluwx
  //       .sendWeChatAuth(scope: "snsapi_userinfo", state: "login")
  //       .then((data) => {
  //             setState(() {
  //               print("Pull WeChat user information: ${data.toString()}");
  //             })
  //           })
  //       .catchError((e) {
  //     print('weChatLogin e $e');
  //   });
  // }

  @override
  void dispose() {
    super.dispose();
    _result = null;
  }

  void addAppleUsername(String username) async {
    // final String key = 'AppleUsername';
    final String key = AppleAuth()._APPLE_USERNAME_KEY;
    // final String value = username;
    AppleAuth().appleUsername = username;

    // await _storage.write(key: key, value: AppleAuth().getAppleUsername);
  }

  static final FacebookLogin facebookLogin = FacebookLogin();
  String _message = 'Log in/out by pressing the button below.';

  Future<Null> _login() async {
    final FacebookLoginResult result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        _showMessage('''
        Logged in!
        
        Token: ${accessToken.token}
        User id: ${accessToken.userId}
        Expire: ${accessToken.expires}
        Permission: ${accessToken.permissions}
        Declined permission: ${accessToken.permissions}
        ''');
        break;

      case FacebookLoginStatus.cancelledByUser:
        _showMessage('Login canceled by the user');
        break;
      case FacebookLoginStatus.error:
        _showMessage('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
  }

  Future<Null> _logOut() async {
    await facebookLogin.logOut();
    _showMessage('Logged out.');
  }

  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Testing Login with Facebook'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_message),
            RaisedButton(
              onPressed: _login,
              child: Text('Log in'),
            ),
            RaisedButton(
              onPressed: _logOut,
              child: Text('Logout'),
            ),
            SignInWithAppleButton(
              onPressed: () async {
                final credential = await SignInWithApple.getAppleIDCredential(
                  scopes: [
                    AppleIDAuthorizationScopes.email,
                    AppleIDAuthorizationScopes.fullName,
                  ],
                  // webAuthenticationOptions: WebAuthenticationOptions(
                  //   clientId:
                  //       'com.aboutyou.dart_packages.sign_in_with_apple.example',
                  //   redirectUri: Uri.parse(
                  //     'https://flutter-sign-in-with-apple-example.glitch.me/callbacks/sign_in_with_apple',
                  //   ),
                  // ),
                );
                final String firstname = credential.givenName;
                final String lastname = credential.familyName;
                addAppleUsername('$firstname $lastname');
                print('Apple credential ${credential.email}');

                Timer(Duration(seconds: 5), () async {
                  // String value =
                  // await _storage.read(key: AppleAuth()._APPLE_USERNAME_KEY);
                  // print('Getting Apple Username from Keychain $value');
                });

                final signInWithAppleEndPoint = Uri(
                    scheme: 'https',
                    host: 'flutter-sign-in-with-apple-example.glitch.me',
                    path: '/sign_in_with_apple',
                    queryParameters: <String, String>{
                      'code': credential.authorizationCode,
                      'firstName': credential.givenName,
                      'lastName': credential.familyName,
                      'useBundleId':
                          Platform.isIOS || Platform.isMacOS ? 'true' : 'false',
                      if (credential.state != null) 'state': credential.state,
                    });
                final session = await http.Client().post(
                  signInWithAppleEndPoint,
                );

                print('Apple Id Session $session');
              },
            ),
            RaisedButton(
              color: Colors.green,
              onPressed: () {
                print('GGWP');
                // openWeChatApp();
                // fluwx.openWeChatApp();
                // _loginWX();
                // handleOpenWeChatApp();
                // _openWeChatApp();
              },
              child: Text('Wechat Login'),
            ),
            Text(_result),
          ],
        ),
      ),
    );
  }
}

class AppleAuth {
  static final AppleAuth sharedInstance = AppleAuth._internal();

  factory AppleAuth() {
    return sharedInstance;
  }

  AppleAuth._internal();

  @protected
  final String _APPLE_USERNAME_KEY = 'appleUsernameKey';
  String appleUsername;

  String get getAppleUsername => appleUsername;

  void setAppleUsername(String username) {
    appleUsername = username;
  }
}

// const String _errCode = "errCode";
// const String _errStr = "errStr";
//
// typedef BaseWeChatResponse _WeChatResponseInvoker(Map argument);
//
// Map<String, _WeChatResponseInvoker> _nameAndResponseMapper = {
//   "onShareResponse": (Map argument) => WeChatShareResponse.fromMap(argument),
//   "onAuthResponse": (Map argument) => WeChatAuthResponse.fromMap(argument),
//   "onLaunchMiniProgramResponse": (Map argument) =>
//       WeChatLaunchMiniProgramResponse.fromMap(argument),
//   "onPayResponse": (Map argument) => WeChatPaymentResponse.fromMap(argument),
//   "onSubscribeMsgResp": (Map argument) =>
//       WeChatSubscribeMsgResponse.fromMap(argument),
//   "onWXOpenBusinessWebviewResponse": (Map argument) =>
//       WeChatOpenBusinessWebviewResponse.fromMap(argument),
//   "onAuthByQRCodeFinished": (Map argument) =>
//       WeChatAuthByQRCodeFinishedResponse.fromMap(argument),
//   "onAuthGotQRCode": (Map argument) =>
//       WeChatAuthGotQRCodeResponse.fromMap(argument),
//   "onQRCodeScanned": (Map argument) =>
//       WeChatQRCodeScannedResponse.fromMap(argument),
// };
//
// class BaseWeChatResponse {
//   final int errCode;
//   final String errStr;
//
//   bool get isSuccessful => errCode == 0;
//
//   BaseWeChatResponse._(this.errCode, this.errStr);
//
//   /// create response from response pool
//   factory BaseWeChatResponse.create(String name, Map argument) =>
//       _nameAndResponseMapper[name](argument);
// }
//
// class WeChatShareResponse extends BaseWeChatResponse {
//   final int type;
//
//   WeChatShareResponse.fromMap(Map map)
//       : type = map["type"],
//         super._(map[_errCode], map[_errStr]);
// }
//
// class WeChatAuthResponse extends BaseWeChatResponse {
//   final int type;
//   final String country;
//   final String lang;
//   final String code;
//   final String state;
//
//   WeChatAuthResponse.fromMap(Map map)
//       : type = map["type"],
//         country = map["country"],
//         lang = map["lang"],
//         code = map["code"],
//         state = map["state"],
//         super._(map[_errCode], map[_errStr]);
//
//   @override
//   bool operator ==(other) {
//     if (other is WeChatAuthResponse) {
//       return code == other.code &&
//           country == other.country &&
//           lang == other.lang &&
//           state == other.state;
//     } else {
//       return false;
//     }
//   }
//
//   @override
//   int get hashCode =>
//       super.hashCode + errCode.hashCode &
//       1345 + errStr.hashCode &
//       15 + (code ?? "").hashCode &
//       1432;
// }
//
// class WeChatLaunchMiniProgramResponse extends BaseWeChatResponse {
//   final int type;
//   final String extMsg;
//
//   WeChatLaunchMiniProgramResponse.fromMap(Map map)
//       : type = map["type"],
//         extMsg = map["extMsg"],
//         super._(map[_errCode], map[_errStr]);
// }
//
// class WeChatPaymentResponse extends BaseWeChatResponse {
//   final int type;
//   final String extData;
//
//   WeChatPaymentResponse.fromMap(Map map)
//       : type = map["type"],
//         extData = map["extData"],
//         super._(map[_errCode], map[_errStr]);
// }
//
// class WeChatSubscribeMsgResponse extends BaseWeChatResponse {
//   final String openid;
//   final String templateId;
//   final String action;
//   final String reserved;
//   final int scene;
//
//   WeChatSubscribeMsgResponse.fromMap(Map map)
//       : openid = map["openid"],
//         templateId = map["templateId"],
//         action = map["action"],
//         reserved = map["reserved"],
//         scene = map["scene"],
//         super._(map[_errCode], map[_errStr]);
// }
//
// class WeChatOpenBusinessWebviewResponse extends BaseWeChatResponse {
//   final int type;
//   final int errCode;
//   final int businessType;
//   final String resultInfo;
//
//   WeChatOpenBusinessWebviewResponse.fromMap(Map map)
//       : type = map["type"],
//         errCode = map[_errCode],
//         businessType = map["businessType"],
//         resultInfo = map["resultInfo"],
//         super._(map[_errCode], map[_errStr]);
// }
//
// class WeChatAuthByQRCodeFinishedResponse extends BaseWeChatResponse {
//   final String authCode;
//   final AuthByQRCodeErrorCode qrCodeErrorCode;
//
//   WeChatAuthByQRCodeFinishedResponse.fromMap(Map map)
//       : authCode = map["authCode"],
//         qrCodeErrorCode = (_authByQRCodeErrorCodes[_errCode] ??
//             AuthByQRCodeErrorCode.UNKNOWN),
//         super._(map[_errCode], map[_errStr]);
// }
//
// ///[qrCode] in memory.
// class WeChatAuthGotQRCodeResponse extends BaseWeChatResponse {
//   final Uint8List qrCode;
//
//   WeChatAuthGotQRCodeResponse.fromMap(Map map)
//       : qrCode = map["qrCode"],
//         super._(map[_errCode], map[_errStr]);
// }
//
// class WeChatQRCodeScannedResponse extends BaseWeChatResponse {
//   WeChatQRCodeScannedResponse.fromMap(Map map)
//       : super._(map[_errCode], map[_errStr]);
// }
//
// ///WechatAuth_Err_OK(0),
// ///WechatAuth_Err_NormalErr(-1),
// ///WechatAuth_Err_NetworkErr(-2),
// ///WechatAuth_Err_JsonDecodeErr(-3),
// ///WechatAuth_Err_Cancel(-4),
// ///WechatAuth_Err_Timeout(-5),
// ///WechatAuth_Err_Auth_Stopped(-6);
// ///[AuthByQRCodeErrorCode.JSON_DECODE_ERR] means WechatAuth_Err_GetQrcodeFailed when platform is iOS
// ///only Android will get [AUTH_STOPPED]
// enum AuthByQRCodeErrorCode {
//   OK,
//   NORMAL_ERR,
//   NETWORK_ERR,
//   JSON_DECODE_ERR,
//   CANCEL,
//   TIMEOUT,
//   AUTH_STOPPED,
//   UNKNOWN
// }
//
// const Map<int, AuthByQRCodeErrorCode> _authByQRCodeErrorCodes = {
//   0: AuthByQRCodeErrorCode.OK,
//   -1: AuthByQRCodeErrorCode.NORMAL_ERR,
//   -2: AuthByQRCodeErrorCode.NETWORK_ERR,
//   -3: AuthByQRCodeErrorCode.JSON_DECODE_ERR,
//   -4: AuthByQRCodeErrorCode.CANCEL,
//   -5: AuthByQRCodeErrorCode.AUTH_STOPPED
// };
