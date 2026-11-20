
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  Future<User?> currentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<UserCredential> signInWithGoogle() async {

    final GoogleSignInAccount googleUser =
        await GoogleSignIn.instance.authenticate();

    final GoogleSignInAuthentication googleAuth =
        googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> initializeGoogle() async {
  await GoogleSignIn.instance.initialize();
}
}
