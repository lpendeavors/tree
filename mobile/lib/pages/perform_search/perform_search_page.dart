import 'dart:math';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_text_view/smart_text_view.dart';
import 'package:treeapp/data/event/firestore_event_repository.dart';
import 'package:treeapp/data/user/firestore_user_repository.dart';
import 'package:treeapp/data/group/firestore_group_repository.dart';
import 'package:treeapp/models/old/event_entity.dart';
import 'package:treeapp/models/old/group_member.dart';
import 'package:treeapp/models/old/user_entity.dart';
import 'package:treeapp/models/old/group_entity.dart';
import 'package:treeapp/pages/perform_search/perform_search_bloc.dart';
import 'package:treeapp/pages/perform_search/perform_search_state.dart';
import 'package:treeapp/user_bloc/user_login_state.dart';
import 'package:treeapp/util/asset_utils.dart';
import 'package:treeapp/util/event_utils.dart';
import '../../user_bloc/user_bloc.dart';
import '../../models/old/user_chat_data.dart';
import '../../models/old/user_chat_group_member.dart';

enum SearchType { CHURCH, USERS, EVENT, CHAT }

List months = [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUN',
  'JUL',
  'AUG',
  'SEP',
  'OCT',
  'NOV',
  'DEC',
];

const int CHAT_TYPE_TEXT = 0;
const int CHAT_TYPE_IMAGE = 1;
const int CHAT_TYPE_GIF = 2;
const int CHAT_TYPE_DOC = 3;
const int CHAT_TYPE_VIDEO = 4;

class PerformSearch extends StatefulWidget {
  final SearchType searchType;
  final String searchFilter;
  final FirestoreUserRepository userRepository;
  final FirestoreEventRepository eventRepository;
  final FirestoreGroupRepository groupRepository;
  final UserBloc userBloc;

  const PerformSearch({
    Key key,
    this.searchType = SearchType.USERS,
    this.searchFilter,
    @required this.userBloc,
    @required this.userRepository,
    @required this.eventRepository,
    @required this.groupRepository,
  }) : super(key: key);

  @override
  _PerformSearchState createState() => _PerformSearchState();
}

class _PerformSearchState extends State<PerformSearch> {
  var searchController = TextEditingController();
  var scrollController = ScrollController();
  FocusNode focusNode = FocusNode();
  bool _showCancel = false;

  SearchBloc _searchBloc;

  @override
  void initState() {
    super.initState();

    _searchBloc = SearchBloc(
        userBloc: widget.userBloc,
        userRepository: widget.userRepository,
        eventRepository: widget.eventRepository,
        groupRepository: widget.groupRepository,
        searchType: widget.searchType);

    searchController.addListener(listener);
    scrollController.addListener(() {
      if (scrollController != null) {
        if (scrollController.position.activity.isScrolling) {
          focusNode.unfocus();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: searchAppBar(),
      body: searchBody(),
    );
  }

  searchAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
      flexibleSpace: PreferredSize(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 5,
                right: 5,
                top: 5,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  CloseButton(),
                  SizedBox(width: 5.0),
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(width: 10.0),
                            GestureDetector(
                              onLongPress: () {},
                              child: Icon(
                                Icons.search,
                                color: Colors.black.withOpacity(.5),
                                size: 17,
                              ),
                            ),
                            SizedBox(width: 10.0),
                            Flexible(
                              flex: 1,
                              child: TextField(
                                textInputAction: TextInputAction.search,
                                focusNode: focusNode,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                autofocus: true,
                                decoration: InputDecoration.collapsed(
                                    hintText: "Search by name",
                                    hintStyle: TextStyle(
                                        fontFamily: 'Nirmala',
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black.withOpacity(.5)),
                                    border: InputBorder.none),
                                style: TextStyle(
                                    fontFamily: 'Nirmala',
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black),
                                controller: searchController,
                                cursorColor: Theme.of(context).primaryColor,
                                cursorWidth: 1,
                                keyboardType: TextInputType.text,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  searchController.text = "";
                                });
                              },
                              child: _showCancel
                                  ? Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 15, 0),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                    )
                                  : Container(),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          preferredSize: Size.fromHeight(10)),
      /*bottom: widget.searchType == SearchType.USERS ? PreferredSize(
        child: Container(
          color: Colors.white,
          child: filterLayout(),
        ),
        preferredSize: Size.fromHeight(45)
      ) : PreferredSize(
        child: Container(),
        preferredSize: Size.fromHeight(0),
      )*/
    );
  }

  filterLayout() {
    return Row(
      children: <Widget>[
        filterItem(Icons.sort, -1, "FILTERS", color: Colors.black),
        Flexible(
          child: Container(
            height: 50,
            padding: EdgeInsets.only(top: 5),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                filterItem(Icons.location_city, 0, "CITY", onTap: () {
                  Navigator.pushReplacementNamed(context, '/search',
                      arguments: {
                        'searchType': widget.searchType,
                        'filter': "CITY"
                      });
                }),
                filterItem(Icons.home, 2, "STATE", onTap: () {
                  Navigator.pushReplacementNamed(context, '/search',
                      arguments: {
                        'searchType': widget.searchType,
                        'filter': "STATE"
                      });
                }),
                filterItem(church_icon, 3, "DENOMINATION", iconIsAsset: true,
                    onTap: () {
                  Navigator.pushReplacementNamed(context, '/search',
                      arguments: {
                        'searchType': widget.searchType,
                        'filter': "DENOMINATION"
                      });
                }),
                filterItem(Icons.favorite, 4, "RELATIONSHIP", onTap: () {
                  Navigator.pushReplacementNamed(context, '/search',
                      arguments: {
                        'searchType': widget.searchType,
                        'filter': "RELATIONSHIP"
                      });
                }),
              ],
            ),
          ),
        )
      ],
    );
  }

  filterItem(icon, index, title,
      {Color color = Colors.white, bool iconIsAsset = false, onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color:
            index == -1 ? Colors.transparent : Theme.of(context).primaryColor,
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(5),
        child: Row(
          children: <Widget>[
            if (iconIsAsset)
              Image.asset(
                icon,
                height: 15,
                width: 15,
                alignment: Alignment.center,
                color: color,
              )
            else
              Icon(
                icon,
                color: color,
                size: 18,
              ),
            SizedBox(width: 5.0),
            Text(
              title,
              style: TextStyle(color: color),
            )
          ],
        ),
      ),
    );
  }

  listener() {
    String searchText = searchController.text.trim();

    if (searchText.isEmpty) {
      if (_showCancel) {
        setState(() {
          _showCancel = false;
        });
      }
    } else {
      startSearch(searchText);
    }
  }

  startSearch(searchText) {
    _showCancel = true;
    String searchText = searchController.text.trim().toLowerCase();
    _searchBloc.search(searchText);
  }

  searchBody() {
    return StreamBuilder<SearchState>(
        stream: _searchBloc.searchState$,
        initialData: _searchBloc.searchState$.value,
        builder: (context, snapshot) {
          SearchState state = snapshot.data ??
              SearchState(
                  results: [], user: null, isLoading: false, error: null);
          var results = state.results;

          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (widget.searchType == SearchType.CHAT) {
            print('CHAT, change results');
            results = results.where((item) {
              item = (item as GroupEntity);
              String groupId = item.groupId;
              List<ChatData> myChats = state.user.myChatsList13;
              bool matching = false;

              if (!item.isGroupPrivate) {
                return true;
              }

              print(groupId);
              for (ChatData chat in myChats) {
                String chatId = chat.chatId;
                if (groupId == chatId) {
                  print(chatId);
                  matching = true;
                  break;
                }
              }

              return matching;
            }).toList();
          }

          if (results.length == 0) {
            return Container(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 50,
                        height: 50,
                        child: Stack(
                          children: <Widget>[
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: Color(0xffff0000),
                                  shape: BoxShape.circle),
                            ),
                            Center(
                                child: Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.white,
                            )),
                            Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(),
                                    flex: 1,
                                  ),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: Color(0xffb20000),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 1)),
                                    child: Center(
                                      child: Text("!",
                                          style: TextStyle(
                                              fontFamily: 'NirmalaB',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0,
                                              color: Colors.white)),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        "No results found",
                        style: TextStyle(
                            fontFamily: 'NirmalaB',
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        "Modify your search and try again",
                        style: TextStyle(
                            fontFamily: 'Nirmala',
                            fontWeight: FontWeight.normal,
                            fontSize: 14.0,
                            color: Colors.black.withOpacity(.5)),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
              ),
            );
          }

          return Column(
            children: <Widget>[
              Flexible(
                child: ListView.separated(
                  controller: scrollController,
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    var item = results[index];
                    var user = state.user;

                    if (item is UserEntity) {
                      bool thisIsChurch = item.isChurch;
                      return InkWell(
                        onTap: () {
                          if (widget.searchType == SearchType.CHURCH) {
                            Navigator.pop(context, item);
                          } else if (widget.searchType == SearchType.USERS) {
                            Navigator.of(context).pushNamed(
                              '/profile',
                              arguments: item.uid,
                            );
                          }
                        },
                        onLongPress: () async {
                          if ((widget.userBloc.loginState$.value
                                  as LoggedInUser)
                              .isAdmin) {
                            await showDialog(
                              context: context,
                              builder: (context) {
                                var alreadyAdmin = item.isAdmin ?? false;
                                var adminAction = alreadyAdmin
                                    ? 'Remove this user from'
                                    : 'Add this user to';
                                return AlertDialog(
                                  title: Text('Admin'),
                                  content: Text('$adminAction admins?'),
                                  actions: [
                                    FlatButton(
                                      child: Text('Confirm'),
                                      onPressed: () {
                                        if (alreadyAdmin) {
                                          _searchBloc.removeAdmin(item.uid);
                                        } else {
                                          _searchBloc.makeAdmin(item.uid);
                                        }
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {},
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(0),
                                  child: AnimatedContainer(
                                    curve: Curves.ease,
                                    alignment: Alignment.center,
                                    duration: Duration(milliseconds: 300),
                                    padding: EdgeInsets.all(0),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(.02),
                                      shape: BoxShape.circle,
                                    ),
                                    width: 60,
                                    height: 60,
                                    child: Stack(
                                      children: <Widget>[
                                        Card(
                                          margin: EdgeInsets.all(0),
                                          shape: CircleBorder(),
                                          clipBehavior: Clip.antiAlias,
                                          color: Colors.transparent,
                                          elevation: .5,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: <Widget>[
                                              Container(
                                                width: 60,
                                                height: 60,
                                                child: Center(
                                                    child: Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                  size: 14,
                                                )),
                                              ),
                                              if (item.image != null &&
                                                  item.image.isNotEmpty)
                                                CachedNetworkImage(
                                                  width: 60,
                                                  height: 60,
                                                  imageUrl: item.image ?? "",
                                                  fit: BoxFit.cover,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15.0),
                              Flexible(
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            thisIsChurch ?? false
                                                ? item.churchName ?? ""
                                                : item.fullName ?? "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          if (thisIsChurch)
                                            GestureDetector(
                                              onTap: () {},
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                                child: AnimatedContainer(
                                                  curve: Curves.ease,
                                                  alignment: Alignment.center,
                                                  duration: Duration(
                                                      milliseconds: 300),
                                                  padding: EdgeInsets.all(0),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  width: 25,
                                                  height: 25,
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Card(
                                                        margin:
                                                            EdgeInsets.all(0),
                                                        shape: CircleBorder(),
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        color:
                                                            Colors.transparent,
                                                        elevation: .5,
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: <Widget>[
                                                            Container(
                                                              width: 25,
                                                              height: 25,
                                                              child: Center(
                                                                  child: Icon(
                                                                Icons.person,
                                                                color: Colors
                                                                    .white,
                                                                size: 14,
                                                              )),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(4.0),
                                                              child:
                                                                  Image.asset(
                                                                church_icon,
                                                                width: 25,
                                                                height: 25,
                                                                color: Colors
                                                                    .white,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          SizedBox(height: 5.0),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              "Denomination",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(width: 5.0),
                                            Text(
                                              thisIsChurch
                                                  ? item.churchDenomination ??
                                                      ""
                                                  : item.churchInfo
                                                          ?.churchDenomination ??
                                                      "",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black
                                                    .withOpacity(.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      if (!thisIsChurch) ...[
                                        SizedBox(height: 5.0),
                                        Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Image.asset(
                                                church_icon,
                                                height: 12,
                                                width: 12,
                                                color: Colors.black
                                                    .withOpacity(.5),
                                              ),
                                              SizedBox(width: 5.0),
                                              Text(
                                                item.churchInfo?.churchName ??
                                                    "",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black
                                                      .withOpacity(.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 5.0),
                                      ],
                                      Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.location_on,
                                              size: 12,
                                              color:
                                                  Colors.black.withOpacity(.5),
                                            ),
                                            SizedBox(width: 5.0),
                                            Flexible(
                                              child: Text(
                                                thisIsChurch
                                                    ? item.churchAddress ?? ""
                                                    : item.city ?? "",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black
                                                      .withOpacity(.5),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (item is EventEntity) {
                      List eventData = item.eventData;
                      DateTime startDate = DateTime.fromMillisecondsSinceEpoch(
                          item.eventStartDate);
                      DateTime startTime = DateTime.fromMillisecondsSinceEpoch(
                          item.eventStartTime);
                      TimeOfDay timeOfEvent = TimeOfDay.fromDateTime(startTime);

                      String eventTitle = item.eventTitle;
                      String eventDetails = item.eventDetails;
                      String location = item.location;
                      int eventIndex = item.eventIndex;
                      bool isSponsored = item.isSponsored;

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/event_details',
                            arguments: item.docId,
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Color(0xff14000000))),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Stack(
                                alignment: Alignment.bottomCenter,
                                children: <Widget>[
                                  CachedNetworkImage(
                                    imageUrl: eventData[0].imageUrl,
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.topCenter,
                                    fit: BoxFit.cover,
                                    color: Colors.black.withOpacity(.1),
                                    colorBlendMode: BlendMode.darken,
                                    errorWidget: (_, s, o) {
                                      return Container(
                                        color: Theme.of(context).primaryColor,
                                        child: Center(
                                            child: Icon(
                                          Icons.refresh,
                                          color: Colors.white,
                                          size: 15,
                                        )),
                                      );
                                    },
                                    placeholder: (_, s) {
                                      return Container(
                                        height: 200,
                                        width: double.infinity,
                                        color:
                                            Color(0xff8470ff).withOpacity(.1),
                                        child: Center(
                                            child: Opacity(
                                                opacity: .3,
                                                child: Image.asset(
                                                  ic_launcher,
                                                  width: 20,
                                                  height: 20,
                                                ))),
                                      );
                                    },
                                  ),
                                  Center(
                                    child: Container(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Flexible(
                                                child: Text(location,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontFamily: 'NirmalaB',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14.0,
                                                        color: Colors.white))),
                                            Container(
                                              height: 45,
                                              width: 45,
                                              padding: EdgeInsets.all(8),
                                              child: Image.asset(
                                                eventTypes[eventIndex]
                                                    .assetImage,
                                                height: 15,
                                                width: 15,
                                                color: eventTypes[eventIndex]
                                                        .useColor
                                                    ? Colors.white
                                                    : null,
                                              ),
                                              decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(.5),
                                                  shape: BoxShape.circle),
                                            ),
                                          ],
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.black.withOpacity(0.1),
                                              Colors.black.withOpacity(0.9)
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          )),
                                    ),
                                  ),
                                  if (isSponsored)
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                                color: Color(0xffe8e8e8)
                                                    .withOpacity(.5),
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: Text("🔥 Sponsored Event",
                                                style: TextStyle(
                                                    fontFamily: 'Nirmala',
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12.0,
                                                    color: Colors.black)),
                                          )),
                                    ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                        icon: Icon(
                                          Icons.more_vert,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {}),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      height: 50,
                                      width: 50,
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: Color(0xffe8e8e8),
                                          shape: BoxShape.circle),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            months[startDate.month - 1],
                                            style: TextStyle(
                                                fontFamily: 'NirmalaB',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                          Text(
                                            '${startDate.day}',
                                            style: TextStyle(
                                                fontFamily: 'NirmalaB',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.0,
                                                color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Flexible(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          '(${timeOfEvent.format(context)}) ${eventTitle}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontFamily: 'NirmalaB',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                              color: Colors.black),
                                        ),
                                        SizedBox(height: 10),
                                        Text(eventDetails,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(
                                                fontFamily: 'Nirmala',
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14.0,
                                                color: Colors.black
                                                    .withOpacity(.7))),
                                      ],
                                    ))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (item is GroupEntity) {
                      GroupEntity item2 = item;

                      String groupId = item2.groupId;
                      List<ChatData> myChats = user.myChatsList13;

                      List<dynamic> members;
                      var isConversation;
                      var isRoom;
                      var isGroup;

                      var groupImage = item2.groupImage ?? "";
                      var groupName = item2.groupName ?? "";
                      var groupDescription = item2.groupDescription ?? "";

                      if (!item2.isGroupPrivate) {
                        isConversation = item2.isConversation;
                        isRoom = item2.isRoom;
                        isGroup = item2.isGroup;

                        if (isGroup && isConversation) {
                          members = item2.groupMembers;
                        }
                      } else {
                        for (ChatData chat in myChats) {
                          String chatId = chat.chatId;
                          if (groupId == chatId) {
                            isConversation = chat.isConversation;
                            isRoom = chat.isRoom;
                            isGroup = chat.isGroup;

                            if (isGroup && isConversation) {
                              members = chat.groupMembers;
                            }
                            break;
                          }
                        }
                      }

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/chat_room_details',
                            arguments: item.documentId,
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  if (members != null &&
                                      members.length > 2 &&
                                      isConversation)
                                    Container(
                                      height: 40,
                                      width: 40,
                                      child: Stack(
                                        children: List.generate(
                                            members.length > 3
                                                ? 3
                                                : members.length, (int i) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                                left: 5 + (i * 4.0)),
                                            child: GestureDetector(
                                              onTap: () {},
                                              child: ClipRRect(
                                                child: AnimatedContainer(
                                                  curve: Curves.ease,
                                                  alignment: Alignment.center,
                                                  duration: Duration(
                                                      milliseconds: 300),
                                                  padding: EdgeInsets.all(
                                                      i == 1 ? 0 : .5),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xfff79836),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  width: 30,
                                                  height: 30,
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Card(
                                                        margin:
                                                            EdgeInsets.all(0),
                                                        shape: CircleBorder(),
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        color:
                                                            Colors.transparent,
                                                        elevation: .5,
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: <Widget>[
                                                            Container(
                                                              width: 30,
                                                              height: 30,
                                                              child: Center(
                                                                  child: Icon(
                                                                Icons.people,
                                                                color: Colors
                                                                    .white,
                                                                size: 14,
                                                              )),
                                                            ),
                                                            CachedNetworkImage(
                                                              width: 30,
                                                              height: 30,
                                                              imageUrl:
                                                                  groupImage,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: EdgeInsets.all(3),
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: ClipRRect(
                                          child: AnimatedContainer(
                                            curve: Curves.ease,
                                            alignment: Alignment.center,
                                            duration:
                                                Duration(milliseconds: 300),
                                            padding: EdgeInsets.all(0),
                                            decoration: BoxDecoration(
                                              color: Color(0xfff79836),
                                              shape: BoxShape.circle,
                                            ),
                                            width: 40,
                                            height: 40,
                                            child: Stack(
                                              children: <Widget>[
                                                Card(
                                                  margin: EdgeInsets.all(0),
                                                  shape: CircleBorder(),
                                                  clipBehavior: Clip.antiAlias,
                                                  color: Colors.transparent,
                                                  elevation: .5,
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: <Widget>[
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        child: Center(
                                                            child: Icon(
                                                          Icons.people,
                                                          color: Colors.white,
                                                          size: 14,
                                                        )),
                                                      ),
                                                      CachedNetworkImage(
                                                        width: 40,
                                                        height: 40,
                                                        imageUrl: groupImage,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              width: 1,
                                              color: Color(0xfff79836))),
                                    ),
                                  SizedBox(width: 10),
                                  Flexible(
                                    flex: 1,
                                    fit: FlexFit.tight,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Flexible(
                                              flex: 1,
                                              fit: FlexFit.tight,
                                              child: Row(
                                                children: <Widget>[
                                                  Flexible(
                                                    child: Text(
                                                      groupName,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'NirmalaB',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14.0,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                  if (isConversation &&
                                                      members.length > 2)
                                                    Container(
                                                      margin: const EdgeInsets
                                                          .fromLTRB(6, 0, 0, 0),
                                                      padding: const EdgeInsets
                                                          .fromLTRB(6, 2, 6, 2),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xff5c4eb2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(25),
                                                          border: Border.all(
                                                              color: Color(
                                                                  0xfffff3f3f3),
                                                              width: 1)),
                                                      child: Text(
                                                        "Conversation",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'NirmalaB',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12.0,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )
                                                  else if (isRoom)
                                                    Container(
                                                      margin: const EdgeInsets
                                                          .fromLTRB(6, 0, 0, 0),
                                                      padding: const EdgeInsets
                                                          .fromLTRB(6, 2, 6, 2),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xff5c4eb2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(25),
                                                          border: Border.all(
                                                              color: Color(
                                                                  0xfffff3f3f3),
                                                              width: 1)),
                                                      child: Text(
                                                        "Chat Room",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'NirmalaB',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12.0,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )
                                                  else if (isGroup &&
                                                      !isConversation)
                                                    Container(
                                                      margin: const EdgeInsets
                                                          .fromLTRB(6, 0, 0, 0),
                                                      padding: const EdgeInsets
                                                          .fromLTRB(6, 2, 6, 2),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xff5c4eb2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(25),
                                                          border: Border.all(
                                                              color: Color(
                                                                  0xfffff3f3f3),
                                                              width: 1)),
                                                      child: Text(
                                                        "Group",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'NirmalaB',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12.0,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Color(0xff0f534949),
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              border: Border.all(
                                                  color: Color(0xfffff3f3f3),
                                                  width: 1)),
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      6, 2, 6, 2),
                                              child: Text(
                                                groupDescription,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'Nirmala',
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12.0,
                                                    color: Colors.black
                                                        .withOpacity(.4)),
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Container(
                                height: 0.5,
                                width: double.infinity,
                                color: Colors.black.withOpacity(.1),
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 0,
                      color: Colors.grey[200],
                    );
                  },
                ),
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    searchController?.removeListener(listener);
    searchController?.dispose();
    scrollController?.dispose();
    _searchBloc.dispose();
    super.dispose();
  }
}
