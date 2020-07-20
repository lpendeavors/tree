import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {

  final String title;
  final String message;
  final String btnTitle;
  final VoidCallback onClick;

  const InfoDialog({
    Key key,
    this.title,
    this.message,
    this.btnTitle,
    this.onClick
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(15),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.update,
                    color: Colors.red,
                    size: 50,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'NirmalaB',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    message,
                    style: TextStyle(
                      fontFamily: 'Nirmala',
                      fontWeight: FontWeight.normal,
                      fontSize: 13,
                      color: Colors.black.withOpacity(.4)
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.0),
                  FlatButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      Navigator.pop(context);
                      onClick();
                      return;
                    },
                    child: Text(
                      btnTitle,
                      style: TextStyle(
                        fontFamily: 'NirmalaB',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white
                      )
                    )
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40, right: 15),
            child: FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Skip",
                  style: TextStyle(
                    fontFamily: 'NirmalaB',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black
                  )
                )
            ),
          )
        ],
      ),
    );
  }
}