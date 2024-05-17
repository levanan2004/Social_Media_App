import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/comment.dart';
import 'package:social_media_app/components/comment_button.dart';
import 'package:social_media_app/components/delete_button.dart';
import 'package:social_media_app/components/like_button.dart';
import 'package:social_media_app/helper/helper_methods.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final String time;
  final List<String> likes;
  const WallPost(
      {super.key,
      required this.message,
      required this.user,
      required this.postId,
      required this.likes,
      required this.time});

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  //  User
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  // Comment text Controller
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  // Toogle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    // Access the document in FireBase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      // If the post is now Liked, add the user's email to the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      // If the post is now unLiked, remove the user's email from the 'Likes' field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  // Add a Comment
  void addComment(String commentText) {
    // Write the comment to firestore under the comments collection for this post
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      'CommentText': commentText,
      'CommentBy': currentUser.email,
      'CommentTime': Timestamp.now(),
    });
  }

  // Show a dialog box for adding comment
  void showCommentDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Add Comment"),
              content: TextField(
                controller: _commentTextController,
                decoration:
                    const InputDecoration(hintText: "Write a comment..."),
              ),
              actions: [
                // Cancel BUtton
                TextButton(
                    onPressed: () {
                      // pop box
                      Navigator.pop(context);

                      // Clear Controller
                      _commentTextController.clear();
                    },
                    child: const Text("Cancle")),
                // Post Button
                TextButton(
                    onPressed: () {
                      // Add Comment
                      addComment(_commentTextController.text);

                      // pop box
                      Navigator.pop(context);
                    },
                    child: const Text("Post")),
              ],
            ));
  }

  // Delete Button methods
  void deletePost() {
    // show a dialog box asking for confirmation before deleting the post
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Delete Post").tr(),
              content:
                  const Text("Are you sure you want to delete this post?").tr(),
              actions: [
                // CANCEL BUTTON
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel").tr()),

                // DELETE BUTTON
                TextButton(
                    onPressed: () async {
                      // first, delete the comment from firestore
                      // (if you only delete the post, the comment will still be stored in firestore)
                      final commentDocs = await FirebaseFirestore.instance
                          .collection("User Posts")
                          .doc(widget.postId)
                          .collection("Comments")
                          .get();
                      for (var doc in commentDocs.docs) {
                        await FirebaseFirestore.instance
                            .collection("User Posts")
                            .doc(widget.postId)
                            .collection("Comments")
                            .doc(doc.id)
                            .delete();
                      }

                      // Then delete the post
                      FirebaseFirestore.instance
                          .collection("User Posts")
                          .doc(widget.postId)
                          .delete()
                          // ignore: avoid_print
                          .then((value) => print("post deleted"))
                          .catchError((error) =>
                              // ignore: avoid_print
                              print("failed to delete post: $error"));

                      // dismiss the dialog
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    child: const Text("Sure").tr()),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // wallpost
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // group of text(message + user email)
              _buildGroupOfText(),
              // Detele Button
              if (widget.user == currentUser.email)
                DeleteButton(onTap: deletePost)
            ],
          ),
          const SizedBox(
            height: 10,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Like(tym) + Like Count
              _buildIconLikeAndLikeCount(),
              const SizedBox(
                width: 10,
              ),
              // Icon Comment + Comment Count
              _buildIconCommentAndCommentCount()
            ],
          ),

          // Comments under the post(COMMENT!!!)
          _buildComment()
        ],
      ),
    );
  }

  Widget _buildGroupOfText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // message
        Text(
          widget.message,
          style: TextStyle(color: Colors.deepPurple.shade900),
        ),
        // user
        Row(
          children: [
            Text(
              widget.user,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              widget.time,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconLikeAndLikeCount() {
    return Column(
      children: [
        // Like Button
        LikeButton(isLiked: isLiked, onTap: toggleLike),
        const SizedBox(
          height: 5,
        ),
        // Like Count
        Text(
          widget.likes.length.toString(),
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildIconCommentAndCommentCount() {
    return Column(
      children: [
        // Comment Button
        CommentButton(onTap: showCommentDialog),
        const SizedBox(
          height: 5,
        ),
        // Comment count
        Text(
          widget.likes.length.toString(),
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildComment() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("User Posts")
            .doc(widget.postId)
            .collection("Comments")
            .orderBy("CommentTime", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // show loading circle if no data yet
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            shrinkWrap: true, // for nested lists
            physics: const NeverScrollableScrollPhysics(),
            children: snapshot.data!.docs.map((doc) {
              // get the comment
              final commentData = doc.data() as Map<String, dynamic>;

              // return the comment
              return Comment(
                  text: commentData['CommentText'],
                  user: commentData['CommentBy'],
                  time: formatDate(commentData['CommentTime']));
            }).toList(),
          );
        });
  }
}
