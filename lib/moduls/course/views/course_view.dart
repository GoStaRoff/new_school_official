import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart' as dios;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_school_official/dialog/dialog_payment.dart';
import 'package:new_school_official/dialog/treyler.dart';
import 'package:new_school_official/moduls/auth/views/register.dart';
import 'package:new_school_official/moduls/course/controllers/course_controller.dart';
import 'package:new_school_official/moduls/home/controllers/home_controller.dart';
import 'package:new_school_official/moduls/main/controllers/main_controller.dart';
import 'package:new_school_official/moduls/video/views/video_view.dart';
import 'package:new_school_official/routes/app_pages.dart';
import 'package:new_school_official/service/backend.dart';
import 'package:new_school_official/widgets/speackear.dart';
import 'package:share/share.dart';

class CourseScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateCourse();
  }
}

class StateCourse extends State<CourseScreen> {
  CourseController _courseController = Get.put(CourseController());
  HomeController _homeController = Get.find();
  MainController _mainController = Get.find();
  final GetStorage box = GetStorage();
  var lessonLast;
  var indexLast;

  @override
  void initState() {
    super.initState();
    initPre();
  }

  @override
  void dispose() {
    loadProfile();
    super.dispose();
  }

  loadProfile() async {
    if (_mainController.profile['id'] != null) {
      await _mainController.initProfile(_mainController.profile['id']);
    }
  }

  initPre() async {
    var response = await Backend().getCourse(_courseController.id);
    print(response.headers);
    if (response.statusCode == 200) {
      var statCourse = await Backend().getStatCourse(_courseController.id);
      _homeController.statCourse = statCourse.data[0];
      print(response.data);
      _homeController.course = response.data;
      response = await Backend().getVideos(_courseController.id);
      _homeController.videos = response.data;
      setState(() {});
    }
  }

  String getTitle() {
    if (_mainController.finishedCourses
            .where((element) =>
                element['course_id'] ==
                _homeController.course['kurses'][0]['id'])
            .length >=
        1) {
      return "Курс пройден";
    }
    if (_mainController.auth.value) {
      print(_mainController.getUservideo_time);
      try {
        if (_mainController.getUservideo_time_all.indexWhere(
                (element) => element['course_id'] == lessonLast['kurs_id']) >=
            0) {
          return "Продолжить";
        } else {
          print("auth true");
          return "Начать учиться";
        }
      } catch (E) {
        return "Начать учиться";
      }
    } else {
      return "Начать учиться";
    }
  }

  @override
  Widget build(BuildContext context) {
    var indexInLookLessonPrevius;
    if (_homeController.videos['lessons'] != null) {
      for (int i = 0; i < _homeController.videos['lessons'].length; i++) {
        var indexInLookLesson = _mainController.getUservideo_time_all
            .indexWhere((element) =>
                element['lesson_id'] ==
                _homeController.videos['lessons'].reversed.toList()[i]['id']);
        if (i == 0) {
          lessonLast = _homeController.videos['lessons'].reversed.toList()[i];
          indexLast = i;
        } else {
          if (_mainController.auth.value) {
            if (indexInLookLesson > 0) {
              indexInLookLessonPrevius = _mainController.getUservideo_time_all
                  .indexWhere((element) =>
                      element['lesson_id'] ==
                      _homeController.videos['lessons'].reversed.toList()[i]
                          ['id']);
              if (_mainController.getUservideo_time_all[indexInLookLesson]
                      ['done'] ==
                  0) {
              } else {
                if (indexInLookLessonPrevius < 0) {
                } else {
                  print("+");
                  lessonLast =
                      _homeController.videos['lessons'].reversed.toList()[i];
                  indexLast = i;
                }
              }
            } else {}
          } else {}
        }
      }
    }
    print("indexInLookLessonPrevius ${indexInLookLessonPrevius}");
    return MaterialApp(
        home: Scaffold(
      resizeToAvoidBottomPadding: true,
      body: Container(
        color: Colors.white,
        child: _homeController.videos['lessons'] != null
            ? ListView(
                padding: EdgeInsets.only(bottom: 20),
                children: [
                  Container(
                    width: Get.width,
                    height: 590,
                    child: Stack(
                      children: [
                        Image.network(
                          "${_homeController.course['kurses'][0]['banner_big']}",
                          width: Get.width,
                          height: 590,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            height: Get.width / 1.5,
                            width: Get.width,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                  Colors.black.withOpacity(1),
                                  Colors.black.withOpacity(0)
                                ])),
                          ),
                        ),
                        Positioned(
                            top: 54,
                            left: 10,
                            child: GestureDetector(
                              child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                  child: Opacity(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_back_ios,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        Text(
                                          "Назад",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              height: 1.2,
                                              color: Colors.white,
                                              letterSpacing: 0.5),
                                        )
                                      ],
                                    ),
                                    opacity: 0.8,
                                  )),
                              onTap: () {
                                _homeController.videos = {}.obs;
                                Get.back();
                              },
                            )),
                        Positioned(
                            top: 54,
                            right: 10,
                            child: GestureDetector(
                              child: Container(
                                padding: EdgeInsets.all(5),
                                height: 32,
                                width: 32,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                                child: SvgPicture.asset(
                                    "assets/icons/share-3 1.svg"),
                              ),
                              onTap: () {
                                _mainController.listCanselToken
                                    .forEach((element) {
                                  try {
                                    element.cancel();
                                  } catch (e) {}
                                });
                                Share.share('https://mapus.com.ua/tasks/',
                                    subject: 'Share');
                              },
                            )),
                        Positioned(
                          bottom: 36,
                          right: 32,
                          left: 32,
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Opacity(
                                  child: Text('Пение',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.white,
                                          letterSpacing: 0.5)),
                                  opacity: 0.8,
                                ),
                                Container(
                                  width: Get.width,
                                  child: AutoSizeText(
                                      '${_homeController.course['kurses'][0]['topic']}',
                                      maxLines: 1,
                                      minFontSize: 12,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 21,
                                          letterSpacing: 0.5,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          fontFamily: "Raleway")),
                                ),
                                SizedBox(
                                  height: 17,
                                ),
                                FlatButton(
                                  splashColor: Colors.white.withOpacity(0.6),
                                  padding: EdgeInsets.all(2),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.padded,
                                  highlightColor:
                                      Colors.white.withOpacity(0.24),
                                  child: Container(
                                    height: 41,
                                    width: Get.width,
                                    padding: EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.white)),
                                    child: Center(
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        getTitle() == "Курс пройден"
                                            ? Image.asset(
                                                "assets/icons/Vector.png")
                                            : Container(),
                                        SizedBox(
                                          width: 6,
                                        ),
                                        Text('${getTitle()}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                letterSpacing: 0.5,
                                                fontFamily: "Raleway",
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white)),
                                      ],
                                    )),
                                  ),
                                  onPressed: () async {
                                    await Future.delayed(
                                        Duration(milliseconds: 500));
                                    if (_mainController.auth.value) {
                                      if (_mainController.getUservideo_time
                                              .indexWhere((element) =>
                                                  element['lesson_id'] ==
                                                  lessonLast['id']) >
                                          0) {
                                        await Get.to(VideoScreen(
                                          lessonLast,
                                          index: indexLast,
                                          duration: int.tryParse(_mainController
                                                  .getUservideo_time[
                                              _mainController.getUservideo_time
                                                  .indexWhere((element) =>
                                                      element['lesson_id'] ==
                                                      lessonLast[
                                                          'id'])]['time']),
                                        ));
                                        SystemChrome
                                            .setEnabledSystemUIOverlays([
                                          SystemUiOverlay.bottom,
                                          SystemUiOverlay.top
                                        ]);
                                        SystemChrome.setSystemUIOverlayStyle(
                                            SystemUiOverlayStyle(
                                                statusBarColor: Colors.white,
                                                statusBarIconBrightness:
                                                    Brightness.dark,
                                                statusBarBrightness:
                                                    Brightness.dark,
                                                systemNavigationBarColor:
                                                    Colors.white));
                                        SystemChrome.setPreferredOrientations([
                                          DeviceOrientation.portraitUp,
                                        ]);
                                        setState(() {});
                                      } else {
                                        await Get.to(VideoScreen(lessonLast,
                                            index: indexLast));
                                        StreamController<int> controller =
                                            StreamController<int>();
                                        Stream stream = controller.stream;
                                        stream.listen((value) async {
                                          dios.Response getUservideo_time_all =
                                              await Backend()
                                                  .getUservideo_time_all(
                                                      id: box.read('id'));

                                          setState(() {
                                            _mainController
                                                .getUservideo_time_all
                                                .value = [];
                                            _mainController
                                                .getUservideo_time_all
                                                .addAll(getUservideo_time_all
                                                    .data['lessons']);
                                            if (box.read('id') != null) {
                                              _mainController
                                                  .initProfile(box.read("id"));
                                            }
                                          });
                                        });
                                        controller.add(1);
                                        SystemChrome
                                            .setEnabledSystemUIOverlays([
                                          SystemUiOverlay.bottom,
                                          SystemUiOverlay.top
                                        ]);
                                        SystemChrome.setSystemUIOverlayStyle(
                                            SystemUiOverlayStyle(
                                                statusBarColor: Colors.white,
                                                statusBarIconBrightness:
                                                    Brightness.dark,
                                                statusBarBrightness:
                                                    Brightness.dark,
                                                systemNavigationBarColor:
                                                    Colors.white));
                                        SystemChrome.setPreferredOrientations([
                                          DeviceOrientation.portraitUp,
                                        ]);

                                        setState(() {});
                                      }
                                    } else {
                                      await Get.to(VideoScreen(
                                          _homeController
                                              .videos['lessons'].reversed
                                              .toList()[0],
                                          index: 0));
                                      StreamController<int> controller =
                                          StreamController<int>();
                                      Stream stream = controller.stream;
                                      stream.listen((value) async {
                                        await _mainController
                                            .initProfile(box.read('id'));
                                        setState(() {});
                                      });
                                      controller.add(1);
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Opacity(
                                  opacity: 0.8,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/play-button-arrowhead-4 1.svg",
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 7,
                                            ),
                                            Text("Смотреть трейлер",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w300,
                                                    fontFamily: "Raleway",
                                                    letterSpacing: 0.5,
                                                    color: Colors.white))
                                          ],
                                        ),
                                        onTap: () async {
                                          await Get.to(TrailerScreen());
                                          SystemChrome
                                              .setEnabledSystemUIOverlays([
                                            SystemUiOverlay.bottom,
                                            SystemUiOverlay.top
                                          ]);
                                          SystemChrome.setSystemUIOverlayStyle(
                                              SystemUiOverlayStyle(
                                                  statusBarColor: Colors.white,
                                                  statusBarIconBrightness:
                                                      Brightness.dark,
                                                  statusBarBrightness:
                                                      Brightness.dark,
                                                  systemNavigationBarColor:
                                                      Colors.white));
                                          SystemChrome
                                              .setPreferredOrientations([
                                            DeviceOrientation.portraitUp,
                                          ]);
                                          setState(() {});
                                        },
                                      ),
                                      _mainController.auth.value
                                          ? SizedBox(
                                              width: 25,
                                            )
                                          : Container(),
                                      _mainController.auth.value
                                          ? GestureDetector(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    "assets/icons/Layer 16.svg",
                                                    height: 15,
                                                    width: 15,
                                                  ),
                                                  SizedBox(
                                                    width: 7,
                                                  ),
                                                  Text(
                                                    "Загрузить",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontFamily: "Raleway",
                                                        letterSpacing: 0.5,
                                                        color: Colors.white),
                                                  )
                                                ],
                                              ),
                                              onTapDown: (_) {
                                                _homeController
                                                    .videos['lessons'].reversed
                                                    .toList()
                                                    .forEach((el) {
                                                  print(
                                                      "${_homeController.course['kurses'][0]}");
                                                  _mainController.controller
                                                      .add({
                                                    "url":
                                                        "${el['videos'][0]['video_url']}",
                                                    "course_id":
                                                        "${el['kurs_id']}",
                                                    "video_id": "${el['id']}",
                                                    "course":
                                                        "${_homeController.course['kurses'][0]}",
                                                    "video": "${el}"
                                                  });
                                                });
                                              },
                                            )
                                          : Container()
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(() {
                    int i = -1;
                    return Container(
                      margin: EdgeInsets.only(top: 22, bottom: 41),
                      height: 210,
                      width: Get.width,
                      child: ListView(
                          padding: EdgeInsets.only(left: 15),
                          scrollDirection: Axis.horizontal,
                          children: [
                            Row(children: [
                              ..._homeController.videos['lessons'].reversed
                                  .toList()
                                  .map((el) {
                                i += 1;
                                if (getTitle() == "Курс пройден") {
                                  return Stack(children: [
                                    Item(
                                        _homeController
                                            .videos['lessons'].reversed
                                            .toList()[i],
                                        true,
                                        _homeController,
                                        _mainController,
                                        i,
                                        false,
                                        look: true),
                                    Positioned(
                                        bottom: 80,
                                        right: 24,
                                        child: SvgPicture.asset(
                                          "assets/icons/Vector (8).svg",
                                          width: 13,
                                          height: 16,
                                        )),
                                  ]);
                                }
                                if (indexLast == 0 && i == 0) {
                                  return Item(
                                      _homeController.videos['lessons'].reversed
                                          .toList()[i],
                                      true,
                                      _homeController,
                                      _mainController,
                                      i,
                                      false);
                                } else {
                                  if (i <= indexLast) {
                                    return Stack(children: [
                                      Item(
                                        _homeController
                                            .videos['lessons'].reversed
                                            .toList()[i],
                                        true,
                                        _homeController,
                                        _mainController,
                                        i,
                                        false,
                                        look: true,
                                      ),
                                      Positioned(
                                          bottom: 80,
                                          right: 24,
                                          child: SvgPicture.asset(
                                            "assets/icons/Vector (8).svg",
                                            width: 13,
                                            height: 16,
                                          )),
                                    ]);
                                  } else {
                                    if (i - 1 == indexLast && indexLast != 0) {
                                      return Item(
                                          _homeController
                                              .videos['lessons'].reversed
                                              .toList()[i],
                                          true,
                                          _homeController,
                                          _mainController,
                                          i,
                                          false);
                                    }
                                  }
                                }
                                return Stack(children: [
                                  Item(
                                      _homeController.videos['lessons'].reversed
                                          .toList()[i],
                                      false,
                                      _homeController,
                                      _mainController,
                                      i,
                                      false),
                                  Positioned(
                                      bottom: 80,
                                      right: 24,
                                      child: Image.asset(
                                        "assets/images/padlock 1.png",
                                        width: 13,
                                        height: 16,
                                      )),
                                ]);
                              }).toList(),
                            ]),
                            _courseController.statTest != null
                                ? Stack(children: [
                                    GestureDetector(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 142,
                                            width: 216,
                                            child: Stack(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      right: 12),
                                                  height: 142,
                                                  width: 216,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      color: Colors.black
                                                          .withOpacity(0.04),
                                                      image: DecorationImage(
                                                          image: NetworkImage(
                                                              _homeController
                                                                          .course[
                                                                      'kurses'][0]
                                                                  ['banner_small']),
                                                          fit: BoxFit.cover)),
                                                ),
                                                Positioned(
                                                  top: 10,
                                                  left: 12,
                                                  child: Text(
                                                    "ТЕСТ",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.white,
                                                        fontFamily: "Raleway"),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  child: Container(
                                                    height: 50,
                                                    width: 196,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                        gradient: LinearGradient(
                                                            begin: Alignment
                                                                .bottomCenter,
                                                            end: Alignment
                                                                .topCenter,
                                                            colors: [
                                                              Colors.black
                                                                  .withOpacity(
                                                                      1),
                                                              Colors.black
                                                                  .withOpacity(
                                                                      0)
                                                            ])),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 9),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [],
                                            ),
                                          )
                                        ],
                                      ),
                                      onTapDown: (_) {
                                        print("wae");
                                        if (_mainController
                                                .getUservideo_time_all
                                                .indexWhere((element) =>
                                                    element['lesson_id'] ==
                                                    _homeController
                                                        .videos['lessons']
                                                        .reversed
                                                        .toList()[i]['id']) <
                                            0) {
                                          Get.snackbar(null, null,
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              colorText: Colors.redAccent,
                                              messageText: Center(
                                                child: Text(
                                                  "Нужно посмотреть все уроки",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily: "Raleway",
                                                      letterSpacing: 0.5,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.redAccent),
                                                ),
                                              ));
                                        } else
                                          Get.toNamed(Routes.TEST);
                                      },
                                    ),
                                    Positioned(
                                        bottom: 80,
                                        left: 12,
                                        child: Text(
                                          "${_courseController.length} вопросов",
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                              fontFamily: "Raleway"),
                                        )),
                                    getTitle() == "Курс пройден"
                                        ? Positioned(
                                            bottom: 80,
                                            right: 24,
                                            child: SvgPicture.asset(
                                              "assets/icons/Vector (8).svg",
                                              width: 13,
                                              height: 16,
                                            ))
                                        : _mainController.getUservideo_time_all
                                                    .indexWhere((element) =>
                                                        element['lesson_id'] ==
                                                        _homeController
                                                            .videos['lessons']
                                                            .reversed
                                                            .toList()[i]['id']) <
                                                0
                                            ? Positioned(
                                                bottom: 80,
                                                right: 24,
                                                child: Image.asset(
                                                  "assets/images/padlock 1.png",
                                                  width: 13,
                                                  height: 16,
                                                ))
                                            : Container(),
                                  ])
                                : Container()
                          ]),
                    );
                  }),
                  getMeterial(_homeController, _mainController),
                  getMDescription(_homeController),
                  getStatistik(),
                  getSpickers(_homeController)
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    ));
  }

  Widget getMeterial(_homeController, _mainController) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 41),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Материалы",
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: Colors.black,
                  fontFamily: "Raleway")),
          SizedBox(
            height: 13,
          ),
          ..._homeController.course['kurses'][0]['materials']
              .map((el) => GestureDetector(
                    onTap: () {
                      print(el);
                    },
                    child: Container(
                      padding: EdgeInsets.only(bottom: 5),
                      margin: EdgeInsets.only(bottom: 17),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 1, color: Color(0xffECECEC)))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${el['material_name']}",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 0.5,
                                  color: Colors.black,
                                  fontFamily: "Raleway")),
                          _mainController.auth.value
                              ? SvgPicture.asset(
                                  "assets/icons/down-arrow 1.svg")
                              : Image.asset(
                                  "assets/images/padlock 1_grey.png",
                                  height: 16,
                                  width: 16,
                                )
                        ],
                      ),
                    ),
                  ))
              .toList()
        ],
      ),
    );
  }

  Widget getMDescription(_homeController) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Описание",
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: Colors.black,
                  fontFamily: "Raleway")),
          SizedBox(
            height: 4,
          ),
          Container(
            padding: EdgeInsets.only(bottom: 5),
            child: Text(
                "${_homeController.course['kurses'][0]['description_short']}",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                    height: 1.5,
                    color: Colors.black,
                    fontFamily: "Raleway")),
          ),
        ],
      ),
    );
  }

  Widget getStatistik() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(width: 1, color: Color(0xffECECEC))),
      height: 95,
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 71),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${_homeController.statCourse['lessons_count']}",
                  style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Colors.black,
                      fontFamily: "Raleway")),
              SizedBox(
                height: 2,
              ),
              Text("Уроков",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                      color: Colors.black,
                      fontFamily: "Raleway"))
            ],
          ),
          // SizedBox(width:50,),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${_homeController.statCourse['minutes_count']}",
                  style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Colors.black,
                      fontFamily: "Raleway")),
              SizedBox(
                height: 2,
              ),
              Text("Минут",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                      color: Colors.black,
                      fontFamily: "Raleway"))
            ],
          ),
          // SizedBox(width:50,),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${_homeController.statCourse['tests_count']}",
                  style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Colors.black,
                      fontFamily: "Raleway")),
              SizedBox(
                height: 2,
              ),
              Text("Тест",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                      color: Colors.black,
                      fontFamily: "Raleway"))
            ],
          )
        ],
      ),
    );
  }

  Widget getSpickers(_homeController) {
    return Container(
        margin: EdgeInsets.only(left: 18, bottom: 57),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Спикеры",
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Colors.black,
                    fontFamily: "Raleway")),
            SizedBox(height: 23),
            Container(
              width: Get.width,
              height: 194,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [getSpicker(_homeController)],
              ),
            )
          ],
        ));
  }

  Widget getSpicker(_homeController) {
    return Container(
      width: 175,
      child: Column(children: [
        GestureDetector(
          onTap: () {
            Get.bottomSheet(SpeakerDialog(), isScrollControlled: true);
          },
          child: Container(
            height: 135,
            width: 135,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.04),
                image: DecorationImage(
                    image: NetworkImage(
                        "${_homeController.course['kurses'][0]['spicker_image']}"),
                    fit: BoxFit.cover)),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        GestureDetector(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("${_homeController.course['kurses'][0]['spicker_name']}",
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Colors.black,
                      fontFamily: "Raleway")),
              SizedBox(
                height: 3,
              ),
              Container(
                child: AutoSizeText("Подробнее",
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                        color: Colors.black,
                        fontFamily: "Raleway")),
              )
            ],
          ),
          onTap: () {
            Get.bottomSheet(SpeakerDialog(), isScrollControlled: true);
          },
        )
      ]),
    );
  }
}

class Item extends StatefulWidget {
  var homeController;
  var lock;
  var index;
  var mainController;
  var lesson;
  bool donSee;
  var lessonLast;
  var indexLast;
  bool look;

  Item(this.lesson, this.lock, this.homeController, this.mainController,
      this.index, this.donSee,
      {this.lessonLast, this.indexLast, this.look});

  @override
  State<StatefulWidget> createState() {
    return StateItem();
  }
}

class StateItem extends State<Item> {
  var _image;
  bool _loading = true;

  var length;

  var value;

  var video;

  GetStorage box = GetStorage();

  MainController _mainController = Get.find();

  @override
  void initState() {
    length = widget.mainController.listCanselToken.length;

    _image = new NetworkImage(
      '${widget.lesson['video_image']}',
    );
    _image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (info, call) {
          if (mounted) {
            setState(() {
              _loading = false;
            });
          }
        },
      ),
    );
    video = {
      "url": "${widget.lesson['videos'][0]['video_url']}",
      "course_id": "${widget.lesson['kurs_id']}",
      "course": widget.homeController.course['kurses'][0],
      "video_id": "${widget.lesson['id']}",
      "video": widget.lesson
    };
    print(_mainController.listValue);
    print('listvalue');
  }

  @override
  Widget build(BuildContext context) {
    print("reload");
    return _loading
        ? Container(
            margin: EdgeInsets.only(right: 12),
            height: 142,
            width: 216,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.black.withOpacity(0.04),
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                child: Container(
                  height: 142,
                  width: 216,
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 12),
                        height: 142,
                        width: 216,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.black.withOpacity(0.04),
                            image: DecorationImage(
                                image: _image, fit: BoxFit.cover)),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          height: 50,
                          width: 196,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(1),
                                    Colors.black.withOpacity(0)
                                  ])),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () async {
                  if (widget.donSee) {
                    print(widget.lessonLast);
                    // await Get.dialog(VideoScreen(widget.lessonLast,index:widget.indexLast));
                    Get.snackbar(null, null,
                        snackPosition: SnackPosition.BOTTOM,
                        colorText: Colors.redAccent,
                        messageText: Center(
                          child: Text(
                            "Нужно посмотреть предыдущий урок",
                            style: TextStyle(
                                fontSize: 12,
                                fontFamily: "Raleway",
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent),
                          ),
                        ));
                  } else {
                    if (widget.lock) {
                      print(widget.lesson);
                      print(widget.index);
                      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
                      await Get.to(
                          VideoScreen(widget.lesson, index: widget.index));
                      StreamController<int> controller =
                          StreamController<int>();
                      Stream stream = controller.stream;
                      stream.listen((value) async {
                        await widget.mainController.initProfile(box.read('id'));
                        setState(() {});
                      });
                      controller.add(1);
                    } else {
                      if (widget.mainController.auth.value) {
                        if (widget.mainController.profile['subscriber'] ==
                            '1') {
                          Get.snackbar(null, null,
                              snackPosition: SnackPosition.BOTTOM,
                              colorText: Colors.redAccent,
                              messageText: Center(
                                child: Text(
                                  "Нужно посмотреть предыдущий урок",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: "Raleway",
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.redAccent),
                                ),
                              ));
                        } else {
                          Get.to(
                              Payment(
                                subscriber: '0',
                              ),
                              duration: Duration());
                        }
                      } else {
                        Get.to(RegisterPage(true), duration: Duration());
                      }
                    }
                  }
                },
              ),
              Container(
                margin: EdgeInsets.only(top: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: !widget.lock
                          ? 0.6
                          : widget.look != null
                              ? 0.6
                              : 1,
                      child: Container(
                        width: 190,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              "${widget.lesson['video_name']}",
                              minFontSize: 11,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: "Raleway",
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            AutoSizeText(
                              "${widget.lesson['video_description']}",
                              minFontSize: 8,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.black,
                                  fontFamily: "Raleway",
                                  fontStyle: FontStyle.normal),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Obx(() => _mainController.auth.value
                        ? widget.lock
                            ? _mainController.listValue
                                        .where((el) =>
                                            el["video"] ==
                                            video['course_id'].toString() +
                                                video['video_id'].toString())
                                        .toList()
                                        .length <=
                                    0
                                ? GestureDetector(
                                    child: SvgPicture.asset(
                                      "assets/icons/Layer 16.svg",
                                      color: Colors.black,
                                      width: 14,
                                      height: 14,
                                    ),
                                    onTapDown: (_) {
                                      _mainController.controller.add(video);
                                    },
                                  )
                                : GestureDetector(
                                    child: Container(
                                      width: 20.0,
                                      height: 20.0,
                                      child: Stack(children: [
                                        CircularProgressIndicator(
                                          value: _mainController.listValue
                                              .where((el) =>
                                                  el["video"] ==
                                                  video['course_id']
                                                          .toString() +
                                                      video['video_id']
                                                          .toString())
                                              .toList()[0]['progress'],
                                          backgroundColor: Color(0xFFF9F9F9F9),
                                          strokeWidth: 1.5,
                                        ),
                                        Center(
                                          child: Container(
                                            height: 7.5,
                                            width: 7.5,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ]),
                                    ),
                                    onTapDown: (_) {},
                                  )
                            : Container()
                        : Container())
                  ],
                ),
              )
            ],
          );
  }
}
