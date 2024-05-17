import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  final void Function()? onTap;
  const DeleteButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8.0), // Set border radius to 8
          ),
          padding: const EdgeInsets.all(5),
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.grey[500]),
          ).tr(),
        ));
  }
}
