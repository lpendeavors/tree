import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import '../../../generated/l10n.dart';
import '../../../widgets/empty_list_view.dart';
import '../events_state.dart';
import '../events_bloc.dart';
import './events_list_item.dart';

class EventsList extends StatelessWidget {
  final EventsBloc bloc;
  final bool onlyMine;

  const EventsList({
    Key key,
    @required this.bloc,
    this.onlyMine = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<EventsListState>(
        stream: bloc.eventsListState$,
        initialData: bloc.eventsListState$.value,
        builder: (context, snapshot) {
          var data = snapshot.data;

          if (data.error != null) {
            print(data.error);
            return Center(
              child: Text(
                S.of(context).error_occurred,
              ),
            );
          }

          if (data.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (data.eventItems.isEmpty || (onlyMine && data.myEvents.isEmpty)) {
            return Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height - 150,
              child: Center(
                child: EmptyListView(
                  title: S.of(context).events_empty_title,
                  description: S.of(context).events_empty_desc,
                  icon: Icons.event,
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: onlyMine ? data.myEvents.length : data.eventItems.length,
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return EventsListItem(
                eventItem:
                    onlyMine ? data.myEvents[index] : data.eventItems[index],
                onDelete: () {
                  bloc.deleteEvent(
                    onlyMine
                        ? data.myEvents[index].id
                        : data.eventItems[index].id,
                  );
                },
                onReport: () {},
                onStatusUpdate: (status) {
                  bloc.updateStatus(Tuple2<String, int>(
                    onlyMine
                        ? data.myEvents[index].id
                        : data.eventItems[index].id,
                    status,
                  ));
                },
              );
            },
            separatorBuilder: (context, index) {
              return Align(
                alignment: Alignment.centerRight,
                child: Container(
                  height: 0.5,
                  width: MediaQuery.of(context).size.width,
                  child: Divider(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
