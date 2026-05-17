// Compact search bar row: an expandable search field with a toggle.
// Used in headers where space is limited and a minimal search control
// is desired.
import 'package:flutter/material.dart';

class SearchBarRow extends StatefulWidget {
  const SearchBarRow({super.key, this.controller, this.onChanged});

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
          duration: const Duration(milliseconds: 300),
          width: _expanded ? 150 : 0,
          height: 40,
          curve: Curves.ease,

          child:
              _expanded
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
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Toggle the expanded state. In many headers this button
              // is used to reveal a compact search input without taking
              // up permanent horizontal space.
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
