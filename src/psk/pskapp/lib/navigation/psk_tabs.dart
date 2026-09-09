import 'package:flutter/material.dart';

/// Stable identifiers for the horizontal top-tab strip.
///
/// Every screen used to reference tabs by bare integers, which broke as soon
/// as a tab was inserted. All navigation now goes through these constants.
class PskTab {
  PskTab._();

  static const int home = 0;
  static const int sports = 1;
  static const int live = 2;
  static const int casino = 3;
  static const int liveCasino = 4;
  static const int lotto = 5;
  static const int virtuals = 6;
  static const int forum = 7;
  static const int arena = 8;
  static const int promos = 9;
  static const int swipe = 10;
  static const int championsClub = 11;

  static const List<PskTabSpec> all = [
    PskTabSpec(home, 'Home', Icons.home_rounded),
    PskTabSpec(sports, 'Sports', Icons.sports_soccer),
    PskTabSpec(live, 'Live', Icons.access_time_filled, isLive: true),
    PskTabSpec(casino, 'Casino', Icons.casino),
    PskTabSpec(liveCasino, 'Live Casino', Icons.stream, isNew: true),
    PskTabSpec(lotto, 'Lotto', Icons.looks_one),
    PskTabSpec(virtuals, 'Virtuals', Icons.videogame_asset),
    PskTabSpec(forum, 'Forum', Icons.forum),
    PskTabSpec(arena, 'PSK Arena', Icons.military_tech),
    PskTabSpec(promos, 'Promotions', Icons.card_giftcard),
    PskTabSpec(swipe, 'Swipe & Bet', Icons.swipe, isNew: true),
    PskTabSpec(championsClub, 'Champions Club', Icons.emoji_events, isNew: true),
  ];

  static PskTabSpec spec(int index) => all.firstWhere(
        (t) => t.index == index,
        orElse: () => all.first,
      );
}

/// Bottom navigation slots.
class PskBottomTab {
  PskBottomTab._();

  static const int none = -1;
  static const int live = 0;
  static const int sports = 1;
  static const int betslip = 2;
  static const int casino = 3;
  static const int menu = 4;
}

class PskTabSpec {
  final int index;
  final String title;
  final IconData icon;
  final bool isNew;
  final bool isLive;

  const PskTabSpec(this.index, this.title, this.icon, {this.isNew = false, this.isLive = false});
}
