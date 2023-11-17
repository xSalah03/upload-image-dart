import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

Future<void> main(List<String> arguments) async {
  print('Début de la requête !!');
  HttpOverrides.global = MyHttpOverrides();

  try {
    await uploadFiles();
  } catch (e) {
    print('Error: $e');
  }

  print('Fin de la requête !!');
}

Future<void> uploadFiles() async {
  var headers = {
    'Content-Type':
        'multipart/form-data;boundary=WebKitFormBoundaryUmZoXOtOBNCTLyxT',
    'Cookie':
        'B1SESSION=161d2b80-851f-11ee-c000-000c296e0a5f-140250966966272-23718; ROUTEID=.node3'
  };

  var uri = Uri.parse('https://192.168.0.32:50000/b1s/v1/Attachments2');

  // Construct the desktop folder path
  String desktopFolder = Platform.environment['HOME'] ?? '';
  desktopFolder = join(desktopFolder, 'Desktop');

  // Double-check the filenames and paths
  String filePath2 = '$desktopFolder/logo.jpeg';
  print(filePath2);
  // Verify that the files at the specified paths exist
  if (!File(filePath2).existsSync()) {
    throw FileSystemException('One or more files not found.');
  }

  // Read the file contents as bytes
  List<int> fileBytes2 = File(filePath2).readAsBytesSync();

  var boundary = 'WebKitFormBoundaryUmZoXOtOBNCTLyxT';
  var body = <int>[
    ...'--$boundary\r\n'.codeUnits,
    ...'Content-Disposition: form-data; name="files"; filename="line4.jpg"\r\n'
        .codeUnits,
    ...'Content-Type: image/jpeg\r\n\r\n'.codeUnits,
    ...fileBytes2,
    ...'\r\n--$boundary--\r\n'.codeUnits,
  ];

  var request = http.Request('POST', uri);
  request.headers.addAll(headers);
  request.bodyBytes = Uint8List.fromList(body);

  // Send the request and get the response
  http.StreamedResponse response = await request.send();

  if (response.statusCode == 201) {
    print('Upload success');
  } else {
    print('Upload failed');
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
