import 'package:dtube_go/bloc/notification/notification_bloc_full.dart';
import 'package:dtube_go/ui/widgets/UnsortedCustomWidgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:dtube_go/bloc/config/txTypes.dart';
import 'package:dtube_go/bloc/user/user_bloc_full.dart';
import 'package:dtube_go/ui/widgets/AccountAvatar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    Key? key,
    required this.sender,
    required this.username,
    required this.tx,
    required this.userNavigation,
    required this.postNavigation,
  }) : super(key: key);

  final String sender;
  final String username;
  final Tx tx;
  final bool userNavigation;
  final bool postNavigation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2.w),
      child: SizedBox(
        height: 15.h,
        width: 100.w,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            DTubeFormCard(
              childs: [
                Row(
                  children: [
                    Container(
                      width: 30.w,
                      child: Column(
                        children: [
                          BlocProvider<UserBloc>(
                            create: (BuildContext context) =>
                                UserBloc(repository: UserRepositoryImpl()),
                            child: AccountAvatarBase(
                              username: sender,
                              avatarSize: 15.w,
                              showVerified: true,
                              showName: false,
                              width: 30.w,
                              height: 7.h,
                            ),
                          ),
                          Text(
                            sender,
                            style: Theme.of(context).textTheme.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 3.w,
                    ),
                    Container(
                      width: 47.w,
                      child: NotificationTitle(
                        sender: sender,
                        tx: tx,
                        username: username,
                      ),
                    ),
                    userNavigation || postNavigation
                        ? FaIcon(
                            userNavigation
                                ? FontAwesomeIcons.user
                                : FontAwesomeIcons.play,
                            size: 5.w,
                          )
                        : SizedBox(width: 0)
                  ],
                ),
              ],
              avoidAnimation: true,
              waitBeforeFadeIn: Duration(milliseconds: 0),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationTitle extends StatelessWidget {
  const NotificationTitle({
    Key? key,
    required this.sender,
    required this.username,
    required this.tx,
  }) : super(key: key);

  final String sender;
  final String username;
  final Tx tx;

  @override
  Widget build(BuildContext context) {
    String username2 = "your";

    String friendlyDescription =
        txTypeFriendlyDescriptionNotifications[tx.type]!
            .replaceAll("##USERNAMES", username2)
            .replaceAll("##USERNAME", username);
    switch (tx.type) {
      case 3:
        friendlyDescription = friendlyDescription.replaceAll(
            '##DTCAMOUNT', (tx.data.amount! / 100).toString());
        break;
      case 19:
        friendlyDescription = friendlyDescription.replaceAll(
            '##TIPAMOUNT', tx.data.tip!.toString());

        break;
      default:
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
            DateFormat('yyyy-MM-dd kk:mm').format(
                    DateTime.fromMicrosecondsSinceEpoch(tx.ts * 1000)
                        .toLocal()) +
                ':',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyText1),
        Container(
          width: 45.w,
          child: Text(friendlyDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyText1),
        ),
      ],
    );
  }
}