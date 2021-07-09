import 'package:ms_engage_proto/model/chat.dart';

abstract class DownloadAttachment{
  Future<void> download(ChatAttachment attachment);
}

class DownloadAttachmentMobile implements DownloadAttachment{
  @override
  Future<void> download(ChatAttachment attachment) async {
    // TODO: implement download
  }

}