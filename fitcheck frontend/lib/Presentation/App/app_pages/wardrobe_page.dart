import 'package:fitcheck/Presentation/app/app_style/backlight_gradient.dart';
import 'package:fitcheck/Presentation/app/app_style/glass_frame.dart';
import 'package:fitcheck/Presentation/app/app_style/glass_navBar.dart';
import 'package:flutter/material.dart';

class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BacklightGradient(
            colorBg: const Color.fromRGBO(0, 0, 0, 1),

            light1: const [
              Color.fromRGBO(0, 0, 0, 1),
              Color.fromRGBO(0, 0, 0, 1),
              Color.fromRGBO(0, 0, 0, 1),
            ],

            light1Alignment: const Alignment(0, 0),
            light1Radius: 0,

            light2: const [
              Color.fromRGBO(0, 0, 0, 1),
              Color.fromRGBO(0, 0, 0, 1),
              Color.fromRGBO(0, 0, 0, 1),
            ],

            light2Alignment: const Alignment(0, 0),
            light2Radius: 0,

            blur: 100,

            child: SizedBox(),
          ),
          Column(
            children: [
              //non scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GlassFrame(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(0, 0, 0, 0.2),

                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_sharp,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(child: SizedBox()),

                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: GlassFrame(
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(0, 0, 0, 0.2),

                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Icon(
                                          Icons.search,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.filter_list_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.grid_view,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 30.0,
                              bottom: 20,
                            ),
                            child: Text(
                              "Wardrobe",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 35,
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 120,
                                  width: 120,
                                  color: Colors.black12,
                                  child: DashedRect(
                                    color: Colors.white,
                                    strokeWidth: 2.0,
                                    gap: 3.0,
                                  ),
                                ),
                                Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          GlassNavBar(
            items: [
              SizedBox(width: 15),
              Icon(Icons.home, size: 30, color: Colors.white),
              Expanded(child: SizedBox()),

              Icon(
                Icons.square_rounded,
                size: 50,
                color: const Color.fromARGB(255, 91, 90, 90),
              ),
              SizedBox(width: 5),
            ],
          ),
        ],
      ),
    );
  }
}
