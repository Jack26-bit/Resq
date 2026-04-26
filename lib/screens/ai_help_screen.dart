import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/shared.dart';
import '../widgets/app_drawer.dart';
import '../services/gemini_service.dart';

class AiHelpScreen extends StatefulWidget {
  const AiHelpScreen({super.key});

  @override
  State<AiHelpScreen> createState() => _AiHelpScreenState();
}

class _AiHelpScreenState extends State<AiHelpScreen>
    with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  late AnimationController _pulseCtrl;
  final GeminiService _geminiService = GeminiService();

  final List<_ChatMsg> _messages = [
    _ChatMsg(
      text:
          'Welcome to ECHO AI. I\'m your tactical assistance module. I can help with:\n\n• Emergency protocols & first aid\n• Evacuation route planning\n• Resource identification\n• Threat assessment\n• Communication relay\n\nHow can I assist you?',
      isBot: true,
      time: '00:00',
    ),
  ];

  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final now = TimeOfDay.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add(_ChatMsg(text: text, isBot: false, time: timeStr));
      _isTyping = true;
    });
    _msgController.clear();
    _scrollToBottom();

    // Fetch real response from Gemini API
    final response = await _geminiService.sendMessage(text);

    if (!mounted) return;
    
    final replyNow = TimeOfDay.now();
    final replyTimeStr =
        '${replyNow.hour.toString().padLeft(2, '0')}:${replyNow.minute.toString().padLeft(2, '0')}';

    setState(() {
      _isTyping = false;
      _messages.add(_ChatMsg(
        text: response,
        isBot: true,
        time: replyTimeStr,
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: C.bg,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            color: C.surfaceLow,
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: C.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'CONNECTED',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: C.green,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'ECHO AI — TACTICAL ASSISTANCE v2.4',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    letterSpacing: 1.5,
                    color: Color(0xFF666666),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.security, color: Color(0xFF666666), size: 14),
                const SizedBox(width: 4),
                const Text(
                  'E2E',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),

          // Quick action chips
          Container(
            height: 48,
            color: C.surfaceLowest,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _quickChip('🔥 Fire Protocol', 'fire'),
                _quickChip('🌊 Flood Alert', 'flood help'),
                _quickChip('🏥 Medical Aid', 'medical first aid'),
                _quickChip('🏠 Find Shelter', 'shelter safe zone'),
                _quickChip('📡 Send SOS', 'help sos emergency'),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessage(_messages[index]);
              },
            ),
          ),

          // Input bar
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _quickChip(String label, String prompt) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          _msgController.text = prompt;
          _sendMessage();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: C.surfaceHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: C.outlineVar.withOpacity(0.3)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: C.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(_ChatMsg msg) {
    final isBot = msg.isBot;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isBot) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: C.surfaceHigh,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: C.outlineVar.withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/images/echo_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isBot ? C.surfaceLow : C.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isBot ? 4 : 16),
                      topRight: Radius.circular(isBot ? 16 : 4),
                      bottomLeft: const Radius.circular(16),
                      bottomRight: const Radius.circular(16),
                    ),
                    border: isBot
                        ? Border.all(color: C.outlineVar.withOpacity(0.2))
                        : null,
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: isBot ? C.onSurface : C.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  msg.time,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    color: Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ),
          if (!isBot) ...[
            const SizedBox(width: 10),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: C.surfaceHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.person, color: C.onSurfaceVar, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: C.surfaceHigh,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: C.outlineVar.withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/echo_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: C.surfaceLow,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: C.outlineVar.withOpacity(0.2)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypingDot(delay: 0),
                SizedBox(width: 4),
                _TypingDot(delay: 200),
                SizedBox(width: 4),
                _TypingDot(delay: 400),
                SizedBox(width: 8),
                Text(
                  'analyzing...',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E0E0E),
        border: Border(top: BorderSide(color: Color(0xFF1F1F1F))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: C.surfaceHigh,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.attach_file,
                      color: C.onSurfaceVar, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: C.surfaceLow,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: C.outlineVar.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgController,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: C.onSurface,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Describe your situation...',
                            hintStyle: TextStyle(
                              color: Color(0xFF555555),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: C.primary,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.send, color: C.onPrimary, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMsg {
  final String text;
  final bool isBot;
  final String time;

  _ChatMsg({required this.text, required this.isBot, required this.time});
}

class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: C.primary.withOpacity(0.3 + _ctrl.value * 0.7),
        ),
      ),
    );
  }
}
