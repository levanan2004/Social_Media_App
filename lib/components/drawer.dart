import 'package:flutter/material.dart';
import 'package:social_media_app/components/my_list_tile.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSettingTap;
  final void Function()? onLogOut;
  const MyDrawer(
      {super.key,
      required this.onProfileTap,
      required this.onSettingTap,
      required this.onLogOut});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // Header
              const DrawerHeader(
                  child: Icon(
                Icons.person,
                color: Colors.white,
                size: 64,
              )),
              //Home list tile
              MyListTile(
                icon: Icons.home,
                text: "H O M E",
                onTap: () => Navigator.pop(context),
              ),
              // Profile list tile
              MyListTile(
                  icon: Icons.person,
                  text: "P R O F I L E",
                  onTap: onProfileTap),
              MyListTile(
                  icon: Icons.settings,
                  text: "S E T T I N G",
                  onTap: onSettingTap),
            ],
          ),
          //Loggest list tile
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: MyListTile(
                icon: Icons.logout, text: "L O G O U T", onTap: onLogOut),
          )
        ],
      ),
    );
  }
}
