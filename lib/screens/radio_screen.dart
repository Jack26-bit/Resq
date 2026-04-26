import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

// ─── Cyan accent for radio ──────────────────────────────────────────────────
const _cyan = Color(0xFF00E5FF);
const _red = Color(0xFFFF3B30);
const _darkBg = Color(0xFF0A0A0A);
const _panelBg = Color(0xFF111111);
const _borderDim = Color(0xFF1E1E1E);

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});
  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen>
    with TickerProviderStateMixin {
  int _selectedChannel = 0;
  double _volume = 75;
  double _squelch = 30;
  late AnimationController _waveCtrl;
  late AnimationController _barCtrl;

  final List<Map<String, String>> _channels = [
    {'id': 'CH-01', 'label': 'COMMAND', 'freq': '144.500'},
    {'id': 'CH-02', 'label': 'LOGISTICS', 'freq': '145.250'},
    {'id': 'CH-03', 'label': 'RESCUE-A', 'freq': '146.000'},
    {'id': 'CH-04', 'label': 'RESCUE-B', 'freq': '147.500'},
    {'id': 'CH-05', 'label': 'INTEL', 'freq': '148.250'},
    {'id': 'CH-06', 'label': 'SCAN', 'freq': '100.100'},
  ];

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _barCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _barCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ch = _channels[_selectedChannel];
    return Scaffold(
      backgroundColor: _darkBg,
      body: Column(
        children: [
          _buildHeader(ch),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  _buildFrequencyPanel(ch),
                  _buildChannelGrid(),
                  _buildAudioControls(),
                  _buildListenOnlyBanner(),
                  _buildSignalActivity(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader(Map<String, String> ch) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xCC0A0A0A),
        border: Border(bottom: BorderSide(color: _borderDim)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _cyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _cyan.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.radio, color: _cyan, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'COMMS_CHANNEL_${(_selectedChannel + 1).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            letterSpacing: 1,
                            color: _cyan)),
                  ]),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: C.surfaceLow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('OPERATOR72',
                      style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: Color(0xFF888888))),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: C.surfaceLow,
                      borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.person,
                      color: Color(0xFF888888), size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Frequency Panel ─────────────────────────────────────────────────────
  Widget _buildFrequencyPanel(Map<String, String> ch) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _panelBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Frequency & stats row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${ch['freq']} MHz',
                        style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontWeight: FontWeight.w800,
                            fontSize: 36,
                            letterSpacing: -1,
                            color: Colors.white)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Color(0xFF34C759)),
                        ),
                        const SizedBox(width: 6),
                        const Text('SIGNAL: STABLE',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                letterSpacing: 2,
                                color: Color(0xFF34C759))),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _statChip('SNR: 42DB'),
                  const SizedBox(height: 6),
                  _statChip('PWR: 5.0W'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Waveform visualizer
          ClipRect(
            child: AnimatedBuilder(
              animation: _waveCtrl,
              builder: (_, __) => CustomPaint(
                painter: _WaveformPainter(_waveCtrl.value),
                size: const Size(double.infinity, 80),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Bottom meta row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metaLabel('RX/TX Encryption: AES-256'),
              _metaLabel('UTC: 14:22:09'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: C.surfaceHigh,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text,
            style: const TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: Colors.white)),
      );

  Widget _metaLabel(String text) => Text(text,
      style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          letterSpacing: 1,
          color: Color(0xFF555555)));

  // ─── Channel Grid ─────────────────────────────────────────────────────────
  Widget _buildChannelGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.5,
        ),
        itemCount: _channels.length,
        itemBuilder: (_, i) {
          final isSelected = i == _selectedChannel;
          final ch = _channels[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedChannel = i),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : _panelBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : _borderDim,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(ch['id']!,
                      style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 0.5,
                          color: isSelected ? Colors.black : Colors.white)),
                  const SizedBox(height: 2),
                  Text(ch['label']!,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          letterSpacing: 1.5,
                          color: isSelected
                              ? const Color(0xFF333333)
                              : const Color(0xFF555555))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Audio Controls ───────────────────────────────────────────────────────
  Widget _buildAudioControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(child: _sliderCard('VOLUME', _volume, 0, 100, (v) => setState(() => _volume = v))),
          const SizedBox(width: 12),
          Expanded(child: _sliderCard('SQUELCH', _squelch, 0, 100, (v) => setState(() => _squelch = v))),
        ],
      ),
    );
  }

  Widget _sliderCard(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panelBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: Color(0xFF666666))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: C.surfaceHigh,
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    onChanged: onChanged,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(value.round().toString(),
                  style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Listen-Only Banner ───────────────────────────────────────────────────
  Widget _buildListenOnlyBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panelBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderDim),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: _red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _red.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      const BoxDecoration(shape: BoxShape.circle, color: _red),
                ),
                const SizedBox(width: 10),
                const Text('LISTEN ONLY MODE',
                    style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 2,
                        color: _red)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'TRANSMISSION CAPABILITIES DISABLED FOR THIS FREQUENCY',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                letterSpacing: 1.5,
                color: Color(0xFF555555)),
          ),
        ],
      ),
    );
  }

  // ─── Signal Activity ──────────────────────────────────────────────────────
  Widget _buildSignalActivity() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panelBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SIGNAL ACTIVITY',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: Color(0xFF666666))),
              Text('-102 dBm',
                  style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Color(0xFF888888))),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _barCtrl,
            builder: (_, __) => CustomPaint(
              painter: _BarGraphPainter(_barCtrl.value),
              size: const Size(double.infinity, 80),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BANDWIDTH',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          letterSpacing: 2,
                          color: Color(0xFF555555))),
                  SizedBox(height: 2),
                  Text('12.5 KHz',
                      style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.white)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('MODULATION',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          letterSpacing: 2,
                          color: Color(0xFF555555))),
                  SizedBox(height: 2),
                  Text('FM - NARROW',
                      style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.white)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Waveform Painter (oscilloscope style) ────────────────────────────────────
class _WaveformPainter extends CustomPainter {
  final double t;
  _WaveformPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final mid = size.height / 2;
    final rng = Random(42);

    for (double x = 0; x <= size.width; x += 2) {
      final phase = (x / size.width + t) * pi * 8;
      final noise = (rng.nextDouble() - 0.5) * 6;
      final y = mid + sin(phase) * 20 + sin(phase * 2.3) * 8 + noise;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WaveformPainter old) => old.t != t;
}

// ─── Bar Graph Painter ────────────────────────────────────────────────────────
class _BarGraphPainter extends CustomPainter {
  final double t;
  _BarGraphPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    const numBars = 20;
    final barW = (size.width - (numBars - 1) * 3) / numBars;
    final rng = Random(99);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < numBars; i++) {
      final base = rng.nextDouble() * 0.5 + 0.1;
      final animated = (base + sin((t + i * 0.3) * pi) * 0.25).clamp(0.0, 1.0);
      final barH = animated * size.height;
      final x = i * (barW + 3);
      final y = size.height - barH;

      paint.color = Color.lerp(
        const Color(0xFF333333),
        const Color(0xFF888888),
        animated,
      )!;

      canvas.drawRect(Rect.fromLTWH(x, y, barW, barH), paint);
    }
  }

  @override
  bool shouldRepaint(_BarGraphPainter old) => old.t != t;
}
