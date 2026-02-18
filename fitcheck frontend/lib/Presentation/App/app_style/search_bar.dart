import 'package:flutter/material.dart';

class SearchBarRow extends StatefulWidget {
  const SearchBarRow();

  @override
  _SearchBarRowState createState() => _SearchBarRowState();
}

class _SearchBarRowState extends State<SearchBarRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: _expanded ? 190 : 0,
          height: 40,
          curve: Curves.ease,
          child: _expanded
              ? TextField(
                  decoration: InputDecoration(
                    hintText: "Search...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  style: TextStyle(color: Colors.white),
                )
              : null,
        ),
        Container(
          width: 50, 
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
          ),
        ),
      ],
    );
  }
}