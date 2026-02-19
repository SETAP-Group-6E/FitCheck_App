import 'package:google_fonts/google_fonts.dart';
import 'package:fitcheck/Presentation/App/app_style/password_field.dart';
import 'package:flutter/material.dart';

class RegPage extends StatelessWidget {
  const RegPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          Expanded(child: SizedBox()),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Color.fromRGBO(217, 156, 19, 1),
                  ),
                  child: Image(image: AssetImage("assets/logo_white.png")),
                ),
              ),
              SizedBox(height: 20),

              Text(
                "Join the Community",
                style: GoogleFonts.dmSerifText(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  
                ),
              ),
              Text(
                "Discover and share your daily style",
                style: GoogleFonts.hedvigLettersSerif(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                height: 40,
                width: 350,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 40,
                width: 350,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 40,
                width: 350,
                child: PasswordField(),
              ),
              SizedBox(height: 10),

              SizedBox(
                height: 40,
                width: 350,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(217, 156, 19, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    null;
                  },
                  child: Text(
                    "Register",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Hedvig Serif Text",
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(217, 156, 19, 1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    height: 35,
                    width: 35,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.one_x_mobiledata,
                        color: Colors.black,
                        size: 30,
                      ),
                      onPressed: () {
                        null;
                      },
                    ),
                  ),
                  SizedBox(width: 25),
                  Container(
                    decoration: BoxDecoration(
                      color:Color.fromRGBO(217, 156, 19, 1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    height: 35,
                    width: 35,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.apple,
                        color: Colors.black,
                        size: 30,
                      ),
                      onPressed: () {
                        null;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(color: Colors.white54),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(color: Color.fromRGBO(217, 156, 19, 1)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}
