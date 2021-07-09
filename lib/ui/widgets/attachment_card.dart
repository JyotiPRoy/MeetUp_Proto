import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mime/mime.dart';
import 'package:ms_engage_proto/model/chat.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/widgets/chat_card.dart';

class AttachmentCard extends StatefulWidget {
  final void Function(PlatformFile) onDelete;
  final PlatformFile attachmentFile;
  const AttachmentCard({
    Key? key,
    required this.onDelete,
    required this.attachmentFile
  }) : super(key: key);

  @override
  _AttachmentCardState createState() => _AttachmentCardState();
}

class _AttachmentCardState extends State<AttachmentCard> {

  AttachmentType _type = AttachmentType.File;

  @override
  void initState() {
    super.initState();
    _type = AttachmentTypeExtension.fromString(
      lookupMimeType(widget.attachmentFile.name) ?? ''
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 50,
      margin: EdgeInsets.only(right: 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppStyle.whiteAccent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    _type.icon,
                    color: AppStyle.whiteAccent,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 125,
                    child: Text(
                      widget.attachmentFile.name,
                      style: TextStyle(fontSize: 16, color: AppStyle.whiteAccent),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: -5,
            right: -5,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => widget.onDelete.call(widget.attachmentFile),
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: AppStyle.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppStyle.defaultBorderColor
                    )
                  ),
                  child: Center(
                    child: Icon(
                      FontAwesomeIcons.times,
                      color: AppStyle.whiteAccent,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
