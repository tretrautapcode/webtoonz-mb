import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:untitled/controller/global_controller.dart';
import 'package:untitled/model/custom_dio.dart';
import 'package:untitled/widgets/dialog.dart';

class AccountController extends GetxController {
  GlobalController globalController = Get.put(GlobalController());
  RxBool isEditting = true.obs;
  TextEditingController fullName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController age = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    var userInfo = globalController.user.value;
    fullName.text =
        userInfo.fullName != null ? userInfo.fullName.toString() : "";
    phoneNumber.text = userInfo.phone != null ? userInfo.phone.toString() : "";
    age.text = userInfo.age != null ? userInfo.age.toString() : "";
  }

  Future getProfile() async {
    try {
      CustomDio customDio = CustomDio();
      customDio.dio.options.headers["Authorization"] =
          globalController.user.value.certificate.toString();

      var response = await customDio.get("/auth/profile");
      var json = jsonDecode(response.toString());
      return (json["data"]);
    } catch (e, s) {
      print(e);
      return null;
    }
  }

  Future editProfile(BuildContext context) async {
    try {
      CustomDio customDio = CustomDio();
      customDio.dio.options.headers["Authorization"] =
          globalController.user.value.certificate.toString();

      var response = await customDio.put(
          "/user/${globalController.user.value.id}", {
        "fullName": fullName.text,
        "age": age.text,
        "phoneNumber": phoneNumber.text
      });
      var json = jsonDecode(response.toString());
      if (json["success"] == true) {
        globalController.user.value.phone = phoneNumber.text;
        globalController.user.value.age = age.text;
        globalController.user.value.fullName = fullName.text;
      }
      CustomDialog(context, "SUCCESS")
          .show({"message": "Change information successful !"});
      isEditting.value = false;
      return (json["data"]);
    } catch (e, s) {
      CustomDialog(context, "FAILED")
          .show({"message": "Change information failed !"});
      print(e);
      return null;
    }
  }
}
