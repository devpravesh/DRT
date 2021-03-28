import 'package:db_vendor/Authorization/controllers/authcontroller.dart';
import 'package:db_vendor/Authorization/views/detailsform.dart';
import 'package:db_vendor/home.dart';
import 'package:db_vendor/welcomscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  AuthController _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
        stream: _authController.user,
        builder: (context, snapshot) {
          return Obx(
            () => _authController.firstBoot.value
                ? WelcomeScreen()
                : snapshot.data == null
                    ? Home(
                        controller: _authController,
                      )
                    : _authController.setupComplete.value
                        ? Home(
                            controller: _authController,
                          )
                        : ShopDetails(),
          );
        });
  }
}