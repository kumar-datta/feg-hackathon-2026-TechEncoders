import 'bet_slip_model.dart';

enum ArenaTicketStatus {
  active('ACTIVE'),
  won('WON'),
  lost('LOST'),
  settled('SETTLED');

  final String label;
  const ArenaTicketStatus(this.label);
}

enum ArenaLegResult {
  pending('PENDING'),
  won('WON'),
  lost('LOST'),
  voided('VOID');

  final String label;
  const ArenaLegResult(this.label);
}

/// A ticket shared to the PSK Arena social feed.
class ArenaTicket {
  final String id;
  final String user;
  final String avatar;
  final String title;
  final double stake;
  final double totalOdds;
  final double potentialWin;
  final int likes;
  final int copiedCount;
  final List<BetSelection> selections;
  final List<ArenaLegResult> legResults;
  final ArenaTicketStatus status;
  final DateTime sharedAt;
  final bool isMine;
  final bool liked;

  const ArenaTicket({
    required this.id,
    required this.user,
    required this.avatar,
    required this.title,
    required this.stake,
    required this.totalOdds,
    required this.potentialWin,
    required this.likes,
    required this.copiedCount,
    required this.selections,
    required this.legResults,
    required this.status,
    required this.sharedAt,
    this.isMine = false,
    this.liked = false,
  });

  double get wonAmount => status == ArenaTicketStatus.won ? potentialWin : 0;

  String get timeAgo {
    final d = DateTime.now().difference(sharedAt);
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    if (d.inHours < 24) return '${d.inHours} h ago';
    return '${d.inDays} d ago';
  }

  ArenaTicket copyWith({int? likes, int? copiedCount, bool? liked}) => ArenaTicket(
        id: id,
        user: user,
        avatar: avatar,
        title: title,
        stake: stake,
        totalOdds: totalOdds,
        potentialWin: potentialWin,
        likes: likes ?? this.likes,
        copiedCount: copiedCount ?? this.copiedCount,
        selections: selections,
        legResults: legResults,
        status: status,
        sharedAt: sharedAt,
        isMine: isMine,
        liked: liked ?? this.liked,
      );
}
