import 'package:chatting_ui_fun/provider/toggle_visibility_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/constants.dart';

class CustomInputField extends StatelessWidget {
  final Function onClickSave;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final bool isEmail;
  final myController = TextEditingController();

  CustomInputField({
    Key key,
    @required this.onClickSave,
    @required this.hintText,
    this.icon,
    this.isPassword = false,
    this.isEmail = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 10,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 5,
      ),
      width: size.width * 0.8,
      decoration: BoxDecoration(
        color: kPrimaryLightColor,
        borderRadius: BorderRadius.circular(
          29,
        ),
      ),
      child: Consumer<ToggleVisibility>(
        builder: (_, toggle, __) {
          return TextFormField(
            // ignore: missing_return
            validator: (value) {
              if (hintText == "Enter email") {
                Pattern pattern =
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regex = new RegExp(pattern);
                if (!regex.hasMatch(value))
                  return 'Please make sure your email address is valid';
                else
                  return null;
              }
              if (value.isEmpty) {
                return _errorsMessage(hintText);
              }
            },
            onSaved: onClickSave,
            keyboardType:
                isEmail ? TextInputType.emailAddress : TextInputType.text,
            obscureText: isPassword ? !toggle.toggleVisibility : false,
            cursorColor: kPrimaryColor,
            decoration: InputDecoration(
              icon: Icon(
                icon,
                color: kPrimaryColor,
              ),
              hintText: hintText,
              border: InputBorder.none,
              suffixIcon: isPassword
                  ? IconButton(
                      icon: toggle.toggleVisibility
                          ? Icon(Icons.visibility)
                          : Icon(Icons.visibility_off),
                      color: kPrimaryColor,
                      onPressed: () {
                        toggle.changeToggle();
                      },
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  String _errorsMessage(String str) {
    switch (str) {
      case 'Email':
        return 'Email is empty !';
      case 'Password':
        return 'Password is empty !';
      case 'Confirm Password':
        return 'Confirm Password is empty !';
      case 'Name':
        return 'Name is empty !';
    }
    return "";
  }
}
