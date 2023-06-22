import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yoggo/home_screen.dart';
import 'package:yoggo/size_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    print(googleUser);
    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    // Once signed in, return the UserCredential
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.yellow, // Set the background color to yellow
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/images/bkground.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 20 * SizeConfig.defaultSize!,
            left: MediaQuery.of(context).size.width / 2 - 95,
            child: GestureDetector(
              onTap: signInWithGoogle,
              child: Image.asset(
                'lib/images/google_login.png',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
