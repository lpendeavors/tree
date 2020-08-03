import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import '../../widgets/image_holder.dart';
import '../../util/asset_utils.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import '../../generated/l10n.dart';
import './post_edit_bloc.dart';
import './post_edit_state.dart';

class EditPostPage extends StatefulWidget {
  final UserBloc userBloc;
  final EditPostBloc Function() initEditPostBloc;

  const EditPostPage({
    Key key,
    @required this.userBloc,
    @required this.initEditPostBloc,
  }) : super(key: key);

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  EditPostBloc _editPostBloc;
  List<StreamSubscription> _subscriptions;

  var _postMessageController = TextEditingController();
  var _editLoaded = false;

  @override
  void initState() {
    super.initState();

    _editPostBloc = widget.initEditPostBloc();
    _subscriptions = [
      widget.userBloc.loginState$
          .where((state) => state is Unauthenticated)
          .listen((event) =>
              Navigator.popUntil(context, ModalRoute.withName('/login'))),
      _editPostBloc.message$.listen(_showMessageResult),
    ];
  }

  void _showMessageResult(EditPostMessage message) {
    print('[DEBUG] EditPostMessage=$message');
    if (message is PostAddedMessageSuccess) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _editPostBloc.dispose();
    _postMessageController.dispose();
    print('[DEBUG] _EditPostPageState#dispose');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var s = S.of(context);

    return StreamBuilder<EditPostState>(
      stream: _editPostBloc.postEditState$,
      initialData: _editPostBloc.postEditState$.value,
      builder: (context, snapshot) {
        var existingPost = snapshot.data;

        if (existingPost.postItem != null && !_editLoaded) {
          _updateFields(existingPost.postItem);
          _editLoaded = true;
        }

        return WillPopScope(
          onWillPop: () async {
            // TODO: confirm exit
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              centerTitle: false,
              title: Text(
                'Share Something',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8),
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'POST',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () async {
                      _editPostBloc.savePost();
                    },
                  ),
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      StreamBuilder<bool>(
                        stream: _editPostBloc.postIsPublic$,
                        initialData: _editPostBloc.postIsPublic$.value,
                        builder: (context, snapshot) {
                          return Column(
                            children: <Widget>[
                              _menuItem(
                                title: 'Public',
                                description:
                                    'This post can be seen by anyone on Tree and can be shared by others',
                                onChange: () =>
                                    _editPostBloc.postIsPublicChanged(true),
                                active: snapshot.data,
                              ),
                              _menuItem(
                                title: 'Connections Only',
                                description:
                                    "This post can only be seen by your connections and can't be shared by others",
                                onChange: () =>
                                    _editPostBloc.postIsPublicChanged(false),
                                active: !snapshot.data,
                              ),
                            ],
                          );
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ImageHolder(
                              size: 40,
                              image: (widget.userBloc.loginState$.value
                                          as LoggedInUser)
                                      .image ??
                                  '',
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: TextFormField(
                                controller: _postMessageController,
                                onChanged: _editPostBloc.postMessageChanged,
                                keyboardType: TextInputType.multiline,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText:
                                      'Hi ${(widget.userBloc.loginState$.value as LoggedInUser).fullName} Share Something',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // if (data.postItem != null) ...[
                      // if (data.postItem.tagged.isNotEmpty) ...[
                      //   Container(
                      //     alignment: Alignment.centerLeft,
                      //     padding: EdgeInsets.all(5),
                      //     margin: EdgeInsets.all(8),
                      //     decoration: BoxDecoration(
                      //       color: Colors.grey[50],
                      //       borderRadius: BorderRadius.circular(15),
                      //       border: Border.all(
                      //         width: 0.5,
                      //         color: Colors.black.withOpacity(0.1),
                      //       ),
                      //     ),
                      //     child: Wrap(
                      //       spacing: 5,
                      //       alignment: WrapAlignment.start,
                      //       crossAxisAlignment: WrapCrossAlignment.start,
                      //       runAlignment: WrapAlignment.start,
                      //       children: List.generate(
                      //         data.postItem.tagged.length,
                      //         (index) {
                      //           return Chip(
                      //             avatar: ImageHolder(
                      //               size: 30,
                      //               image: '',
                      //             ),
                      //             label: Text(
                      //               data.postItem.tagged[index],
                      //               style: TextStyle(
                      //                 fontSize: 10,
                      //               ),
                      //             ),
                      //           );
                      //         },
                      //       ),
                      //     ),
                      //   ),
                      // ],
                      Divider(height: 25),
                      StreamBuilder<List<String>>(
                          stream: _editPostBloc.postMedia$,
                          initialData: _editPostBloc.postMedia$.value,
                          builder: (context, snapshot) {
                            var media = snapshot.data;

                            if (media.isNotEmpty) {
                              return Container(
                                height: 350,
                                margin: EdgeInsets.only(
                                  top: 15,
                                  bottom: 10,
                                ),
                                child: PageView.builder(
                                  controller: PageController(
                                    viewportFraction: 0.9,
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: media.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () async {
                                        // TODO: preview if video
                                      },
                                      child: Stack(
                                        alignment: Alignment.topLeft,
                                        children: <Widget>[
                                          StreamBuilder(
                                            stream:
                                                _editPostBloc.postMediaType$,
                                            initialData: _editPostBloc
                                                .postMediaType$.value,
                                            builder: (context, snapshot) {
                                              var mediaType =
                                                  snapshot.data ?? null;

                                              if (mediaType - 1 ==
                                                  PostMediaType.image.index) {
                                                return Container(
                                                  margin: EdgeInsets.only(
                                                      top: 10, left: 5),
                                                  padding: EdgeInsets.all(2),
                                                  height: 350,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      width: 0.25,
                                                      color: Colors.grey
                                                          .withOpacity(0.6),
                                                    ),
                                                  ),
                                                  child: Container(
                                                    height: 350,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    margin: EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey
                                                          .withOpacity(0.5),
                                                      image: DecorationImage(
                                                        image: _editLoaded
                                                            ? NetworkImage(
                                                                media[0],
                                                              )
                                                            : FileImage(
                                                                File(media[0]),
                                                              ),
                                                        fit: BoxFit.contain,
                                                        alignment:
                                                            Alignment.center,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }

                                              if (mediaType - 1 ==
                                                  PostMediaType.video.index) {
                                                return Container(
                                                  margin: EdgeInsets.only(
                                                      top: 10, left: 5),
                                                  padding: EdgeInsets.all(2),
                                                  height: 300,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: StreamBuilder<String>(
                                                    stream: _editPostBloc
                                                        .postVideoThumbnail$,
                                                    initialData: _editPostBloc
                                                        .postVideoThumbnail$
                                                        .value,
                                                    builder:
                                                        (context, snapshot) {
                                                      var thumbnail =
                                                          snapshot.data ?? '';

                                                      if (thumbnail
                                                          .isNotEmpty) {
                                                        return Container(
                                                          height: 300,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          margin:
                                                              EdgeInsets.all(2),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5),
                                                            image:
                                                                DecorationImage(
                                                              image: FileImage(
                                                                File(media[0]),
                                                              ),
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: Container(
                                                              height: 50,
                                                              width: 50,
                                                              child: Icon(
                                                                Icons
                                                                    .play_arrow,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.8),
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1.5,
                                                                ),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }

                                                      return Container();
                                                    },
                                                  ),
                                                );
                                              }

                                              return Container();
                                            },
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              media.remove(media[0]);
                                              _editPostBloc
                                                  .postMediaChanged(media);
                                              _editPostBloc
                                                  .postMediaTypeChanged(null);
                                            },
                                            child: _editLoaded
                                                ? Container()
                                                : Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 20, top: 20),
                                                    child: Container(
                                                      height: 30,
                                                      width: 30,
                                                      child: Icon(
                                                        Icons.clear,
                                                        size: 15,
                                                        color: Colors.white,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else {
                              return Container();
                            }
                          }),
                      // ],
                    ],
                  ),
                ),
                Container(
                  height: 60,
                  color: Colors.white,
                  margin: EdgeInsets.all(15),
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        onPressed: () async {
                          var image = await ImagePicker.pickImage(
                              source: ImageSource.gallery);
                          if (image != null) {
                            var cropped = await ImageCropper.cropImage(
                                sourcePath: image.path);
                            _editPostBloc.postMediaChanged([cropped.path]);
                            _editPostBloc.postMediaTypeChanged(
                                PostMediaType.image.index);
                          }
                        },
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 20,
                              width: 20,
                              child: Icon(
                                Icons.camera_alt,
                                size: 15,
                                color: Colors.white,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Photos',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RaisedButton(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        onPressed: () async {
                          var video = await FilePicker.getFilePath(
                            type: FileType.video,
                          );
                          if (video != null) {
                            var thumbnail = await VideoThumbnail.thumbnailFile(
                              video: video,
                              thumbnailPath:
                                  (await getTemporaryDirectory()).path,
                              imageFormat: ImageFormat.PNG,
                              maxHeight: 350,
                              quality: 75,
                            );

                            _editPostBloc.postMediaChanged([video]);
                            _editPostBloc.postVideoThumbnailChanged(thumbnail);
                            _editPostBloc.postMediaTypeChanged(
                                PostMediaType.video.index);
                          }
                        },
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 20,
                              width: 20,
                              child: Icon(
                                Icons.videocam,
                                size: 15,
                                color: Colors.white,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Videos',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RaisedButton(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        onPressed: () async {
                          var tagged = await Navigator.of(context).pushNamed(
                            '/tag_connections',
                          );

                          if (tagged != null)
                            _editPostBloc.taggedChanged(tagged);
                        },
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 20,
                              width: 20,
                              child: Icon(
                                Icons.group_add,
                                size: 15,
                                color: Colors.white,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Tagging',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateFields(FeedPostItem post) {
    _editPostBloc.postMessageChanged(post.message);
    _postMessageController.text = post.message;

    _editPostBloc.postIsPublicChanged(post.isPublic);

    if (post.images.isNotEmpty) {
      _editPostBloc.postMediaTypeChanged(PostMediaType.image.index);
      _editPostBloc.postMediaChanged(post.images);
    }

    if (post.videos.isNotEmpty) {
      _editPostBloc.postMediaTypeChanged(PostMediaType.video.index);
      _editPostBloc.postMediaChanged(post.videos);
    }

    if (post.tagged.isNotEmpty) {
      // _editPostBloc.taggedChanged(post.tagged);
    }
  }

  Widget _menuItem({
    String title,
    String description,
    Function onChange,
    bool active,
  }) {
    return InkWell(
      onTap: onChange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            color: active ? Colors.grey[50] : null,
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                if (active)
                  Container(
                    height: 20,
                    width: 20,
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                    child: Container(
                      height: 20,
                      width: 20,
                      child: Icon(
                        Icons.check,
                        size: 10,
                        color: Colors.white,
                      ),
                      decoration: BoxDecoration(
                          color: Colors.green[700],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black.withOpacity(0.4),
                          )),
                    ),
                  )
                else
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.black.withOpacity(0.04),
          ),
        ],
      ),
    );
  }
}
