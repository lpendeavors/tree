import 'dart:async';

import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import '../../widgets/image_holder.dart';
import '../../user_bloc/user_login_state.dart';
import '../../user_bloc/user_bloc.dart';
import '../../generated/l10n.dart';
import './poll_edit_bloc.dart';
import './poll_edit_state.dart';

class EditPollPage extends StatefulWidget {
  final UserBloc userBloc;
  final EditPollBloc Function() initEditPollBloc;

  const EditPollPage({
    Key key,
    @required this.userBloc,
    @required this.initEditPollBloc,
  }) : super(key: key);

  @override
  _EditPollPageState createState() => _EditPollPageState();
}

class _EditPollPageState extends State<EditPollPage> {
  EditPollBloc _editPollBloc;
  List<StreamSubscription> _subscriptions;

  var _pollMessageController = TextEditingController();
  var _pollAnswerControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  var _editLoaded = false;

  @override
  void initState() {
    super.initState();

    _editPollBloc = widget.initEditPollBloc();
    _subscriptions = [
      widget.userBloc.loginState$
          .where((state) => state is Unauthenticated)
          .listen((_) =>
              Navigator.popUntil(context, ModalRoute.withName('/login'))),
      _editPollBloc.message$.listen(_showMessageResult),
    ];
  }

  void _showMessageResult(EditPollMessage message) {
    print('[DEBUG] EditPollMessage=$message');
    if (message is PollAddedMessageSuccess) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _editPollBloc.dispose();
    print('[DEBUG] _EditPollPageState#dispose');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var s = S.of(context);

    _addDefaultAnswers();

    return StreamBuilder<EditPollState>(
      stream: _editPollBloc.pollEditState$,
      initialData: _editPollBloc.pollEditState$.value,
      builder: (context, snapshot) {
        var data = snapshot.data;

        if (data.pollItem != null && !_editLoaded) {
          _updateFields(data.pollItem);
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
              elevation: 0,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 30,
                  color: Colors.grey,
                ),
                onPressed: () => Navigator.pop(context),
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
                      var endDate = _editPollBloc.endDate$.value;
                      var question = _editPollBloc.question$.value;
                      if (endDate is DateTime &&
                          endDate.isAfter(DateTime.now())) {
                        _editPollBloc.savePoll();
                      } else if (question.isEmpty) {
                        return showDialog<void>(
                          context: context,
                          barrierDismissible: false, // user must tap button!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Invalid Question'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text('Please enter a question.'),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        return showDialog<void>(
                          context: context,
                          barrierDismissible: false, // user must tap button!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Invalid End Date'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text('Please select a future date.'),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            body: GestureDetector(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        alignment: Alignment.center,
                        child: ListView(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                ImageHolder(
                                  size: 40,
                                  image: (widget.userBloc.loginState$.value
                                              as LoggedInUser)
                                          .image ??
                                      "",
                                ),
                                SizedBox(width: 10),
                                Flexible(
                                  child: TextFormField(
                                    controller: _pollMessageController,
                                    onChanged: _editPollBloc.questionChanged,
                                    keyboardType: TextInputType.multiline,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'What is your question...?',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            StreamBuilder<List<Map<String, String>>>(
                              stream: _editPollBloc.tagged$,
                              initialData: _editPollBloc.tagged$.value,
                              builder: (context, snapshot) {
                                var tagged = snapshot.data ?? [];

                                if (tagged.isEmpty) {
                                  return Container();
                                }

                                return Container(
                                  padding: EdgeInsets.all(5),
                                  margin: EdgeInsets.all(8),
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      width: 0.5,
                                      color: Colors.black.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Wrap(
                                    spacing: 5,
                                    alignment: WrapAlignment.start,
                                    runAlignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.start,
                                    children: List.generate(
                                      tagged.length,
                                      (index) {
                                        return Chip(
                                          avatar: ImageHolder(
                                            size: 30,
                                            image: tagged[index]["image"],
                                          ),
                                          label: Text(
                                            tagged[index]["name"],
                                            style: TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            Divider(height: 25),
                            Container(
                              margin: EdgeInsets.only(top: 15),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.4),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  StreamBuilder<List<PollAnswerItem>>(
                                    stream: _editPollBloc.answers$,
                                    initialData: _editPollBloc.answers$.value,
                                    builder: (context, snapshot) {
                                      var answers = snapshot.data ?? [];

                                      return Column(
                                        children: List.generate(
                                          answers.length,
                                          (index) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: Row(
                                                children: <Widget>[
                                                  Container(
                                                    height: 30,
                                                    width: 30,
                                                    padding: EdgeInsets.all(3),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        answers[index].label,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 15),
                                                  Flexible(
                                                    child: TextFormField(
                                                      controller:
                                                          _pollAnswerControllers[
                                                              index],
                                                      onChanged: (value) {
                                                        answers[index].answer =
                                                            value;
                                                        _editPollBloc
                                                            .answersChanged(
                                                                answers);
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            'Enter answer',
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 20),
                                                  StreamBuilder<int>(
                                                    stream: _editPollBloc.type$,
                                                    initialData: _editPollBloc
                                                        .type$.value,
                                                    builder:
                                                        (context, snapshot) {
                                                      var type =
                                                          snapshot.data ?? 1;
                                                      if (type == 1) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            _editPollBloc
                                                                .correctAnswerChanged(
                                                                    index);
                                                          },
                                                          child: Container(
                                                            height: 20,
                                                            width: 20,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    3),
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              border:
                                                                  Border.all(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            child:
                                                                StreamBuilder<
                                                                    int>(
                                                              stream: _editPollBloc
                                                                  .correctAnswer$,
                                                              initialData:
                                                                  _editPollBloc
                                                                      .correctAnswer$
                                                                      .value,
                                                              builder: (context,
                                                                  snapshot) {
                                                                var correctAnswer =
                                                                    snapshot
                                                                        .data;

                                                                return Container(
                                                                  height: 20,
                                                                  width: 20,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: index ==
                                                                            correctAnswer
                                                                        ? Colors.green[
                                                                            700]
                                                                        : Colors
                                                                            .white,
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        return Container();
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  Text('Poll Duration'),
                                  StreamBuilder<DateTime>(
                                    initialData: _editPollBloc.endDate$.value,
                                    builder: (context, snapshot) {
                                      DateTime existingDate =
                                          snapshot.data ?? DateTime.now();

                                      return DateTimeField(
                                        format: DateFormat(
                                            "MMMM dd, yyyy 'at' h:mma"),
                                        decoration: InputDecoration(
                                          helperText: 'Select end date',
                                          helperStyle: TextStyle(
                                            color: Colors.grey[300],
                                          ),
                                        ),
                                        initialValue: existingDate,
                                        onShowPicker:
                                            (context, currentValue) async {
                                          final date = await showDatePicker(
                                              context: context,
                                              firstDate: DateTime.now(),
                                              initialDate: existingDate,
                                              lastDate: DateTime(2100));
                                          if (date != null) {
                                            final time = await showTimePicker(
                                              context: context,
                                              initialTime:
                                                  TimeOfDay.fromDateTime(
                                                      existingDate),
                                            );
                                            _editPollBloc.endDateChanged(
                                                DateTimeField.combine(
                                                    date, time));
                                            return DateTimeField.combine(
                                                date, time);
                                          } else {
                                            return currentValue;
                                          }
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      2,
                                      (index) {
                                        var active = false;
                                        return Padding(
                                          padding: EdgeInsets.all(8),
                                          child: RaisedButton(
                                            color: active
                                                ? Colors.blue
                                                : Colors.white,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                color: Colors.blue,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            onPressed: () {
                                              _editPollBloc.typeChanged(index);
                                            },
                                            child: Row(
                                              children: <Widget>[
                                                Container(
                                                  height: 20,
                                                  width: 20,
                                                  child: Icon(
                                                    Icons.check,
                                                    size: 15,
                                                    color: active
                                                        ? Colors.blue
                                                        : Colors.white,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: active
                                                        ? Colors.white
                                                        : Colors.blue,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  index == 0
                                                      ? 'Poll Question'
                                                      : 'Quiz',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: active
                                                        ? Colors.white
                                                        : Colors.blue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      margin: EdgeInsets.all(15),
                      color: Colors.white,
                      child: RaisedButton(
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

                          if (tagged != null) {
                            _editPollBloc.taggedChanged(
                                tagged as List<Map<String, String>>);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                              'Tag a connection',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateFields(FeedPollItem poll) {
    _editPollBloc.questionChanged(poll.question);
    _pollMessageController.text = poll.question;

    _editPollBloc.answersChanged(poll.answers);
    poll.answers.forEach((answer) {
      _pollAnswerControllers[poll.answers.indexOf(answer)].text = answer.answer;
      if (answer.isCorrect != null && answer.isCorrect) {
        _editPollBloc.correctAnswerChanged(poll.answers.indexOf(answer));
      }
    });

    _editPollBloc.typeChanged(poll.type);
    _editPollBloc.endDateChanged(poll.endDate);
  }

  void _addDefaultAnswers() {
    var choices = ['A', 'B', 'C', 'D'];
    var answers = List.generate(choices.length, (index) {
      var answer = PollAnswerItem();
      answer.label = choices[index];
      answer.answer = '';
      answer.isCorrect = false;
      answer.responses = List<String>();
      return answer;
    });

    _editPollBloc.answersChanged(answers);
  }
}
