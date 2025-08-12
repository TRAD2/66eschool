import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCupertinoSwitch extends StatelessWidget {
  final Function onChanged;
  final bool value;

  const CustomCupertinoSwitch(
      {super.key, required this.onChanged, required this.value,});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
        scale: 0.65,
        child: CupertinoSwitch(
            activeTrackColor: Theme.of(context).colorScheme.primary,
            value: value,
            onChanged: (value) {
              onChanged(value);
            },),);
  }
}
