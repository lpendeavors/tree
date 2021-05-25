import 'package:flutter/material.dart';
import '../../util/asset_utils.dart';

class ProfileImageModal extends StatelessWidget {
  final List<String> options;

  const ProfileImageModal({Key key, this.options}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 45, 25, 25),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: new Row(
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
                          child: Text(
                            "Tree",
                            style: TextStyle(
                              fontFamily: 'Nirmala',
                              fontSize: 11.0,
                              color: Colors.black26,
                              fontWeight: FontWeight.normal,
                            ),
                          )),
                      SizedBox(width: 15.0),
                    ],
                  ),
                ),
                SizedBox(height: 5.0),
                Container(
                  height: 1.0,
                  width: double.infinity,
                  color: Colors.black12,
                ),
                Container(
                  color: Colors.white,
                  child: new ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: (MediaQuery.of(context).size.height / 2) +
                            (MediaQuery.of(context).orientation ==
                                    Orientation.landscape
                                ? 0
                                : (MediaQuery.of(context).size.height / 5))),
                    child: Scrollbar(
                      child: new ListView.builder(
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                        itemBuilder: (context, position) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              (position == 0
                                  ? Container()
                                  : Container(
                                      height: 1.0,
                                      width: double.infinity,
                                      color: Colors.black12,
                                    )),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop(options[position]);
                                },
                                child: new Container(
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
                                        Text(options[position],
                                            style: TextStyle(
                                              fontFamily: 'Nirmala',
                                              fontSize: 15.0,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.normal,
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        itemCount: options.length,
                        shrinkWrap: true,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 1.0,
                  width: double.infinity,
                  color: Colors.black12,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
