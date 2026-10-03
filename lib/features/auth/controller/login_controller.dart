import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:suraj_approval/core/constants/api_url.dart';
import 'package:suraj_approval/core/constants/app_constants.dart';
import 'package:suraj_approval/core/constants/app_strings.dart';
import 'package:suraj_approval/core/extentions/num_extention.dart';
import 'package:suraj_approval/core/router/app_router.dart';
import 'package:suraj_approval/core/service/api_service.dart';
import 'package:suraj_approval/core/service/local_db.dart';
import 'package:suraj_approval/core/service/notification_service.dart';
import 'package:suraj_approval/core/utills/app_module_container.dart';
import 'package:suraj_approval/core/utills/app_utills.dart';
import 'package:suraj_approval/core/widgets/app_dialog.dart';
import 'package:suraj_approval/core/widgets/app_text_field.dart';
import 'package:suraj_approval/core/widgets/common_widgets.dart';

import '../../../core/utills/device_type.dart';
import '../../dashboard/controller/session_controller.dart';
import '../../notifications/controller/notification_controller.dart';

class LoginController extends GetxController {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController baseUrlController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxString errorMessage = ''.obs;
  final sessionController = Get.find<SessionController>();
  RxInt ipType = 1.obs;
  RxInt selectIPType = 1.obs;
  final FocusNode keyboardFocusNode = FocusNode();

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final fcmId = await NotificationService.getFcmId();
      print('fcmId:${fcmId}');
      final response = await ApiService.postData(
        ApiUrl.loginApi,
        queryParams: {
          'mUser': userIdController.text.trim(),
          'mPasswords': passwordController.text.trim(),
          'fcmid': fcmId,
          'mDeviceType': DeviceType.isMobile(Get.context!) ? 'mobile' : 'web',
        },
      );

      if (isClosed) return;
      final data = response.data;
      if (data['status'] == 'success') {
        final userData = (data['data'] as Map);
        final jsonString = jsonEncode(userData);
        LocalDB.setString(AppConstants.currentUser, jsonString);
        Get.find<SessionController>().startSessionTimer();
        await Get.find<NotificationController>().fetchNotifications();
        Get.offAllNamed(AppRouter.dashboardScreen);
        AppUtils.showSnackBar('Login successful!');
      } else {
        errorMessage.value = 'Invalid credentials. Please try again.';
      }
      isLoading.value = false;
    } on DioException catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Connection not found, Config your environment';
      if (e.type == DioExceptionType.connectionError) {
        showSettingsDialog(Get.context!);
      }
    } catch (e) {
      errorMessage.value = 'Login failed. Please try again.$e';
      isLoading.value = false;
    }
  }

  // ! GET Base URL
  void ipTypeChanged(int? value) {
    if (value != null) {
      ipType.value = value;
    }
  }

  Future<void> getBaseUrl(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final response = await ApiService.getData(
        // ApiUrl.getBaseUrl,
        'http://124.123.122.112:7081/ReportNew/GetBaseUrl',
        // 'http://124.123.122.112:7081/Report/GetBaseUrl',
        queryParams: {'mType': ipType.value == 1 ? 'Global' : 'Local'},
      );
      final data = (response.data);

      if (response.statusCode == 200) {
        final newBase = data['data']?['mUrl'] ?? '';
        await LocalDB.setString(AppConstants.baseUrl, newBase);
        ApiUrl.baseUrlGlobal = newBase;
        ApiService.setBaseUrl(newBase);
        login();
      } else {
        AppUtils.showSnackBar(data?['message'] ?? 'Failed to get URL');
        isLoading.value = false;
      }
    } on DioException catch (e) {
      errorMessage.value = 'Connection not found, Config your environment';
      if (e.type == DioExceptionType.connectionError) {
        showSettingsDialog(context);
      }
      isLoading.value = false;
    } catch (e) {
      AppUtils.showSnackBar(e.toString());
      isLoading.value = false;
    }
  }

  String? validateUserId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your User ID';
    }
    if (value.length < 3) {
      return 'User ID must be at least 3 characters';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 3) {
      return 'Password must be at least 3 characters';
    }
    return null;
  }

  @override
  void onClose() {
    userIdController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void showSettingsDialog(BuildContext context) async {
    await Get.dialog(
      GenericDialogBox(
        headerText: 'Config Environment',
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child:
              DeviceType.isMobile(context) || DeviceType.isTablet(context)
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Enter New Base URL:',
                        style: TextStyles.medium(context),
                      ),
                      10.heightGap,
                      AppTextField(
                        hint: 'Base Url',
                        controller: baseUrlController,
                      ),
                    ],
                  )
                  : Row(
                    children: [
                      AppText(
                        'Enter New Base URL:',
                        style: TextStyles.medium(context),
                      ),
                      10.widthGap,
                      Flexible(
                        child: AppTextField(
                          hint: 'Base Url',
                          controller: baseUrlController,
                        ),
                      ),
                    ],
                  ),
        ),
        isLoading: isLoading,
        primaryButtonText: AppStrings.confirm,
        secondaryButtonText: AppStrings.cancel,
        onPrimaryButtonPressed: () async {
          final trimmedUrl = baseUrlController.text.trim();
          if (trimmedUrl.isEmpty) {
            AppUtils.showSnackBar(
              'Base URL cannot be empty',
              background: Colors.red,
            );
            return;
          }
          ApiService.setBaseUrl(baseUrlController.text.trim());
          Get.back();
        },
        onSecondaryButtonPressed: () {
          Get.back();
        },
      ),
    );
    isLoading.value = false;
    baseUrlController.clear();
  }

  bool isValidBaseUrl(String url) {
    final urlPattern =
        r'^(https?:\/\/)?(([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})|(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}))(:\d+)?(\/.*)?$';
    final regex = RegExp(urlPattern);
    return regex.hasMatch(url);
  }

  @override
  void onInit() {
    super.onInit();
    keyboardFocusNode.requestFocus();
    NotificationService.updateBadgeCount(0);
  }
}
