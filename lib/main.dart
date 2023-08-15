import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Test",
      home: MainApp(),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    final TextEditingController _text = TextEditingController();
    final TextEditingController _code = TextEditingController();
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              FloatingActionButton(onPressed: () async {
                await auth.verifyPhoneNumber(
                  phoneNumber: _text.text,
                  verificationCompleted:
                      (PhoneAuthCredential credential) async {
                    // ANDROID ONLY!

                    // Sign the user in (or link) with the auto-generated credential
                    await auth.signInWithCredential(credential);
                  },
                  verificationFailed: (FirebaseAuthException e) {
                    if (e.code == 'invalid-phone-number') {
                      print('The provided phone number is not valid.');
                    }

                    // Handle other errors
                  },
                  codeSent: (String verificationId, int? resendToken) async {
                    if (_code.text.length >= 6) {
                      // Update the UI - wait for the user to enter the SMS code

                      String smsCode = _code.text;

                      // Create a PhoneAuthCredential with the code
                      PhoneAuthCredential credential =
                          PhoneAuthProvider.credential(
                              verificationId: verificationId, smsCode: smsCode);

                      // Sign the user in (or link) with the credential
                      try {
                        await auth.signInWithCredential(credential);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Код введен верно"),
                              );
                            });
                      } catch (e) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Код введен неверно"),
                              );
                            });
                      }
                    }
                  },
                  timeout: const Duration(seconds: 60),
                  codeAutoRetrievalTimeout: (String verificationId) {
                    // Auto-resolution timed out...
                  },
                );
              }),
              TextField(
                controller: _text,
              ),
              TextField(
                controller: _code,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
