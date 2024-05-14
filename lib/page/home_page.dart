import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/drawer.dart';
import 'package:social_media_app/components/text_field.dart';
import 'package:social_media_app/components/wall_post.dart';
import 'package:social_media_app/helper/helper_methods.dart';
import 'package:social_media_app/page/profile_page.dart';
import 'package:social_media_app/page/setting_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // User
  final currentUser = FirebaseAuth.instance.currentUser!;

  // Text controller
  final textController = TextEditingController();

  // Sign out
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  // Post message
  void postMessage() {
    // Only post if there is something in the TextField
    if (textController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('User Posts').add({
        'UserEmail': currentUser.email,
        'Message': textController.text.trim(),
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }
    //Clear the TextFields
    setState(() {
      textController.clear();
    });
  }

  // Navigate to profile page
  void goToProfilePage() {
    // pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ProfilePage()));
  }

  // Navigate to setting page
  void goToSettingPage() {
    // pop menu drawer
    Navigator.pop(context);

    // go to profile page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SettingsPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onBackground,
          title: Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 50),
              child: const Text(
                "Message All",
                style: TextStyle(color: Colors.white),
              ).tr(),
            ),
          )),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSettingTap: goToSettingPage,
        onLogOut: signOut,
      ),
      body: Center(
        child: Column(
          children: [
            // The wall
            Expanded(
                child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('User Posts')
                  .orderBy("TimeStamp", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        //get the message
                        final post = snapshot.data!.docs[index];
                        return WallPost(
                          message: post['Message'],
                          user: post['UserEmail'],
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []),
                          time: formatDate(post['TimeStamp']),
                        );
                      });
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error:${snapshot.error}'),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            )),
            // Post message
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  Expanded(
                      child: MyTextField(
                    controller: textController,
                    hintText: "Write something on Message All".tr(),
                    obscureText: false,
                  )),
                  // Post Button
                  IconButton(
                      onPressed: postMessage,
                      icon: const Icon(Icons.arrow_circle_up))
                ],
              ),
            ),
            // Logged in as
            Text(
              "Logged in as:${currentUser.email!}",
              style: const TextStyle(color: Colors.grey),
            ).tr(),
            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
