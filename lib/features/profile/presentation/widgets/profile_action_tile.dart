import 'package:flutter/material.dart';

class ProfileActionTile extends StatelessWidget {
  final IconData? icon;
  final void Function()? onTap;
  final String title;
  const ProfileActionTile(
      {super.key,
      required this.icon,
      required this.onTap,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.1,
      ),
      onTap: onTap,
      horizontalTitleGap: 31,
      leading: CircleAvatar(
        backgroundColor: const Color.fromRGBO(16, 16, 16, 0.05),
        child: Icon(icon),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
