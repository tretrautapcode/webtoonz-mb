import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../model/custom_dio.dart';
import '../../model/espisode.dart';

class EpisodeDetailController extends GetxController with StateMixin {
  final String episodeId;
  Rx<Episode> episode = Episode().obs;
  RxList comments = List.empty(growable: true).obs;

  EpisodeDetailController({required this.episodeId});

  RxBool seeAll = false.obs;

  @override
  void onInit() async {
    super.onInit();
    change(null, status: RxStatus.loading());
    await getEpisodeDetail();
    await getComments();
    change(null, status: RxStatus.success());
  }

  Future addToCart(int quantity) async {
    try {
      CustomDio customDio = CustomDio();
      var response = await customDio.get("/user/cart");
      response = jsonDecode(response.toString());
      RxList data = List.empty(growable: true).obs;
      data.value = response["data"];
      var requet = {"cartItems": data.value};
      while (quantity > 0) {
        data.add("$episodeId");
        quantity--;
      }

      response = await customDio.put("/user/cart", requet);
      return true;
    } catch (e, s) {
      print(e.toString());
      return false;
    }
  }

  Future getEpisodeDetail() async {
    try {
      CustomDio customDio = CustomDio();
      var response = await customDio.get("/episode/$episodeId");
      response = jsonDecode(response.toString());
      episode.value = Episode.fromJson(response);
      return true;
    } catch (e, s) {
      print(e.toString());
      return false;
    }
  }

  Future getComments() async {
    try {
      CustomDio customDio = CustomDio();
      var response = await customDio.get("/episode/$episodeId/comments");
      response = jsonDecode(response.toString());
      var data = response["data"] ?? [];
      comments.value = data;
      return true;
    } catch (e, s) {
      print(e.toString());
      return false;
    }
  }

  Future addComment(String comment) async {
    try {
      CustomDio customDio = CustomDio();
      var data = {
        "episodeId": episodeId,
        "description": comment,
      };

      var response = await customDio.post(
        "/comment",
        data,
      );
      var json = jsonDecode(response.toString());
      var result = json["data"]["data"];
      return result ?? json;
    } catch (e, s) {
      return null;
    }
  }

  Future addToCard() async {
    try {
      CustomDio customDio = CustomDio();
      var data = {};

      var response = await customDio.post(
        "/user",
        data,
      );
      var json = jsonDecode(response.toString());
      var result = json["data"];
      return result ?? json;
    } catch (e, s) {
      return null;
    }
  }

  Future addToFavorite() async {
    try {
      CustomDio customDio = CustomDio();
      var data = {};

      var response = await customDio.post(
        "/user",
        data,
      );
      var json = jsonDecode(response.toString());
      var result = json["data"];
      return result ?? json;
    } catch (e, s) {
      return null;
    }
  }

  Future like() async {
    try {
      CustomDio customDio = CustomDio();
      var data = {
        "episodeId": episodeId,
      };

      var response = await customDio.post(
        "/like/like",
        data,
      );
      var json = jsonDecode(response.toString());
      var result = json["data"];
      return result ?? json;
    } catch (e, s) {
      return null;
    }
  }

  Future unLike() async {
    try {
      CustomDio customDio = CustomDio();
      var data = {
        "episodeId": episodeId,
      };

      var response = await customDio.post(
        "/like/unlike",
        data,
      );
      var json = jsonDecode(response.toString());
      var result = json["data"];
      return result ?? json;
    } catch (e, s) {
      return null;
    }
  }
}