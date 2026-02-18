import 'package:flutter/material.dart';

class SearchBarRow extends StatefulWidget {
  const SearchBarRow({Key? key}) : super(key: key);

  @override
  _SearchBarRowState createState() => _SearchBarRowState();
}

class _SearchBarRowState extends State<SearchBarRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
  
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: _expanded ? 250 : 60,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
        child: Row(),
      );
    }
  }