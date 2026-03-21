import 'package:fitcheck/Presentation/App/app_pages/wardrobe/widgets/create_item.dart';
import 'package:fitcheck/Presentation/App/app_style/dashed_box.dart';
import 'package:fitcheck/Presentation/App/app_style/floating_nav_bar.dart';
import 'package:fitcheck/Presentation/App/app_style/search_bar.dart';
import 'package:fitcheck/Presentation/App/app_style/glass_frame.dart';
import 'package:flutter/material.dart';
//import 'package:fitcheck/Presentation/App/app_pages/wardrobe/widgets/create_item.dart';
//import 'package:fitcheck/Presentation/App/app_pages/wardrobe/widgets/create_outfit.dart';
import 'package:fitcheck/Data/repositories/supabase_wardrobe_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key});
  


  @override
  Widget build(BuildContext context) {
    final wardrobeRepository = SupabaseWardrobeRepository(
      Supabase.instance.client,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
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
                              SizedBox(
                                child: GlassFrame(
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(0, 0, 0, 0.2),
            
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.arrow_back_ios_sharp,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(child: SizedBox()),
            
                              SizedBox(
                                child: GlassFrame(
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(0, 0, 0, 0.2),
            
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                    child: Row(
                                      children: [
                                        SearchBarRow(),
            
                                        SizedBox(
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.filter_list_outlined,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              null;
                                            },
                                          ),
                                        ),
            
                                        SizedBox(
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.grid_view,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              null;
                                            },
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
                                    height: 125,
                                    width: 125,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 125,
                                    width: 125,
                                    color: Colors.black12,
                                    child: DashedBox(
                                      color: Colors.black,
                                      strokeWidth: 7.0,
                                      gap: 11.1,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 125,
                                    width: 125,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      onPressed: () async {
                                        await CreateItem.open(
                                          context,
                                          repository: wardrobeRepository,
                                        );
                                      },
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
          ),
          FloatingNavbar(),
        ],
      ),
    );
  }
}
