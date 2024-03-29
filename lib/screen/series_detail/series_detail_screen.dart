import 'dart:convert';
import 'dart:math';

import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:sizer/sizer.dart';
import 'package:untitled/controller/series_detail/series_detail_controller.dart';
import 'package:untitled/model/Serie.dart';
import 'package:untitled/screen/episode_detail/episode_detail_screen.dart';
import 'package:untitled/screen/series_detail/episode_card.dart';
import 'package:untitled/screen/series_detail/search_episodes.dart';
import 'package:untitled/utils/config.dart';
import 'package:untitled/widgets/image.dart';

import '../../controller/edit_series/edit_series_controller.dart';
import '../../controller/episode_detail/episode_detail_controller.dart';
import '../../controller/home_page/home_page_controller.dart';
import '../../main.dart';
import '../../model/custom_dio.dart';
import '../create_episode/create_episode_screen.dart';
import '../edit_series/edit_series_screen.dart';

class SeriesDetailScreen extends StatelessWidget {
  final String serieId;
  final SerieDetailController controller = Get.put(SerieDetailController());

  SeriesDetailScreen({Key? key, required this.serieId}) : super(key: key);

  Future<Series> fetchSerie(String serieId) async {
    try {
      CustomDio customDio = CustomDio();
      customDio.dio.options.headers["Authorization"] =
          globalController.user.value.certificate.toString();
      var response = await customDio
          .get("/serie/$serieId?page=1&limit=${controller.limit}");
      response = jsonDecode(response.toString());
      if (response["code"] != 200) return Series();
      var serieData = response["data"];
      var serieEpisodes = List.generate(
          serieData["episodes"].length,
          (index) => SeriesEpisode(
              serieData["episodes"][index]["name"],
              serieData["episodes"][index]["thumbnail"],
              serieData["episodes"][index]["price"],
              serieData["episodes"][index]["likeInit"],
              serieData["episodes"][index]["comments"],
              serieData["episodes"][index]["episodeId"],
              serieData["episodes"][index]["chapter"]));
      controller.initialize(
          serieEpisodes, serieData["serieId"], serieData["isPublished"]);
      var seriesInfo = Series.fullParam(
        serieData["serieName"],
        serieData["description"],
        serieData["thumbnail"],
        serieData["cover"],
        serieData["totalEpisodes"],
        serieData["likes"],
        serieData["categoryId"],
        serieData["category"]["categoryName"],
        serieData["creatorInfo"]["fullName"],
        serieData["creatorInfo"]["avatar"],
        serieData["serieId"],
      );
      return seriesInfo;
    } catch (e) {
      print(e);
      return Series();
    }
  }

  @override
  Widget build(BuildContext context) {
    double coverImageBottomPadding = 30;
    double imageHeight =
        MediaQuery.of(context).orientation == Orientation.portrait ? 30 : 40;
    double sidePadding = 5;
    double authorAvatarWidth = 10;
    double descriptionFontSize = 10;
    double statusFontSize = 10;
    double categoryFontSize = 9;
    double authorTitleFontSize = 15;

    return FutureBuilder<Series>(
        future: fetchSerie(serieId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasData)
              return Text("No data");
            else {
              controller.seriesInfo.value = snapshot.data!;
              var ratio =
                  controller.seriesInfo.value.totalEpisodes! / controller.limit;
              var numberOfPages =
                  ratio > ratio.floor() ? ratio.floor() + 1 : ratio.floor();
              numberOfPages = max(numberOfPages, 1);
              return Scaffold(
                floatingActionButton: _buttons(controller.seriesInfo.value),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                // appBar: appBar(
                //     title: controller.seriesInfo.value.serieName,
                //     centerTitle: true,
                //     actions: <Widget>[
                //       new IconButton(
                //         icon: new Icon(Icons.search, color: Colors.black),
                //         onPressed: () {
                //           Get.to(() => SearchEpisodeScreen());
                //         },
                //       )
                //     ]),

                appBar: AppBar(
                    backgroundColor: Colors.white,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                        size: getHeight(20),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    centerTitle: true,
                    elevation: 0,
                    title: Obx(() => Text(
                          controller.seriesInfo.value.serieName,
                          style: TextStyle(
                            fontSize: getHeight(18),
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3669C9),
                          ),
                        )),
                    actions: <Widget>[
                      new IconButton(
                        icon: new Icon(Icons.search, color: Colors.black),
                        onPressed: () {
                          Get.to(() => SearchEpisodeScreen());
                        },
                      )
                    ]),
                body: Container(
                  color: Colors.white,
                  child: ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.only(bottom: coverImageBottomPadding),
                        child: Container(
                          color: Colors.black,
                          child: Obx(() => Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  getImage(controller.seriesInfo.value.cover,
                                      height: imageHeight.h, fit: BoxFit.cover),
                                ],
                              )),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: sidePadding.w, right: sidePadding.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  RichText(
                                      text: TextSpan(
                                          style: TextStyle(color: Colors.black),
                                          children: [
                                        TextSpan(
                                            text:
                                                '${controller.seriesInfo.value.totalEpisodes} items  |  ',
                                            style: TextStyle(
                                                fontSize: statusFontSize.sp)),
                                        WidgetSpan(
                                            child: SvgPicture.asset(
                                          'assets/icons/heart.svg',
                                          width: statusFontSize.sp,
                                        )),
                                        TextSpan(
                                            text:
                                                ' ${controller.seriesInfo.value.totalLikes}',
                                            style: TextStyle(
                                                fontSize: statusFontSize.sp))
                                      ])),
                                  Container(
                                      width: statusFontSize.sp,
                                      child: Icon(Icons.share_sharp))
                                ],
                              ),
                            ),
                            Obx(() => Text(
                                  controller.seriesInfo.value.category!,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: categoryFontSize.sp),
                                )),
                            Container(
                              child: Container(
                                height: 50,
                                child: Center(
                                  child: CustomPaint(
                                    painter: DrawDashLine(),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 3.h),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(right: 2.w),
                                    child: Container(
                                      width: authorAvatarWidth.w,
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(controller
                                            .seriesInfo.value.authorAvatar!),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    controller.seriesInfo.value.authorName!,
                                    style: TextStyle(
                                        fontSize: authorTitleFontSize.sp),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Obx(() => ExpandableText(
                                      controller.seriesInfo.value.description,
                                      style: TextStyle(
                                          fontSize: descriptionFontSize.sp),
                                      expandText: 'show more',
                                      collapseText: 'show less',
                                      maxLines: 6,
                                      linkColor: Colors.blue,
                                    ))),
                            Obx(() => GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: controller.episodes.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () async {
                                        var episodeDetailController =
                                            EpisodeDetailController(
                                                episodeId: controller
                                                    .episodes[index].episodeId);
                                        await episodeDetailController.getApi();
                                        Get.to(() => EpisodeDetailScreen(
                                            controller:
                                                episodeDetailController));
                                      },
                                      child: EpisodeCard(
                                          episode: controller.episodes[index]),
                                    );
                                  },
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 0,
                                          mainAxisSpacing: 0,
                                          childAspectRatio: 4 / 5.7),
                                )),
                            NumberPaginator(
                              numberPages: numberOfPages,
                              initialPage: 0,
                              onPageChange: (index) {
                                controller.getEpisodes(serieId, index + 1);
                              },
                              buttonShape: CircleBorder(
                                  side: BorderSide(
                                      width: 1, color: Colors.transparent)),
                              buttonSelectedForegroundColor: Colors.white,
                              buttonSelectedBackgroundColor: Colors.blue,
                              buttonUnselectedForegroundColor: Colors.black,
                              buttonUnselectedBackgroundColor: Colors.white,
                            ),
                            Obx(() {
                              if (globalController.user.value.role ==
                                  "creator") {
                                return SizedBox(height: getWidth(130));
                              }
                              return Container();
                            })
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          } else if (snapshot.hasError)
            return Column(
              children: [
                Text(
                  snapshot.error.toString(),
                ),
              ],
            );
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Widget _buttons(Series seriesInfo) {
    return Obx(() {
      if (globalController.user.value.role == "creator") {
        return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 7,
                  offset: Offset(0, 1), // changes position of shadow
                ),
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            width: double.infinity,
            height: getWidth(130),
            padding: EdgeInsets.only(top: getWidth(10)),
            child: SizedBox(
                height: getWidth(130),
                child: Column(children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          minimumSize: Size(
                            getWidth(142),
                            getWidth(47),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(getWidth(15))),
                              side: BorderSide(color: Colors.black)),
                        ),
                        onPressed: () {
                          var editSeriesController = Get.put(
                              EditSeriesController(serieData: seriesInfo));
                          Get.to(() => EditSeriesScreen(
                                controller: editSeriesController,
                              ));
                        },
                        child: Text(
                          "Edit series",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: getWidth(13),
                          ),
                        ),
                      ),
                      SizedBox(width: getWidth(17)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF3669C9),
                          minimumSize: Size(
                            getWidth(142),
                            getWidth(47),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(getWidth(15))),
                          ),
                        ),
                        onPressed: () {
                          Get.to(() => CreateEpisodeScreen(seriesId: serieId));
                        },
                        child: Text(
                          "Create episode",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: getWidth(13),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: getWidth(13.6)),
                  Obx(() {
                    if (controller.episodes.length > 0) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              minimumSize: Size(
                                getWidth(302),
                                getWidth(47),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(getWidth(15))),
                                  side: BorderSide(color: Colors.black)),
                            ),
                            onPressed: () async {
                              controller.isChangingStatus.value = true;
                              await controller.changeStatus();
                              controller.isChangingStatus.value = false;
                            },
                            child: Obx(() {
                              if (controller.isChangingStatus.value == true)
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              if (controller.isPublished.value == true) {
                                return Text(
                                  "Unpublish series",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: getWidth(13),
                                  ),
                                );
                              }
                              return Text(
                                "Publish series",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: getWidth(13),
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            minimumSize: Size(
                              getWidth(142),
                              getWidth(47),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(getWidth(15))),
                                side: BorderSide(color: Colors.black)),
                          ),
                          onPressed: () async {
                            controller.isChangingStatus.value = true;
                            await controller.changeStatus();
                            controller.isChangingStatus.value = false;
                          },
                          child: Obx(() {
                            if (controller.isChangingStatus.value == true)
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            if (controller.isPublished.value == true) {
                              return Text(
                                "Unpublish series",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: getWidth(13),
                                ),
                              );
                            }
                            return Text(
                              "Publish series",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: getWidth(13),
                              ),
                            );
                          }),
                        ),
                        SizedBox(width: getWidth(17)),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFF3669C9),
                            minimumSize: Size(
                              getWidth(142),
                              getWidth(47),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(getWidth(15))),
                            ),
                          ),
                          onPressed: () async {
                            controller.isDeleting.value = true;
                            // var result={
                            //   "success":true,
                            // };
                            // await Future.delayed(Duration(seconds: 2));
                            var result = await controller.deleteSeries();
                            controller.isDeleting.value = false;
                            print(result["success"]);
                            if (result["success"] == true) {
                              await Get.put(HomePageController()).getSeries();
                              Get.back();
                              Get.snackbar(
                                "Delete series ${seriesInfo.serieName}",
                                "Success",
                                icon: Icon(Icons.done_outlined,
                                    color: Colors.white),
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.green,
                                borderRadius: 20,
                                margin: EdgeInsets.all(15),
                                colorText: Colors.white,
                                duration: Duration(seconds: 2),
                                isDismissible: true,
                                forwardAnimationCurve: Curves.easeOutBack,
                              );
                              return;
                            }
                            Get.snackbar(
                              "Delete series ${seriesInfo.serieName}",
                              "Failed",
                              icon: Icon(Icons.sms_failed, color: Colors.white),
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red,
                              borderRadius: 20,
                              margin: EdgeInsets.all(15),
                              colorText: Colors.white,
                              duration: Duration(seconds: 2),
                              isDismissible: true,
                              forwardAnimationCurve: Curves.easeOutBack,
                            );
                          },
                          child: Obx(() {
                            if (controller.isDeleting.value == false)
                              return Text(
                                "Delete series",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: getWidth(13),
                                ),
                              );
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }),
                        ),
                      ],
                    );
                  }),
                ])));
      }
      return Container();
    });
  }
}

class DrawDashLine extends CustomPainter {
  Paint _paint = Paint();

  DrawDashLine() {
    //_paint = Paint();
    _paint.color = Colors.grey; //dots color
    _paint.strokeWidth = 2; //dots thickness
    _paint.strokeCap = StrokeCap.square; //dots corner edges
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (double i = -300; i < 300; i = i + 15) {
      // 15 is space between dots
      if (i % 3 == 0)
        canvas.drawLine(Offset(i, 0.0), Offset(i + 10, 0.0), _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
