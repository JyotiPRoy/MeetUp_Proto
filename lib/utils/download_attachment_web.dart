import 'dart:html' as html;
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:ms_engage_proto/model/chat.dart';
import 'package:ms_engage_proto/utils/download_attachment.dart';

//This had to be done since the import dart:html crashes mobile apps

class DownloadAttachmentWeb implements DownloadAttachment{

  final _storageRef = FirebaseStorage.instance.ref('chatAttachments');

  @override
  Future<void> download(ChatAttachment attachment) async {
    // var blob = html.Blob();
    var fileRef = _storageRef.child(attachment.fileName);
    Uint8List? data = await fileRef.getData();
    if(data != null){
      var blob = html.Blob(data, lookupMimeType(attachment.fileName),);
      var anchorElement = html.AnchorElement(
        href: html.Url.createObjectUrlFromBlob(blob).toString(),
      )..setAttribute("download", attachment.fileName)..click();
    }
  }
}