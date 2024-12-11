import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final bool enabledBackground;

  const MyAppBar(
      {super.key, this.title, this.leading, this.enabledBackground = false});

  @override
  Widget build(BuildContext context) {
    return enabledBackground
        ? _buildWithBackground()
        : _buildWithoutBackground();
  }

  Widget _buildWithBackground() {
    return Material(
      elevation: 6, // Adds a shadow effect
      shadowColor: Colors.black.withOpacity(0.5), // Customize shadow color
      color: Colors.white,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 18, right: 18, top: 15, bottom: 15),
        child: AppBar(
          leading: leading,
          title: title,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
      ),
    );
  }

  Widget _buildWithoutBackground() {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 20, bottom: 20),
      child: AppBar(
        leading: leading,
        title: title,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (enabledBackground ? 30 : 45)); // Set custom height
}
