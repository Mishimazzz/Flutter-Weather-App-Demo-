import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  Future<void> signInWithGoogle() async {
  try {
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final uc = await FirebaseAuth.instance.signInWithCredential(credential);

    debugPrint("firebase user: ${uc.user?.email}");
    debugPrint("currentUser: ${FirebaseAuth.instance.currentUser?.email}");
  } catch (e) {
    debugPrint("signIn error: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton.icon(
          onPressed: signInWithGoogle,
          icon: const Icon(Icons.login),
          label: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}
