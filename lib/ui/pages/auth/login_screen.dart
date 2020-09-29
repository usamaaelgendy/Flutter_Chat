import 'package:chatting_ui_fun/provider/user_auth_provider.dart';
import 'package:chatting_ui_fun/ui/pages/auth/register_screen.dart';
import 'package:chatting_ui_fun/ui/pages/home_screen.dart';
import 'package:chatting_ui_fun/ui/widgets/customLoader.dart';
import 'package:chatting_ui_fun/ui/widgets/custom_button.dart';
import 'package:chatting_ui_fun/ui/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../helper/constants.dart';
import '../home_screen.dart';

class LoginScreen extends StatelessWidget {
  final CustomLoader _loader = CustomLoader();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  String _email, _password;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        width: double.infinity,
        height: size.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                "assets/images/main_top.png",
                width: size.width * 35,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Image.asset(
                "assets/images/login_bottom.png",
                width: size.width * 0.4,
              ),
            ),
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "LOGIN",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: size.height * 0.03),
                    SvgPicture.asset(
                      "assets/icons/login.svg",
                      height: size.height * 0.35,
                    ),
                    SizedBox(height: size.height * 0.03),
                    CustomInputField(
                      hintText: "Email",
                      icon: Icons.person,
                      onClickSave: (value) {
                        _email = value;
                      },
                    ),
                    CustomInputField(
                      hintText: "Password",
                      icon: Icons.lock,
                      isPassword: true,
                      onClickSave: (value) {
                        _password = value;
                      },
                    ),
                    CustomButton(
                      text: "LOGIN",
                      press: () {
                        _submitForm(context);
                      },
                    ),
                    SizedBox(height: size.height * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don’t have an Account ? ",
                          style: TextStyle(color: kPrimaryColor),
                        ),
                        GestureDetector(
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return RegisterScreen();
                                },
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _submitForm(BuildContext context) async {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      _loader.showLoader(context);
      var status = Provider.of<UserAuthProvider>(context, listen: false);
      if (await status.signIn(_email, _password)) {
        _loader.hideLoader();
        Navigator.pop(context);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        _loader.hideLoader();
      }
    }
  }
}
