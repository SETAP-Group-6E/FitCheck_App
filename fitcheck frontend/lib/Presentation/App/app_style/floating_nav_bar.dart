import 'package:fitcheck/Data/repositories/supabase_wardrobe_repository.dart';
import 'package:fitcheck/Presentation/App/app_pages/wardrobe/widgets/create_outfit.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FloatingNavbar extends StatelessWidget {
  final double width;
  final double height;
  final double bottomPadding;
  final BorderRadius borderRadius;
  final wardrobeRepository = SupabaseWardrobeRepository(
    Supabase.instance.client,
  );

  FloatingNavbar({
    super.key,
    this.width = 470,
    this.height = 60,
    this.bottomPadding = 20,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  Widget _defaultAvatar(BuildContext context) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: Colors.grey[350],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: IconButton(
          icon: const Icon(Icons.person),
          color: Colors.black87,
          iconSize: 20,
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final cacheBuster = DateTime.now().millisecondsSinceEpoch;
    final imageUrl =
      userId == null
        ? null
        : Supabase.instance.client.storage
          .from('Avatars')
          .getPublicUrl('$userId/avatar.jpg?t=$cacheBuster');

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomPadding,
      child: Center(
        child: Container(
          color: const Color.fromRGBO(0, 0, 0, 0.2),
          width: width,
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: 15),
              IconButton(
                icon: Icon(Icons.home, size: 40, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/homepage');
                },
              ),
              Expanded(child: SizedBox()),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Color.fromRGBO(217, 156, 19, 1),
                ),
                child: IconButton(
                  icon: Icon(Icons.add, size: 30, color: Colors.white),
                  onPressed: () async {
                    await CreateOutfitModal.open(
                      context,
                      repository: wardrobeRepository,
                    );
                  },
                ),
              ),
              Expanded(child: SizedBox()),
              
              
                  imageUrl == null
                          ? _defaultAvatar(context)
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Stack(
                children: [Image.network(
                              imageUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _defaultAvatar(context);
                              },
                            ),
                            IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/settings');
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              splashFactory: NoSplash.splashFactory,
                            ),
                            icon: const Icon(
                              Icons.account_box_rounded,
                              color: Colors.transparent,
                            ),
                          ),
                        
                            ]
                          ),

                          
                        
              ),
              

              SizedBox(width: 5),
            ],
          ),
        ),
      ),
    );
  }
}
