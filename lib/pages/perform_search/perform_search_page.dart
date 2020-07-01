import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_text_view/smart_text_view.dart';
import 'package:treeapp/data/event/firestore_event_repository.dart';
import 'package:treeapp/data/user/firestore_user_repository.dart';
import 'package:treeapp/models/old/event_entity.dart';
import 'package:treeapp/models/old/user_entity.dart';
import 'package:treeapp/pages/perform_search/perform_search_bloc.dart';
import 'package:treeapp/pages/perform_search/perform_search_state.dart';
import 'package:treeapp/util/asset_utils.dart';
import 'package:treeapp/util/event_utils.dart';

enum SearchType { CHURCH, USERS, EVENT }

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

class PerformSearch extends StatefulWidget {
  final SearchType searchType;
  final String searchFilter;
  final FirestoreUserRepository userRepository;
  final FirestoreEventRepository eventRepository;

  const PerformSearch({Key key,
    this.searchType = SearchType.USERS,
    this.searchFilter,
    @required this.userRepository,
    @required this.eventRepository
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
      userRepository: widget.userRepository,
      eventRepository: widget.eventRepository,
      searchType: widget.searchType
    );

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
      resizeToAvoidBottomPadding: true,
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
                                  color: Colors.black.withOpacity(.5)
                                ),
                                border: InputBorder.none
                              ),
                              style: TextStyle(
                                fontFamily: 'Nirmala',
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal,
                                color: Colors.black
                              ),
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
                            child: _showCancel ? Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                              child: Icon(
                                Icons.close,
                                color: Colors.black,
                                size: 20,
                              ),
                            ) : Container(),
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
        preferredSize: Size.fromHeight(10)
      ),
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
                  Navigator.pushReplacementNamed(
                    context,
                    '/search',
                    arguments: {'searchType': widget.searchType, 'filter': "CITY"}
                  );
                }),
                filterItem(Icons.home, 2, "STATE", onTap: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/search',
                    arguments: {'searchType': widget.searchType, 'filter': "STATE"}
                  );
                }),
                filterItem(church_icon, 3, "DENOMINATION", iconIsAsset: true, onTap: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/search',
                    arguments: {'searchType': widget.searchType, 'filter': "DENOMINATION"}
                  );
                }),
                filterItem(Icons.favorite, 4, "RELATIONSHIP", onTap: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/search',
                    arguments: {'searchType': widget.searchType, 'filter': "RELATIONSHIP"}
                  );
                }),
              ],
            ),
          ),
        )
      ],
    );
  }

  filterItem(icon, index, title, {Color color = Colors.white, bool iconIsAsset = false, onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: index == -1 ? Colors.transparent : Theme.of(context).primaryColor,
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
    }else{
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
        SearchState state = snapshot.data;

        if(state.isLoading){
          return Center(
            child: CircularProgressIndicator()
          );
        }

        if(state.results.length == 0){
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
                                shape: BoxShape.circle
                            ),
                          ),
                          Center(
                              child: Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white,
                              )
                          ),
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
                                      border: Border.all(color: Colors.white, width: 1)),
                                  child: Center(
                                    child: Text(
                                        "!",
                                        style: TextStyle(
                                            fontFamily: 'NirmalaB',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.0,
                                            color: Colors.white
                                        )
                                    ),
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
                          color: Colors.black
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      "Modify your search and try again",
                      style: TextStyle(
                          fontFamily: 'Nirmala',
                          fontWeight: FontWeight.normal,
                          fontSize: 14.0,
                          color: Colors.black.withOpacity(.5)
                      ),
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
                itemCount: state.results.length,
                itemBuilder: (context, index) {
                  var item = state.results[index];

                  if(item is UserEntity){
                    bool thisIsChurch = item.isChurch;
                    return InkWell(
                      onTap: (){
                        if(widget.searchType == SearchType.CHURCH){
                          Navigator.pop(context, item);
                        }else if(widget.searchType == SearchType.USERS){
                          Navigator.of(context).pushNamed(
                            '/profile',
                            arguments: item.uid,
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            GestureDetector(
                              onTap: (){},
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
                                                  )
                                              ),
                                            ),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          thisIsChurch ? item.churchName : item.fullName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        if (thisIsChurch)
                                          GestureDetector(
                                            onTap: (){},
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(0),
                                              child: AnimatedContainer(
                                                curve: Curves.ease,
                                                alignment: Alignment.center,
                                                duration: Duration(milliseconds: 300),
                                                padding: EdgeInsets.all(0),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).primaryColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                width: 25,
                                                height: 25,
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
                                                            width: 25,
                                                            height: 25,
                                                            child: Center(
                                                                child: Icon(
                                                                  Icons.person,
                                                                  color: Colors.white,
                                                                  size: 14,
                                                                )
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.all(4.0),
                                                            child: Image.asset(
                                                              church_icon,
                                                              width: 25,
                                                              height: 25,
                                                              color: Colors.white,
                                                              fit: BoxFit.cover,
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
                                          borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            "Denomination",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          SizedBox(width: 5.0),
                                          Text(
                                            thisIsChurch ? item.churchDenomination ?? "" : item.churchInfo?.churchDenomination ?? "",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black.withOpacity(.5),
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
                                            borderRadius: BorderRadius.circular(8)
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Image.asset(
                                              church_icon,
                                              height: 12,
                                              width: 12,
                                              color: Colors.black.withOpacity(.5),
                                            ),
                                            SizedBox(width: 5.0),
                                            Text(
                                              item.churchInfo?.churchName ?? "",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black.withOpacity(.5),
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
                                          borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.location_on,
                                            size: 12,
                                            color: Colors.black.withOpacity(.5),
                                          ),
                                          SizedBox(width: 5.0),
                                          Flexible(
                                            child: Text(
                                              thisIsChurch ? item.churchAddress ?? "" : item.city ?? "",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black.withOpacity(.5),
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
                  }else if(item is EventEntity){
                    List eventData = item.eventData;
                    DateTime startDate = DateTime.fromMillisecondsSinceEpoch(item.eventStartDate);
                    DateTime startTime = DateTime.fromMillisecondsSinceEpoch(item.eventStartTime);
                    TimeOfDay timeOfEvent = TimeOfDay.fromDateTime(startTime);

                    String eventTitle = item.eventTitle;
                    String eventDetails = item.eventDetails;
                    String location = item.location;
                    int eventIndex = item.eventIndex;
                    bool isSponsored = item.isSponsored;

                    return GestureDetector(
                      onTap: (){
                        Navigator.of(context).pushNamed(
                          '/event_details',
                          arguments: item.docId,
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.all(10),
                        decoration:
                        BoxDecoration(color: Colors.white, border: Border.all(color: Color(0xff14000000))),
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
                                  fit: BoxFit.cover, color: Colors.black.withOpacity(.1),
                                  colorBlendMode: BlendMode.darken,
                                  errorWidget: (_, s, o) {
                                    return Container(
                                      color: Theme.of(context).primaryColor,
                                      child: Center(
                                        child: Icon(
                                          Icons.refresh,
                                          color: Colors.white,
                                          size: 15,
                                        )
                                      ),
                                    );
                                  },
                                  placeholder: (_, s) {
                                    return Container(
                                      height: 200,
                                      width: double.infinity,
                                      color: Color(0xff8470ff).withOpacity(.1),
                                      child: Center(
                                        child: Opacity(
                                          opacity: .3,
                                          child: Image.asset(
                                            ic_launcher,
                                            width: 20,
                                            height: 20,
                                          )
                                        )
                                      ),
                                    );
                                  },
                                ),
                                Center(
                                  child: Container(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Flexible(
                                            child: Text(
                                                location,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: 'NirmalaB',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.0,
                                                color: Colors.white
                                              )
                                            )
                                          ),
                                          Container(
                                            height: 45,
                                            width: 45,
                                            padding: EdgeInsets.all(8),
                                            child: Image.asset(
                                              eventTypes[eventIndex].assetImage,
                                              height: 15,
                                              width: 15,
                                              color: eventTypes[eventIndex].useColor ? Colors.white : null,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(.5),
                                              shape: BoxShape.circle
                                            ),
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
                                      )
                                    ),
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
                                          color: Color(0xffe8e8e8).withOpacity(.5),
                                          borderRadius: BorderRadius.circular(12)
                                        ),
                                        child: Text(
                                          "🔥 Sponsored Event",
                                          style: TextStyle(
                                            fontFamily: 'Nirmala',
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12.0,
                                            color: Colors.black
                                          )
                                        ),
                                      )
                                    ),
                                  ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {}
                                  ),
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
                                    decoration:
                                    BoxDecoration(color: Color(0xffe8e8e8), shape: BoxShape.circle),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          months[startDate.month - 1],
                                          style: TextStyle(
                                            fontFamily: 'NirmalaB',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                            color: Theme.of(context).primaryColor
                                          ),
                                        ),
                                        Text(
                                          '${startDate.day}',
                                          style: TextStyle(
                                            fontFamily: 'NirmalaB',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.0,
                                            color: Colors.black
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            '(${timeOfEvent.format(context)}) ${eventTitle}',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontFamily: 'NirmalaB',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                              color: Colors.black
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            eventDetails,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(
                                                fontFamily: 'Nirmala',
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14.0,
                                                color: Colors.black.withOpacity(.7)
                                            )
                                          ),
                                        ],
                                      ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }else{
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
      }
    );
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
