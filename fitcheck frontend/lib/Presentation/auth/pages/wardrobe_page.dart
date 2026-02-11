import 'package:fitcheck/Presentation/app_style/backlight_gradient.dart';
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
          Color.fromRGBO(106, 106, 106, 0.502),
          Color.fromRGBO(59, 44, 32, .5),
          Color.fromRGBO(59, 44, 32, .5),
        ],

        light2Alignment: const Alignment(-1, 1),
        light2Radius: 1,

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
                      child: Image.asset(
                        'assets/logo_white.png',
                        width: 110,
                        height: 110,
                          ),
                    ),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(
                  decoration: InputDecoration(
                    filled:true,
                    fillColor: const Color.fromARGB(55, 0, 0, 0),
                    hintText: '',
                    suffixIcon: Icon(Icons.search, color: Colors.white,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:BorderSide.none,                 ),
                    

                    
                  ),
                ),
              )
              ]
              )
              )
              ]
              )
              )
                    )
    );
                  
                
     
  }
}
