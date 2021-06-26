import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ms_engage_proto/provider/pexel_img_provider.dart';
import 'package:ms_engage_proto/ui/colors/style.dart';

class DateTimeDisplay extends StatelessWidget {
  const DateTimeDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      height: height * 0.28,
      width: width * 0.48,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: FutureBuilder<String?>(
                future: PexelImageProvider.imageUrl,
                builder: (context, snapshot) {
                  if(snapshot.hasData && snapshot.data != null){
                    return Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: AppStyle.defaultBorderColor,
                          ),
                          image: DecorationImage(
                              image: NetworkImage(snapshot.data!),
                              fit: BoxFit.cover
                          )
                      ),
                    );
                  }
                  return Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: AppStyle.defaultBorderColor,
                        ),
                        color: AppStyle.secondaryColor
                    ),
                  );
                }
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: 3,
                  sigmaY: 3
              ),
              child: Container(
                color: AppStyle.secondaryColor.withOpacity(0.4),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '4 : 17 PM',
                    style: TextStyle(
                        color: AppStyle.whiteAccent,
                        fontSize: 48,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Friday, 25 June 2021',
                    style: TextStyle(
                        color: AppStyle.whiteAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            right: 15,
            top: 15,
            child: Container(
              height: 20,
              width: 20,
              child: Icon(
                Icons.refresh,
                color: AppStyle.whiteAccent.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
