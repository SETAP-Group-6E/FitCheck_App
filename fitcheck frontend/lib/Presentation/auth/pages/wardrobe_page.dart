import 'package:flutter/material.dart';

class WardrobePage extends StatelessWidget {
  const WardrobePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
	return Scaffold(
	  appBar: AppBar(
		title: const Text('Wardrobe'),
	  ),
	  body: const Center(
		
		child: Text('Welcome to the Wardrobe Page!'),
	  ),
	);
  }
}

