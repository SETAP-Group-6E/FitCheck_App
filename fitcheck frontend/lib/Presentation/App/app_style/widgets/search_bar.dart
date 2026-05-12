import 'package:flutter/material.dart';

class SearchBarRow extends StatefulWidget {
  const SearchBarRow({
    super.key,
    this.controller,
    this.onChanged,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  State<SearchBarRow> createState() => _SearchBarRowState();
}

class _SearchBarRowState extends State<SearchBarRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: _expanded ? 150 : 0,
          height: 40,
          curve: Curves.ease,
          child: _expanded
              ? TextField(
                  controller: widget.controller,
                  onChanged: widget.onChanged,
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
            color: Theme.of(context).scaffoldBackgroundColor,
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
