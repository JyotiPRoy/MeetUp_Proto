import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ms_engage_proto/model/chat.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';
import 'package:ms_engage_proto/ui/widgets/attachment_card.dart';

class AttachmentTray extends StatefulWidget {
  final StreamController<bool> visibilityController;
  final StreamController<List<PlatformFile>> attachmentController;

  const AttachmentTray({
    Key? key,
    required this.visibilityController,
    required this.attachmentController,
  }) : super(key: key);

  @override
  _AttachmentTrayState createState() => _AttachmentTrayState();
}

class _AttachmentTrayState extends State<AttachmentTray> {

  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    widget.visibilityController.stream.listen((val) {
     setState(() {
       _isVisible = val;
     });
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 300
      ),
      height: _isVisible ? 100 : 0,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            child: Divider(
            height: height * 0.02,
            color: AppStyle.darkBorderColor,
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Container(
                width: double.infinity,
                height: 50,
                child: StreamBuilder<List<PlatformFile>>(
                  stream: widget.attachmentController.stream,
                  builder: (context, snapshot){
                    if(snapshot.hasData && snapshot.data != null){
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: snapshot.data!.map((file)
                          => AttachmentCard(
                            onDelete: (file){
                              var attachments = snapshot.data!;
                              attachments.remove(file);
                              widget.attachmentController.add(attachments);
                            },
                            attachmentFile: file,
                            ),
                          ).toList(),
                        ),
                      );
                    }
                    return Container();
                  },
                ),
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 15,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  widget.visibilityController.add(false);
                  await Future.delayed(const Duration(milliseconds: 100));
                  widget.attachmentController.add([]);
                },
                child: Container(
                  height: 20,
                  width: 20,
                  child: Icon(
                    FontAwesomeIcons.times,
                    color: AppStyle.whiteAccent,
                    size: 16,
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
