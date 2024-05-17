import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/text_box.dart';
import 'package:social_media_app/components/wall_post.dart';
import 'package:social_media_app/helper/helper_methods.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // User
  final currentUser = FirebaseAuth.instance.currentUser!;

  // All user
  final userCollection = FirebaseFirestore.instance.collection("Users");

  // Edit Field
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text(
                "Edit Username".tr(),
                style: const TextStyle(color: Colors.white),
              ),
              content: TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: "Enter new username".tr(),
                    hintStyle: const TextStyle(color: Colors.grey)),
                onChanged: (value) => {newValue = value},
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel".tr(),
                      style: const TextStyle(color: Colors.white),
                    )),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(newValue),
                    child: Text(
                      "Save".tr(),
                      style: const TextStyle(color: Colors.white),
                    ))
              ],
            ));
    // update in firestore
    if (newValue.trim().isNotEmpty) {
      // only update if there is something in the textfield
      await userCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  // // Run buildMyPosts is first
  // @override
  // void initState(){
  //   super.initState();
  //   buildMyPosts();
  // }
  // // After run buildMyPosts then delete all items in listMyPosts in buildMyPosts
  // @override
  // void dispose(){
  //   super.dispose();
  //   buildMyPosts();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Profile Page".tr(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey[900],
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("Users")
                      .doc(currentUser.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    // get user data
                    if (snapshot.hasData) {
                      final userData =
                          snapshot.data!.data() as Map<String, dynamic>;

                      return ListView(
                        children: [
                          const SizedBox(
                            height: 50,
                          ),
                          // Profile Picture
                          const Icon(
                            Icons.person,
                            size: 72,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          // User Email
                          Text(
                            currentUser.email!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          // User Details
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              "My Details".tr(),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          // UserName
                          MyTextBox(
                              text: userData['username'],
                              sectionName: "username".tr(),
                              onPressed: () => editField('username')),
                          // Bio
                          MyTextBox(
                              text: userData['bio'],
                              sectionName: "bio".tr(),
                              onPressed: () => editField('bio')),
                          const SizedBox(
                            height: 50,
                          ),
                          // User Posts
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              "My Posts".tr(),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error${snapshot.error}'),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
            ),
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
                        if (post['UserEmail'].toString() ==
                            currentUser.email.toString()) {
                          return WallPost(
                            message: post['Message'],
                            user: post['UserEmail'],
                            postId: post.id,
                            likes: List<String>.from(post['Likes'] ?? []),
                            time: formatDate(post['TimeStamp']),
                          );
                        }
                        return null;
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
          ],
        ));
  }
}
