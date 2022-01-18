// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:encrypt/encrypt.dart' as enc;
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class App extends StatelessWidget {
//   const App({Key key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Encrept();
//   }
// }
//
// class Encrept extends StatefulWidget {
//   static const routeName = 'Encrept';
//   const Encrept({Key key}) : super(key: key);
//
//   @override
//   _EncreptState createState() => _EncreptState();
// }
//
// class _EncreptState extends State<Encrept> {
//   bool _isGranted = true;
//   String filename = "demo.zip";
//   String videoUrl =
//       "https://glearningcenter.com/wp-content/uploads/2021/12/Enterprenuor1.mp4";
//
//   Future<List<Directory>> get getAppDir async {
//     final appDocDir = await getExternalStorageDirectories();
//     return appDocDir;
//   }
//
//   Future<Directory> get getExternalVisibleDir async {
//     if (await Directory('/storage/emulated/0/MyEncFolder').exists()) {
//       final externalDir = Directory('/storage/emulated/0/MyEncFolder');
//       return externalDir;
//     } else
//       await Directory('/storage/emulated/0/MyEncFolder')
//           .create(recursive: true);
//     final externalDir = Directory('/storage/emulated/0/MyEncFolder');
//     return externalDir;
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       body: Center(
//         child: Column(
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 if (_isGranted) {
//                   Directory d = await getExternalVisibleDir;
//                   //Director hidden dir = await getAppDir;
//                   _downloadAndCreate(videoUrl, d, filename);
//                 } else {
//                   print("no permission granted");
//                   requestStoragePermission();
//                 }
//               },
//               child: Text("download & encrpt"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 if (_isGranted) {
//                   Directory d = await getExternalVisibleDir;
//                   //Director hidden dir = await getAppDir;
//                   _getNormalFile(d, filename);
//                 } else {
//                   print("no permission granted");
//                   requestStoragePermission();
//                 }
//               },
//               child: Text("open"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// _getNormalFile(Directory d, filename) async {
//   Uint8List encData = await _readData(d.path + '/$filename.aes');
//
//   var plainData = await _decryptData(encData);
//   String p = await _writeData(plainData, d.path + '/$filename');
//   print("file decrypted successfully: $p");
// }
//
// _decryptData(encData) {
//   print("file dec");
//   enc.Encrypted en = new enc.Encrypted(encData);
//   return MyEncrypt.myEncrypter.decryptBytes(en, iv: MyEncrypt.myIv);
// }
//
// _downloadAndCreate(String url, Directory d, filename) async {
//   if (await canLaunch(url)) {
//     print("Data Downloading....");
//     var resp = await http.get(url);
//     var encResult = _encryptData(resp.bodyBytes);
//     String p = await _writeData(encResult, d.path + '/$filename.aes');
//     print("file encrypted scussully $p");
//   } else {
//     print("cannot lunch url");
//   }
// }
//
// Future<Uint8List> _readData(fileNameWithPath) async {
//   print("reading data....");
//   File f = File(fileNameWithPath);
//   return await f.readAsBytes();
// }
//
// Future _writeData(dataToWrite, fileNameWithPath) async {
//   print("writing data....");
//   File f = File(fileNameWithPath);
//   await f.writeAsBytes(dataToWrite);
//   return f.absolute.toString();
// }
//
// _encryptData(plainString) {
//   print("Encrypting File");
//   final encrypted =
//       MyEncrypt.myEncrypter.encryptBytes(plainString, iv: MyEncrypt.myIv);
//   return encrypted.bytes;
// }
//
// class MyEncrypt {
//   static final myKey = enc.Key.fromUtf8('TechWithVPTechWithVPTechWithVP12');
//   static final myIv = enc.IV.fromUtf8("VivekPanchal1122");
//   static final myEncrypter = enc.Encrypter(enc.AES(myKey));
// }
