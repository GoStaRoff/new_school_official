import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_school_official/moduls/auth/views/auth.dart';
import 'package:new_school_official/moduls/home/views/home.dart';
import 'package:new_school_official/moduls/main/views/download_page.dart';
import 'package:new_school_official/moduls/profile/views/profile.dart';
import 'package:new_school_official/moduls/search/views/search_view.dart';
import 'package:new_school_official/moduls/static/views/static_view.dart';
import 'package:new_school_official/service/backend.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs;
  var image = File("1").obs;
  final GetStorage box = GetStorage();
  RxBool auth = true.obs;
  RxList widgets = [].obs;

  RxBool banner = true.obs;

  var profile = {}.obs;

  var phoneEditingController = new TextEditingController();

  var passEditingController = new TextEditingController();

  var getUservideo_cab = [].obs;

  var getUservideo_time = [].obs;

  var getUservideo_time_all = [].obs;

  var getStats = {}.obs;

  var lastnameEditingController = new TextEditingController();

  var nameEditingController = new TextEditingController();

  var passEditEditingController = new TextEditingController();

  var passOldEditingController = new TextEditingController();

  var passConfEditingController = new TextEditingController();

  var emailConfEditEditingController = new TextEditingController();

  var emailEditEditingController = new TextEditingController();

  var password = "".obs;

  var email = "".obs;
  StreamController<dynamic> controller = StreamController<dynamic>();
  Stream stream;

  var listCanselToken = [];
  var listValue = [];

  var downloads;

  var allCourse = [];

  var searchCourse = [].obs;

  var finishedCourses = [].obs;

  var controllerSearch = new TextEditingController();
  var listContCourse = [].obs;

  @override
  void onInit() async {
    super.onInit();
    downloads = box.read("downloads");
    stream = controller.stream;
    stream.listen((value) async {
      CancelToken cancelToken = CancelToken();
      listCanselToken.add(cancelToken);
      await downloadFile(value['url'], value['course_id'], value['course'],
          value['video_id'], value['video'], cancelToken);
    });

    allCourse = (await Backend().getAllCourses()).data['kurses'];
    auth.value = await box.read("auth");
    if (box.read("id") != null) {
      initProfile(box.read("id"));
      Get.appUpdate();
    } else {
      auth.value = auth.value != null ? auth.value : false;
      widgets.value = [
        HomePage(),
        SearchScreen(),
        StaticScreen(),
        DownloadPage(),
        auth.value ? ProfilePage() : AuthPage(),
      ];
    }
  }

  Future initProfile(id) async {
    Backend backend = Backend();
    await Future.wait([
      backend.getFinishedCourses(id),
      backend.getUservideo_time_all(id: id),
      backend.getUservideo_time(id: id),
      backend.getUservideo_cab(id: id),
      backend.getUser(id: id)
    ]);

    if (backend.getFinishedCoursesResponse
        .toString()
        .contains("ended_courses")) {
      finishedCourses
          .addAll(backend.getFinishedCoursesResponse['ended_courses']);
    } else {
      finishedCourses.value = [];
    }
    this.getUservideo_time_all.value = [];
    this.getUservideo_time_all.addAll(
        backend.getUservideoTimeAllResponse['lessons'] != null
            ? backend.getUservideoTimeAllResponse['lessons']
            : []);
    this.getUservideo_time.value = [];
    this.getUservideo_time.addAll(
        backend.getUserVideoTimeResponse['lessons'] != null
            ? backend.getUserVideoTimeResponse['lessons']
            : []);

    profile.value = backend.getUserResponse['clients'][0];
    nameEditingController = new TextEditingController(text: profile['name']);
    lastnameEditingController =
        new TextEditingController(text: profile['lastname']);
    getUservideo_time.forEach((element) {
      if (finishedCourses
              .where((el) => el['course_id'] == element['course_id'])
              .length !=
          0) {
      } else {
        listContCourse.add(element);
      }
    });
    print("listContCourse ${listContCourse}");
    this.getUservideo_cab.value =
        backend.getUserVideoCabResponse['lessons_cabinet'];
    auth.value = auth.value != null ? auth.value : false;
    widgets.value = [
      HomePage(),
      SearchScreen(),
      StaticScreen(),
      DownloadPage(),
      auth.value ? ProfilePage() : AuthPage(),
    ];
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    auth.close();
    controller.close();
    super.onClose();
  }

  void onIndexChanged(input) {
    currentIndex.value = input;
    downloads = box.read("downloads");
  }

  Future downloadFile(
      String url, course_id, cours, video_id, video, cancelToken) async {
    int CTI = listCanselToken.length - 1;
    print(video);
    Dio dio = Dio();
    try {
      var dir = await getApplicationDocumentsDirectory();
      print(dir);
      print('dir');
      listValue.add({
        "rec": 1,
        "total": 1,
        "progress": num.parse((1 / 1).toStringAsFixed(2)),
        "video": course_id.toString() + video_id.toString(),
        "download": true,
        "cancelToken": cancelToken
      });
      var responce = await dio
          .download(url, "${dir.path}/$course_id/$video_id.mp4",
              onReceiveProgress: (rec, total) async {
        listValue[CTI] = {
          "rec": rec,
          "total": total,
          "progress": num.parse((rec / total).toStringAsFixed(2)),
          "video": course_id.toString() + video_id.toString(),
          "download": true,
          "cancelToken": cancelToken
        };
        Get.appUpdate();
        print(listValue);
        if (rec == total) {
          print("finish download file ${dir.path}/$course_id/$video_id.mp4");
          listValue.removeAt(CTI);
          listCanselToken.removeAt(CTI);
          var downloads = box.read("downloads");
          var course = box.read("$course_id");
          if (downloads == null) {
            print(course);
            box.write(
                "downloads",
                jsonEncode({
                  "id": "$course_id",
                  "image": "${cours['banner_small']}",
                  "title": "${cours['topic']}",
                  "desc": "${cours['description']}"
                }));
            if (course == null) {
              box.write(
                  "$course_id",
                  jsonEncode({
                    "id": "$course_id",
                    "image": "${video['video_image']}",
                    "title": "${video['video_name']}",
                    "desc": "${video['video_description']}",
                    "video": "/$course_id/$video_id.mp4"
                  }));
            } else {
              if (course.toString().indexOf("${jsonEncode({
                        "id": "$course_id",
                        "image": "${video['video_image']}",
                        "title": "${video['video_name']}",
                        "desc": "${video['video_description']}",
                        "video": "/$course_id/$video_id.mp4"
                      })}") >=
                  0) {
              } else {
                box.write(
                    "$course_id",
                    '$course||${jsonEncode({
                      "id": "$course_id",
                      "image": "${video['video_image']}",
                      "title": "${video['video_name']}",
                      "desc": "${video['video_description']}",
                      "video": "/$course_id/$video_id.mp4"
                    })}');
                print(box.read("$course_id"));
              }
            }
          } else {
            if (downloads.toString().indexOf("${jsonEncode({
                      "id": "$course_id",
                      "image": "${cours['banner_small']}",
                      "title": "${cours['topic']}",
                      "desc": "${cours['description']}"
                    })}") >=
                0) {
            } else {
              await box.write(
                  "downloads",
                  '$downloads||${jsonEncode({
                    "id": "$course_id",
                    "image": "${cours['banner_small']}",
                    "title": "${cours['topic']}",
                    "desc": "${cours['description']}"
                  })}');
            }
            if (course == null) {
              box.write(
                  "$course_id",
                  jsonEncode({
                    "id": "$course_id",
                    "image": "${video['video_image']}",
                    "title": "${video['video_name']}",
                    "desc": "${video['video_description']}",
                    "video": "/$course_id/$video_id.mp4"
                  }));
            } else {
              if (course.toString().indexOf("${jsonEncode({
                        "id": "$course_id",
                        "image": "${video['video_image']}",
                        "title": "${video['video_name']}",
                        "desc": "${video['video_description']}",
                        "video": "/$course_id/$video_id.mp4"
                      })}") >=
                  0) {
              } else {
                box.write(
                    "$course_id",
                    '$course||${jsonEncode({
                      "id": "$course_id",
                      "image": "${video['video_image']}",
                      "title": "${video['video_name']}",
                      "desc": "${video['video_description']}",
                      "video": "/$course_id/$video_id.mp4"
                    })}');
                print(box.read("$course_id"));
              }
            }
          }
        }
      }, cancelToken: cancelToken);
      print(responce.data);
    } catch (e) {
      print(e);
    }
    print("Download completed");
  }

  getVideo(course) {
    return box.read("$course");
  }

  void onChange(String value) {
    searchCourse.value = [];
    var search = allCourse
        .where((element) =>
            element['topic'].toLowerCase().contains(value.toLowerCase()))
        .toList();
    print(search);
    searchCourse.addAll(search);
    Get.appUpdate();
  }
}
