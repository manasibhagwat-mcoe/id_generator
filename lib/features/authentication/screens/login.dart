// import 'package:mongo_dart/mongo_dart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:id_generator/animations/shake-widget.dart';
import 'package:id_generator/features/generate_qr_code.dart';
import 'package:id_generator/pages/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late Size mediaSize;
  late Color myColor;
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool rememberUser = false;
  final _formKey = GlobalKey<FormState>();
  final shakeKey = GlobalKey<ShakeWidgetState>();

  RegExp passValid = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");
  RegExp phoneValid = RegExp(r"^\+?[0-9]{10,12}$");

  bool validatePassword(String pass) {
    String _password = pass.trim();

    if (passValid.hasMatch(_password)) {
      return true;
    } else {
      return false;
    }
  }

  bool validatePhoneNumber(String phone) {
    String _phoneNumber = phone.trim();

    if (phoneValid.hasMatch(_phoneNumber)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    mediaSize = MediaQuery.of(context).size;
    myColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Login ",
            style: TextStyle(
                color: myColor, fontSize: 48, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      body: SafeArea(
        child: _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 60,
              ),
              ShakeWidget(
                  key: shakeKey,
                  shakeOffset: 10,
                  shakeCount: 3,
                  shakeDuration: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      TextFormField(
                        maxLength: 10,
                        keyboardType: TextInputType.phone,
                        controller: phoneController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "9145369999",
                            label: Text(" Phone Number "),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Colors.deepPurple,
                            )),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Phone Number ';
                          } else {
                            bool result = validatePhoneNumber(value);
                            if (result) {
                              return null;
                            } else {
                              return "Enter Proper Number";
                            }
                          }
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        maxLength: 12,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Password ';
                          } else {
                            bool result = validatePassword(value);
                            if (result) {
                              return null;
                            } else {
                              return " Password should contain Capital, small letter & Number & Special";
                            }
                          }
                        },
                        keyboardType: TextInputType.visiblePassword,
                        controller: passwordController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Abc#123",
                            label: Text("Password "),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.deepPurple,
                            )),
                      ),
                    ],
                  )),
              const SizedBox(
                height: 30,
              ),
              // _buildRememberForgot(),
              const SizedBox(
                height: 30,
              ),
              _buildLoginButton(),
              const SizedBox(height: 30),
              _buildRegister(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.grey),
    );
  }

  Widget _buildInputField(
      TextEditingController controller, String label, int ml, TextInputType tit,
      {isPassword = false}) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please Provide Credential  ';
        }
        return null;
      },
      controller: controller,
      maxLength: 10,
      keyboardType: tit,
      decoration: InputDecoration(
          suffixIcon: isPassword
              ? const Icon(Icons.remove_red_eye)
              : const Icon(Icons.done),
          border: const OutlineInputBorder(),
          label: Text(label)),
      obscureText: isPassword,
    );
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
                value: rememberUser,
                onChanged: (value) {
                  setState(() {
                    rememberUser = value!;
                  });
                }),
            _buildGreyText("Remember me ")
          ],
        ),
        TextButton(onPressed: () {}, child: _buildGreyText("Forgot Password"))
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final snapshot = await checkCredentials();
            if (snapshot.docs.isNotEmpty) {
              for (QueryDocumentSnapshot document in snapshot.docs) {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String password = data['password'];
                if (passwordController.text == password) {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', true);
                  debugPrint("Sharedpreference Set !");
                  Get.to(GenerateQR(data: "$phoneController.text"));
                } else {
                  // ignore: use_build_context_synchronously
                  showDialog(
                    context: context,
                    builder: (context) => const AlertDialog(
                      title: Text("Password Not Matched "),
                    ),
                  );
                }
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Phone Number does not exist '),
                  duration:
                      Duration(seconds: 2), // Adjust the duration as needed
                ),
              );
            }
          } else {
            shakeKey.currentState?.shake();
          }
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: myColor,
            shape: const StadiumBorder(),
            elevation: 20,
            shadowColor: Colors.deepPurple,
            minimumSize: const Size.fromHeight(60)),
        child: const Text(
          "LOGIN",
          style: TextStyle(color: Colors.white),
        ));
  }

  Widget _buildRegister() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildGreyText("Don't have an account? "),
          TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: () {
                setState(() {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Signup()));
                });
              },
              child: const Text(
                "Register Here ",
                style: TextStyle(color: Colors.deepPurple),
              ))
        ],
      ),
    );
  }

  Future<QuerySnapshot> checkCredentials() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('credentials')
        .where('phonenumber', isEqualTo: phoneController.text)
        .get();
    return snapshot;
  }
}