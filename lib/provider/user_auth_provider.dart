import 'package:chatting_ui_fun/database/database_services.dart';
import 'package:chatting_ui_fun/helper/constants.dart';
import 'package:chatting_ui_fun/model/users.dart';
import 'package:chatting_ui_fun/ui/widgets/custom_widget/custom_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserAuthProvider extends ChangeNotifier {
  // firebase
  FirebaseAuth _auth = FirebaseAuth.instance;
  User _user;

  // Google sign in
  GoogleSignIn _googleSignIn = GoogleSignIn();

  // cons
  Status _status = Status.Uninitialized;

  // getter method
  User get user => _user;

  Status get status => _status;

  UserAuthProvider.initialize() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onStateChanged);
  }

  Future<void> _onStateChanged(User user) async {
    if (user == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = user;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password,
      {GlobalKey<ScaffoldState> scaffoldKey}) async {
    try {
      _status = Status.Authenticating;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return true;
    } catch (error) {
      _status = Status.Unauthenticated;
      print(error.toString());
      customSnackBar(scaffoldKey, error.message);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(Users userModel, String password,
      {GlobalKey<ScaffoldState> scaffoldKey}) async {
    try {
      _status = Status.Authenticating;
      _user = (await _auth.createUserWithEmailAndPassword(
              email: userModel.email, password: password))
          .user;
      userModel.userId = _user.uid;
      DatabaseServices().addAndUpdateUserData(userModel);
      return true;
    } catch (error) {
      _status = Status.Unauthenticated;
      print(error);
      customSnackBar(scaffoldKey, error.message);
      notifyListeners();
      return false;
    }
  }

  /// GOOGLE SIGN IN AND CREATE USER
  Future<bool> handelUserSignInWithGoogle(
      {GlobalKey<ScaffoldState> scaffoldKey}) async {
    try {
      // this line connect to google account and get user data from google
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google login cancelled by user');
      }
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleUser.authentication;

      // get credential --> to get Credential token and id
      // to connect with firebase we need this credential
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // this line login with google into firebase and get data
      _user = (await _auth.signInWithCredential(credential)).user;

      createUserFromGoogleSignIn(_user);
      notifyListeners();
      return true;
    } catch (error) {
      _status = Status.Unauthenticated;
      print(error);
      customSnackBar(scaffoldKey, error.message);
      notifyListeners();
      return false;
    }
  }

  Future<void> createUserFromGoogleSignIn(User user) async {
    // into the User class we can access to metadata .. this contain create time and last sign in time
    /// print(user.metadata);

    // get the difference between date now and create time
    if (DateTime.now().difference(user.metadata.creationTime) <
        Duration(seconds: 15)) {
      print("New User");
      Users model = Users(
        profilePic: user.photoURL,
        email: user.email,
        userId: user.uid,
        isOnline: true,
        userName: user.displayName,
      );
      await DatabaseServices().addAndUpdateUserData(model);
    } else {
      print("Old User ");
    }
  }

  /// Sign out
  Future signOut() async {
    await _googleSignIn.signOut();
    await _googleSignIn.disconnect();
    await _auth.signOut();
    await FirebaseAuth.instance.signOut();

    _status = Status.Uninitialized;
    notifyListeners();
  }
}
