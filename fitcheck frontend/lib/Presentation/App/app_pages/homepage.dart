import 'package:flutter/material.dart';


class FitCheckApp extends StatelessWidget {
  const FitCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FitCheck",
      theme: ThemeData(fontFamily: "Arial"),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool menuOpen = false;

  void toggleMenu() {
    setState(() {
      menuOpen = !menuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Stack(
        children: [
          /// MAIN PAGE
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            left: menuOpen ? -180 : 0,
            child: buildMainPage(),
          ),

          /// SIDE PANEL
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            right: menuOpen ? 0 : -260,
            child: buildSidePanel(),
          ),
        ],
      ),
    );
  }

  /// ================= MAIN SCREEN =================
  Widget buildMainPage() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          /// TOP BAR
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.amber),
                onPressed: toggleMenu,
              ),
              const Expanded(
                child: Text(
                  "FitCheck",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 48) // To balance the menu icon
            ],
          ),

          const Spacer(),

          /// BOTTOM NAV
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.home_outlined,
                    color: Colors.white, size: 28),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Home pressed")),
                  );
                },
              ),

              /// CENTER ADD BUTTON
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Add Outfit")),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xffC9A227),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.black),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.square,
                    color: Colors.grey, size: 26),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Square button pressed")),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ================= SIDE PANEL =================
  Widget buildSidePanel() {
    return Container(
      width: 260,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Center(
                  child: const Text(
                    "FitCheck",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: toggleMenu,
              )
            ],
          ),

          const SizedBox(height: 80),

          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Wardrobe opened")),
              );
            },
            child: const Text(
              "wardrobe",
              style: TextStyle(fontSize: 22, color: Colors.black),
            ),
          ),

          const Spacer(),

          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Settings opened")),
              );
            },
            child: const Text(
              "settings",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
