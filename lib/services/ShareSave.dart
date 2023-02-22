import 'dart:convert';
import 'dart:io';
import "package:universal_html/html.dart" as html;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareFiles{
  Future<void> shareLocal(f, explanationText) async{
    XFile file = XFile(f.path);
    Share.shareXFiles([file], subject: explanationText);
  }

  Future<File> localF (filename) async {
    // the downloads folder path
    var tempPath = await getTemporaryDirectory();
    var filePath = '${tempPath.path}/${filename.toString().replaceAll(' ', '_')}';
    return File(filePath).create();

  }

  void generateCSV(csv, String name){
//Now Convert or encode this csv string into utf8
    final bytes = utf8.encode(csv);
//NOTE THAT HERE WE USED HTML PACKAGE
    final blob = html.Blob([bytes]);
//It will create downloadable object
    final url = html.Url.createObjectUrlFromBlob(blob);
//It will create anchor to download the file
    final anchor = html.document.createElement('a')  as    html.AnchorElement..href = url..style.display = 'none'
      ..download = name;
//finally add the csv anchor to body
    html.document.body?.children.add(anchor);
// Cause download by calling this function
    anchor.click();
//revoke the object
    html.Url.revokeObjectUrl(url);

  }
}