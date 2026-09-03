import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

typedef ResponseCallback<R, E> = void Function(R response, E error);

const emailPattern =
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

const sendTransition = Transition.rightToLeft;
const backTransition = Transition.leftToRight;

/*sharedPrefKey start*/
const String keyUserId = "keyUserId";
const String keySortBy = "keySortBy";
const String keyUserName = "keyUserName";
const String keyUserType = "keyUserType";
const String keyJwtToken = "keyJwtToken";
const String keyRefreshToken = "keyRefreshToken";
const String keyUserMail = 'keyUserMail';
const String keyUserImage = 'keyUserImage';
/*sharedPrefKey end*/

const dblToDBl = "dblToDBl";
const npsb = "npsb";
const eftn = "eftn";
const mfs = "mfs";

void closeSoftKeyBoard() {
  FocusManager.instance.primaryFocus?.unfocus();
}




/*Future<bool> isInternetConnected(BuildContext context,
    {bool isShowAlert = false}) async {
  bool isConnected = false;

  try {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      isConnected = true;
    }
  } catch (_) {}

  if (isShowAlert && !isConnected) {
    showMessage("Internet Connectivity Problem");
  }

  return isConnected;
}*/

Future<bool> isInternetConnected(BuildContext context,
    {bool isShowAlert = false}) async {
  bool isConnected = false;

  try {
    // First check if connected to network
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {

      // Now verify actual internet by making a real request
      try {
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 5));

        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          isConnected = true;
        }
      } on SocketException catch (_) {
        isConnected = false;
      } on TimeoutException catch (_) {
        isConnected = false;
      }
    }
  } catch (_) {
    isConnected = false;
  }

  if (isShowAlert && !isConnected) {
    showMessage("Internet Connectivity Problem");
  }

  return isConnected;
}



void dismissLoading({bool isFormLoading = false}) {
  EasyLoading.dismiss();
}

void showMessage(
  String? value, {
  bool isToast = false,
  bool isInfo = false,
  bool isMessage = false,
  Duration errorDuration = const Duration(seconds: 5),
}) {
  if (isInfo) {
    EasyLoading.showInfo("$value");
  } else if (isToast) {
    EasyLoading.showSuccess("$value");
  } else if (isMessage) {
    EasyLoading.showToast("$value");
  } else {
    dismissLoading();
    EasyLoading.showError(
      "$value",
      duration: errorDuration,
      dismissOnTap: true,
    );
  }
}

void showAlertDialog(String title, String body, String confirmButtonText,
    String cancelButtonText, Function(bool onConfirm, bool onCancel) clickEvent,
    {barrierDismissible = true}) {
  Get.defaultDialog(
    title: title,
    textConfirm: " $confirmButtonText ",
    textCancel: cancelButtonText,
    radius: 11,
    barrierDismissible: barrierDismissible,
    content: Text(
      body,
      textAlign: TextAlign.center,
    ),
    confirmTextColor: Colors.white,
    titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    contentPadding: const EdgeInsets.all(16),
    onConfirm: () {
      Get.back();
      clickEvent(true, false);
    },
    onCancel: () {
      Get.back();
      clickEvent(false, true);
    },
  );
}


Navigation(Widget page, {String? arguments, bool? type}) {
  if (type == true) {
    if (arguments != null) {
      Get.off(() => page, arguments: arguments, transition: sendTransition);
    } else {
      Get.off(() => page, transition: sendTransition);
    }
  } else {
    if (arguments != null) {
      Get.to(() => page, arguments: arguments, transition: sendTransition);
    } else {
      Get.to(() => page, transition: sendTransition);
    }
  }
}
