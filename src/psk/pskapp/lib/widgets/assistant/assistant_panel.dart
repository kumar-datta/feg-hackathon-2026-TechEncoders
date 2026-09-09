import 'package:flutter/material.dart';

import '../../assistant/assistant_controller.dart';
import '../../assistant/assistant_models.dart';
import '../../assistant/assistant_router.dart';
import '../../state/app_state.dart';
import '../../theme/psk_colors.dart';

/// The chat panel: slides up to 85 % of the screen, shows the welcome state
/// with suggestion chips, then the transcript with action buttons, source
/// citations, clarification options and a typing indicator.
class AssistantPanel extends StatefulWidget {
  final AssistantController controller;
  final AppState state;

  const AssistantPanel({super.key, required this.controller, required this.state});

  static Future<void> show(BuildContext context, AssistantController controller, AppState state) {
    controller.setOpen(true);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x990E0E11),
      builder: (_) => AssistantPanel(controller: controller, state: state),
    ).whenComplete(() => controller.setOpen(false));
  }

  @override
  State<AssistantPanel> createState() => _AssistantPanelState();
}

class _AssistantPanelState extends State<AssistantPanel> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();

  static const List<String> _suggestions = [
    '🎰 Open Vatreni Cup',
    '⚽ Show football bets',
    '❓ How does roulette work?',
    '💰 Check my balance',
  ];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    _input.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());

    // The pipeline decides when a jump is safe. It omits the route whenever
    // the match is uncertain or the destination needs confirmation.
    final route = widget.controller.takePendingNavigate();
    if (route != null) {
      Future<void>.delayed(const Duration(milliseconds: 550), () {
        if (!mounted) return;
        Navigator.of(context).pop();
        AssistantRouter.open(context, widget.state, route);
      });
    }
  }

  void _scrollToEnd() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  /// Sends the typed text, or a suggestion chip with its leading emoji removed.
  void _send([String? text]) {
    final message = text == null ? _input.text : _stripEmoji(text);
    if (message.trim().isEmpty) return;
    _input.clear();
    widget.controller.send(message);
    _focus.requestFocus();
  }

  String _stripEmoji(String s) => s.replaceFirst(RegExp(r'^[^\w]+', unicode: true), '').trim();

  void _runAction(AssistantAction a) {
    if (a.requiresConfirmation) {
      // a financial destination: let the confirm loop handle it
      widget.controller.send('yes');
      return;
    }
    Navigator.of(context).pop();
    AssistantRouter.open(context, widget.state, a.route);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final height = MediaQuery.of(context).size.height * 0.85;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          color: PskColors.bgDarkSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(color: PskColors.surfaceDarkAction, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 8),
            _header(c),
            Expanded(
              child: c.messages.isEmpty ? _welcome() : _transcript(c),
            ),
            _inputBar(c),
          ],
        ),
      ),
    );
  }

  Widget _header(AssistantController c) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: PskColors.surfaceDark,
        border: Border(bottom: BorderSide(color: PskColors.borderDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [PskColors.brandBlue, PskColors.brandBlueLight]),
            ),
            alignment: Alignment.center,
            child: const Text('✦', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PSK Assistant', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: c.ready ? PskColors.liveGreen : PskColors.warningOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        c.ready ? 'AI-powered · ${c.modeLabel}' : 'Loading knowledge…',
                        style: const TextStyle(color: PskColors.textMuted, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Assistant settings',
            onPressed: () => _showSettings(c),
            icon: const Icon(Icons.tune, color: PskColors.textMuted, size: 18),
            visualDensity: VisualDensity.compact,
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(color: PskColors.surfaceDarkAction, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _welcome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [PskColors.brandBlue, PskColors.brandBlueHover]),
              ),
              alignment: Alignment.center,
              child: const Text('✦', style: TextStyle(color: Colors.white, fontSize: 40)),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Text(
                'Hi! I can help you find games, navigate the app, or answer questions.',
                textAlign: TextAlign.center,
                style: TextStyle(color: PskColors.textGray, fontSize: 14, height: 20 / 14),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _suggestions
                  .map((s) => InkWell(
                        onTap: () => _send(s),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: PskColors.surfaceDarkPanel,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(s, style: const TextStyle(color: PskColors.textGray, fontSize: 12, fontWeight: FontWeight.w500)),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transcript(AssistantController c) {
    final msgs = c.messages;
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      itemCount: msgs.length + (c.busy ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == msgs.length) return const _TypingIndicator();
        final m = msgs[i];
        return m.isUser ? _userBubble(m) : _assistantBubble(m);
      },
    );
  }

  Widget _userBubble(ChatMessage m) {
    final time = '${m.at.hour.toString().padLeft(2, '0')}:${m.at.minute.toString().padLeft(2, '0')}';
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: PskColors.brandBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(m.content, style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 4),
              child: Text(time, style: const TextStyle(color: PskColors.textMuted, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _assistantBubble(ChatMessage m) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 8, top: 4),
            decoration: const BoxDecoration(color: PskColors.brandBlue, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Text('✦', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: m.error ? PskColors.alertRed.withValues(alpha: 0.25) : PskColors.surfaceDarkPanel,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.content, style: const TextStyle(color: PskColors.textGray, fontSize: 13, height: 19 / 13)),
                    if (m.refusal != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '🛡 Safety response · ${m.refusal!.toLowerCase().replaceAll('_', ' ')}',
                          style: const TextStyle(color: PskColors.warningOrange, fontSize: 10),
                        ),
                      ),
                    if (m.sources.isNotEmpty) _Sources(sources: m.sources),
                    if (m.clarification.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...m.clarification.map((o) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: TextButton(
                                onPressed: () => _send(o.label),
                                style: TextButton.styleFrom(
                                  backgroundColor: PskColors.surfaceDarkAction,
                                  foregroundColor: PskColors.textGray,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text(o.label, style: const TextStyle(fontSize: 13)),
                              ),
                            ),
                          )),
                    ] else if (m.actions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...m.actions.map((a) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: SizedBox(
                              width: double.infinity,
                              height: 36,
                              child: TextButton(
                                onPressed: () => _runAction(a),
                                style: TextButton.styleFrom(
                                  backgroundColor: PskColors.brandBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: a.requiresConfirmation
                                        ? const BorderSide(color: PskColors.accentGold, width: 2)
                                        : BorderSide.none,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    if (a.requiresAuth) const Text('🔒 ', style: TextStyle(fontSize: 11)),
                                    Expanded(
                                      child: Text(
                                        '▶ ${a.label}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward, size: 14),
                                  ],
                                ),
                              ),
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBar(AssistantController c) {
    final hasText = _input.text.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      decoration: const BoxDecoration(color: PskColors.surfaceDark),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 44,
              padding: const EdgeInsets.only(left: 16, right: 4),
              decoration: BoxDecoration(
                color: PskColors.surfaceDarkPanel,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      focusNode: _focus,
                      maxLength: 500,
                      style: const TextStyle(color: PskColors.textGray, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Ask me anything...',
                        hintStyle: TextStyle(color: PskColors.textMuted),
                        border: InputBorder.none,
                        counterText: '',
                        isDense: true,
                      ),
                      textInputAction: TextInputAction.send,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  InkWell(
                    onTap: hasText && !c.busy ? () => _send() : null,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: hasText && !c.busy ? PskColors.brandBlue : PskColors.surfaceDarkAction,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        size: 18,
                        color: hasText && !c.busy ? Colors.white : PskColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'AI answers are informational only. Verify important details.',
                style: TextStyle(color: PskColors.textMuted, fontSize: 9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings(AssistantController c) {
    final url = TextEditingController(text: c.remoteUrl);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PskColors.surfaceDark,
        title: const Text('Assistant settings', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Engine: ${c.modeLabel}\n'
              'Knowledge: ${c.service.chunkCount} chunks · ${c.service.entityCount} entities',
              style: const TextStyle(color: PskColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            const Text(
              'Optional: connect to the PSK website assistant API (LLM-backed). Leave empty to answer on-device.',
              style: TextStyle(color: PskColors.textGray, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: url,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'http://10.0.2.2:5000',
                hintStyle: TextStyle(color: PskColors.textMuted),
                filled: true,
                fillColor: PskColors.surfaceDarkPanel,
                border: OutlineInputBorder(borderSide: BorderSide.none),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              c.clearHistory();
              Navigator.pop(ctx);
            },
            child: const Text('Clear chat', style: TextStyle(color: PskColors.alertRed)),
          ),
          TextButton(
            onPressed: () {
              c.setRemoteUrl(url.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _Sources extends StatefulWidget {
  final List<AssistantSource> sources;
  const _Sources({required this.sources});

  @override
  State<_Sources> createState() => _SourcesState();
}

class _SourcesState extends State<_Sources> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final n = widget.sources.length;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Text(
              '📄 $n ${n == 1 ? 'source' : 'sources'} ${_open ? '▴' : '▾'}',
              style: const TextStyle(color: PskColors.brandBlueLight, fontSize: 11),
            ),
          ),
          if (_open)
            ...widget.sources.map((s) => Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text.rich(
                    TextSpan(
                      text: '• ${s.title}',
                      style: const TextStyle(color: PskColors.textMuted, fontSize: 11),
                      children: [
                        if (s.requiresVerifiedSource)
                          const TextSpan(
                            text: ' · Needs verified source',
                            style: TextStyle(color: PskColors.warningOrange),
                          ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 32),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 56,
          height: 32,
          decoration: BoxDecoration(color: PskColors.surfaceDarkPanel, borderRadius: BorderRadius.circular(16)),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final phase = ((_c.value - i * 0.2) % 1.0);
                final lift = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Transform.translate(
                    offset: Offset(0, -4 * lift),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: PskColors.textMuted, shape: BoxShape.circle),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
