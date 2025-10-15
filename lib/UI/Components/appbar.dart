import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Send Snap'),
      centerTitle: true,
      leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      elevation: 2,
    );
  }
}
