import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:untitled/controller/global_controller.dart';
import 'package:untitled/controller/home_page/home_page_controller.dart';
import 'package:untitled/screen/home_page/home_page_component.dart';
import 'package:untitled/screen/home_page/search_result_screen.dart';
import 'package:untitled/utils/config.dart';
import 'package:untitled/widgets/app_bar.dart';
import 'package:untitled/widgets/input.dart';

class CreatorHomePageTabScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GlobalController globalController = Get.put(GlobalController());
    HomePageController homePageController = Get.put(HomePageController());
    return Scaffold(
      appBar: appBar(
          title: "Shop name",
          hideBackButton: true,
          centerTitle: true,
          elevation: 1.0,
          actions: [
            SvgPicture.asset(
              "assets/icons/bell.svg",
              width: getWidth(24),
            ),
            SizedBox(
              width: getWidth(20),
            ),
          ]),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: getWidth(20)),
        child: ListView(
          children: [
            SizedBox(
              height: getHeight(25),
            ),
            Container(
              child: inputSearch(
                context,
                hintText: "Search product name",
                textEditingController: homePageController.searchText,
                onSearch: () {
                  if (homePageController.searchText.text != "") {
                    homePageController.search();
                    Get.to(SearchResultScreen());
                  }
                },
                fillColor: 0xFFFAFAFA,
                borderColor: 0xFFFAFAFA,
              ),
            ),
            SizedBox(
              height: getHeight(28),
            ),
            Obx(() {
              return GridView.count(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                primary: false,
                crossAxisSpacing: getWidth(0),
                mainAxisSpacing: getHeight(20),
                crossAxisCount: 2,
                childAspectRatio: 4 / 5.5,
                children: homePageController.seriesList.map((e) {
                  return SeriesItem(
                    seriesInfo: e,
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}