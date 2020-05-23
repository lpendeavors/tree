import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../generated/l10n.dart';
import '../../../widgets/empty_list_view.dart';
import '../explore_state.dart';
import '../explore_bloc.dart';
import './posts_list_item.dart';

class ExplorePostsTab extends StatelessWidget {
  final ExploreBloc bloc;

  const ExplorePostsTab({
    Key key,
    @required this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var s = S.of(context);

    return Container(
      child: StreamBuilder<ExploreState>(
        stream: bloc.exploreState$,
        initialData: bloc.exploreState$.value,
        builder: (context, snapshot) {
          var data = snapshot.data;

          if (data.error != null) {
            print(data.error);
            return Center(
              child: Text(
                s.error_occurred,
              ),
            );
          }

          if (data.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (data.postItems.isEmpty) {
            return Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height - 150,
              child: Center(
                child: EmptyListView(
                  title: s.explore_posts_empty,
                  description: s.explore_post_empty_desc,
                  icon: Icons.image,
                ),
              ),
            );
          }

          // return ListView.separated(
          //   itemCount: data.postItems.length,
          //   physics: BouncingScrollPhysics(),
          //   shrinkWrap: true,
          //   itemBuilder: (context, index) {
          //     return PostListItem(
          //       postItem: data.postItems[index],
          //     );
          //   },
          //   separatorBuilder: (context, index) {
          //     return Align(
          //       alignment: Alignment.centerRight,
          //       child: Container(
          //         height: 0.5,
          //         width: MediaQuery.of(context).size.width,
          //         child: Divider(),
          //       ),
          //     );
          //   },
          // );

          return StaggeredGridView.countBuilder(
            shrinkWrap: true,
            crossAxisCount: 3,
            itemCount: data.postItems.length,
            staggeredTileBuilder: (index) {
              return StaggeredTile.count(1, 2);
            },
            itemBuilder: (context, index) {
              return PostListItem(
                postItem: data.postItems[index],
              );
            },
          );
        },
      ),
    );
  }
}