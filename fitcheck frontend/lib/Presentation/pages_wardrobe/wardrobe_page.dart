import 'package:fitcheck/Presentation/app_style/backlight_gradient.dart';
import 'package:fitcheck/Presentation/app_style/glass_frame.dart';
import 'package:flutter/material.dart';

class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BacklightGradient(
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

                            borderRadius: BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Icon(
                            Icons.settings_outlined,
                            color: Colors.white, 
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                      Padding(
                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.56),
                        child:GlassFrame(
                        child:  Container(
                        padding: const EdgeInsets.all(3), 
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(0, 0, 0, 0.2),
                        
                          borderRadius: BorderRadius.circular(
                            20,
                          ),
                        ),
                        child:
                        Row(
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
                          ]
                        )
                                             
                                            ),)
                      ),
                    
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
