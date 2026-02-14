import 'package:fitcheck/Presentation/app_style/backlight_gradient.dart';
import 'package:fitcheck/Presentation/app_style/glass_frame.dart';
import 'package:fitcheck/Presentation/app_style/glass_navBar.dart';
import 'package:flutter/material.dart';

class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BacklightGradient(
            colorBg: const Color.fromARGB(255, 65, 42, 24),

            light1: const [
              Color.fromRGBO(125, 124, 124, 1),
              Color.fromRGBO(59, 44, 32, 1),
              Color.fromRGBO(91, 91, 91, 0.3),
            ],

            light1Alignment: const Alignment(1, -1.5),
            light1Radius: 2,

            light2: const [
              Color.fromRGBO(0, 0, 0, 1),
              Color.fromRGBO(59, 44, 32, .5),
              Color.fromRGBO(35, 22, 10, 0.536),
            ],

            light2Alignment: const Alignment(-1, 1),
            light2Radius: 2,

            blur: 100,

            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
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

                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.settings_outlined,
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

                                borderRadius: BorderRadius.circular(20),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 30),
                            child: Text(
                              "WARDROBE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontFamily: "Oswald",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GlassFrame(
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.27,
                                  height: 65,
                                  padding: const EdgeInsets.all(30),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(0, 0, 0, 0.2),
                                    borderRadius: BorderRadius.circular(1),
                                ),
                              ),),
                              SizedBox(width: 20),
                              GlassFrame(
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.27,
                                  height: 65,
                                  padding: const EdgeInsets.all(30),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(0, 0, 0, 0.2),
                                    borderRadius: BorderRadius.circular(1),
                                ),
                              ),),
                              SizedBox(width: 20),
                              GlassFrame(
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.27,
                                  height: 65,
                                  padding: const EdgeInsets.all(30),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(0, 0, 0, 0.2),
                                    borderRadius: BorderRadius.circular(1),
                                ),
                              ),),
                            ],

                          ),
                          SizedBox(height: 10),
                          GlassFrame(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: MediaQuery.of(context).size.height * 0.65,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(0, 0, 0, 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  "Your wardrobe is empty. Start adding your clothes to create outfits and get personalized recommendations!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: "Oswald",
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          GlassNavBar(
            items: [
              Icon(Icons.home, color: Colors.white),
              Container(
                width: 270,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
