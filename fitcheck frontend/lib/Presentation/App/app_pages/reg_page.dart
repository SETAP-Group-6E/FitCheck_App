import 'package:fitcheck/Presentation/App/app_style/dashed_box.dart';
import 'package:fitcheck/Presentation/App/app_style/search_bar.dart';
import 'package:fitcheck/Presentation/app/app_style/glass_frame.dart';
import 'package:fitcheck/Presentation/App/app_style/floating_navBar.dart';
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

              
            ],
          ),Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}
