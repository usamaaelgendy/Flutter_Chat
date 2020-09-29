import 'dart:math';

import 'package:chatting_ui_fun/helper/constants.dart';
import 'package:chatting_ui_fun/model/users.dart';
import 'package:chatting_ui_fun/provider/user_auth_provider.dart';
import 'package:chatting_ui_fun/ui/pages/auth/login_screen.dart';
import 'package:chatting_ui_fun/ui/widgets/customLoader.dart';
import 'package:chatting_ui_fun/ui/widgets/custom_button.dart';
import 'package:chatting_ui_fun/ui/widgets/custom_input_field.dart';
import 'package:chatting_ui_fun/ui/widgets/custom_widget/custom_widgets.dart';
import 'package:chatting_ui_fun/ui/widgets/social_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../home_screen.dart';

// ignore: must_be_immutable
class RegisterScreen extends StatelessWidget {
  final CustomLoader _loader = CustomLoader();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String _email, _name, _password, _confirmPassword;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var state = Provider.of<UserAuthProvider>(context, listen: false);
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        height: size.height,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                "assets/images/register_top.png",
                width: size.width * 0.35,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Image.asset(
                "assets/images/main_bottom.png",
                width: size.width * 0.25,
              ),
            ),
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "SIGNUP",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: size.height * 0.03),
                    SvgPicture.asset(
                      "assets/icons/signup.svg",
                      height: size.height * 0.25,
                    ),
                    CustomInputField(
                      onClickSave: (value) {
                        _email = value;
                      },
                      icon: Icons.email,
                      hintText: "Email",
                      isEmail: true,
                    ),
                    CustomInputField(
                      onClickSave: (value) {
                        _name = value;
                      },
                      icon: Icons.person,
                      hintText: "Name",
                    ),
                    CustomInputField(
                      onClickSave: (value) {
                        _password = value;
                      },
                      hintText: "Password",
                      icon: Icons.lock,
                      isPassword: true,
                    ),
                    CustomInputField(
                      onClickSave: (value) {
                        _confirmPassword = value;
                      },
                      hintText: "Confirm Password",
                      icon: Icons.lock,
                      isPassword: true,
                    ),
                    CustomButton(
                      text: "SIGNUP",
                      press: () {
                        _submitForms(context);
                      },
                    ),
                    SizedBox(height: size.height * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an Account ? ",
                          style: TextStyle(color: kPrimaryColor),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return LoginScreen();
                                },
                              ),
                            );
                          },
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                    buildDivider(context),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SocialIcon(
                          iconSrc: "assets/icons/facebook.svg",
                          press: () {},
                        ),
                        SocialIcon(
                          iconSrc: "assets/icons/twitter.svg",
                          press: () {},
                        ),
                        SocialIcon(
                          iconSrc: "assets/icons/google-plus.svg",
                          press: () async {
                            if (await state.handelUserSignInWithGoogle()) {
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()));
                            } else {
                              print("error");
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDivider(context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: size.height * 0.02),
      width: size.width * 0.8,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Divider(
              color: Color(0xFFD9D9D9),
              height: 1.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "OR",
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Color(0xFFD9D9D9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  _submitForms(BuildContext context) async {
    _formKey.currentState.save();
    if (_password != _confirmPassword) {
      customSnackBar(_scaffoldKey, "password don't match");
      return;
    }
    if (_formKey.currentState.validate()) {
      _loader.showLoader(context);
      var state = Provider.of<UserAuthProvider>(context, listen: false);
      Random random = new Random();
      int randomNumber = random.nextInt(7);

      Users user = Users(
        email: _email.toLowerCase(),
        profilePic: dummyProfilePicList[randomNumber],
        isOnline: true,
        userName: _name,
      );
      //
      if (await state.signUp(user, _password, scaffoldKey: _scaffoldKey)) {
        _loader.hideLoader();
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      } else {
        _loader.hideLoader();
      }
    }
  }
}
