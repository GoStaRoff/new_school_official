import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_school_official/moduls/main/controllers/main_controller.dart';
import 'package:new_school_official/storage/colors/main_color.dart';

import 'list_videos.dart';

class DownloadPage extends StatelessWidget {
  MainController mainController = Get.find();

  GetStorage box = GetStorage();
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white_color,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(top: 0),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding: EdgeInsets.only(
                      left: 22,
                      right: 22,
                      top: 27,
                    ),
                    child: Text(
                      "Мои загрузки",
                      style: TextStyle(
                          fontSize: 25,
                          color: Color(0xff000000),
                          fontWeight: FontWeight.w700,
                          height: 1,
                          fontFamily: "Raleway"),
                    )),
                mainController.downloads == null
                    ? Container(
                        width: Get.width,
                        height: Get.height - 178,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 134,
                              height: 134,
                              padding: EdgeInsets.all(33),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xffF9F9F9)),
                              child:
                                  Image.asset("assets/images/download 1.png"),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              "Пока загрузок нет",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 17,
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Raleway"),
                            ),
                            Text(
                              "Загружайте курсы, чтобы Вы всегда могли обучаться, даже если вы в офлайн.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w300,
                                  fontFamily: "Raleway"),
                            ),
                            !mainController.auth.value
                                ? Text(
                                    "(Доступно при подписке)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 14,
                                        height: 1.5,
                                        fontWeight: FontWeight.w300,
                                        fontFamily: "Raleway"),
                                  )
                                : Container()
                          ],
                        ),
                      )
                    : mainController.auth.value
                        ? Column(children: [
                            SizedBox(
                              height: 36,
                            ),
                            ...mainController.downloads.split("||").map((el) {
                              return GestureDetector(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 61,
                                      width: 93,
                                      margin:
                                          EdgeInsets.only(bottom: 21, left: 20),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.black,
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  "${jsonDecode(el)['image']}"))),
                                    ),
                                    SizedBox(
                                      width: 18,
                                    ),
                                    Container(
                                      height: 61,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${jsonDecode(el)['title']}",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                                fontFamily: "Raleway"),
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                              "Загружено: ${box.read("${jsonDecode(el)['id']}").split("||").length} урока",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300,
                                                  color: Color(0xff6A6A6A),
                                                  fontFamily: "Raleway")),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                onTapDown: (_) {
                                  print(el);
                                  print(jsonDecode(el)['id']);
                                  print(box.read("${jsonDecode(el)['id']}"));
                                  Get.to(ListVideo(
                                      box.read("${jsonDecode(el)['id']}"),
                                      jsonDecode(el)['title']));
                                },
                              );
                            }).toList(),
                          ])
                        : Container(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
