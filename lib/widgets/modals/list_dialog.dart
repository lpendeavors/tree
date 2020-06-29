import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:treeapp/generated/l10n.dart';
import 'package:treeapp/util/asset_utils.dart';

class ListDialog extends StatelessWidget {
  String title;
  var items;
  List images;
  bool isIcon;
  bool useTint;
  bool usePosition;
  BuildContext context;

  ListDialog(items, {
    title,
    images,
    bool isIcon = false,
    bool useTint = true,
    bool usePosition = true
  }) {
    this.title = title;
    this.items = items;
    this.images = images == null ? List() : images;
    this.isIcon = isIcon;
    this.useTint = useTint;
    this.usePosition = usePosition;
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Stack(fit: StackFit.expand, children: <Widget>[
      GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          color: Colors.black.withOpacity(.8),
        ),
      ),
      page()
    ]);
  }

  page() {
    var s = S.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 45, 25, 25),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SizedBox(width: 15.0),
                      Image.asset(
                        ic_launcher,
                        height: 20,
                        width: 20,
                      ),
                      SizedBox(width: 10.0),
                      Flexible(
                        flex: 1,
                        child: title == null
                        ? Text(
                          s.app_title,
                          style: TextStyle(
                            fontFamily: 'Nirmala',
                            fontSize: 11.0,
                            fontWeight: FontWeight.normal,
                            color: Colors.black.withOpacity(.1)
                          )
                        ) : Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'NirmalaB',
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                          )
                        ),
                      ),
                      SizedBox(width: 15.0),
                    ],
                  ),
                ),
                SizedBox(height: 5.0),
                Container(
                  height: 0.5,
                  width: double.infinity,
                  color: Colors.black.withOpacity(.1),
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                ),
                Container(
                  color: Colors.white,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: (MediaQuery.of(context).size.height / 2) + (MediaQuery.of(context).orientation == Orientation.landscape ? 0 : (MediaQuery.of(context).size.height / 5))),
                    child: Scrollbar(
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                        itemBuilder: (context, position) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              position == 0
                              ? Container()
                              : Container(
                                  height: 0.5,
                                  width: double.infinity,
                                  color: Colors.black.withOpacity(.1),
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop(usePosition ? position : items[position]);
                                },
                                child: Container(
                                  color: Colors.white,
                                  width: double.infinity,
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.fromLTRB(0, 15, 0, 15),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: <Widget>[
                                        images.isEmpty ? Container() : isIcon ? Icon(
                                          images[position],
                                          size: 17,
                                          color: !useTint ? null : Colors.black.withOpacity(.3),
                                        ) : Image.asset(
                                          images[position],
                                          width: 17,
                                          height: 17,
                                          color: !useTint ? null : Colors.black.withOpacity(.3),
                                        ),
                                        images.isNotEmpty ? SizedBox(width: 10.0) : Container(),
                                        Text(
                                          items[position],
                                          style: TextStyle(
                                            fontFamily: 'Nirmala',
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black.withOpacity(.8)
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        itemCount: items.length,
                        shrinkWrap: true,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 0.5,
                  width: double.infinity,
                  color: Colors.black.withOpacity(.1),
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
