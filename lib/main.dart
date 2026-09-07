import 'dart:async';

import 'package:flutter/material.dart';

import 'services/location_engine.dart';
import 'services/step_engine.dart';
import 'widgets/metric_card.dart';
import 'wingstar_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WingstarApp());
}

class WingstarApp extends StatelessWidget {
  const WingstarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wingstar',
      debugShowCheckedModeBanner: false,
      theme: buildWingstarTheme(),
      home: const WingstarShell(),
    );
  }
}

class WingstarShell extends StatefulWidget {
  const WingstarShell({super.key});

  @override
  State<WingstarShell> createState() => _WingstarShellState();
}

class _WingstarShellState extends State<WingstarShell> {
  int index = 0;
  late final StepEngine stepEngine;
  late final LocationEngine locationEngine;

  @override
  void initState() {
    super.initState();
    stepEngine = StepEngine();
    locationEngine = LocationEngine();
  }

  @override
  void dispose() {
    stepEngine.dispose();
    locationEngine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onStart: () => setState(() => index = 1)),
      FlowPage(stepEngine: stepEngine, locationEngine: locationEngine),
      const GreenPage(),
      const ImpactPage(),
    ];

    return Scaffold(
      body: SafeArea(child: IndexedStack(index: index, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: '홈'),
          NavigationDestination(icon: Icon(Icons.directions_walk), label: 'FLOW'),
          NavigationDestination(icon: Icon(Icons.eco_outlined), label: 'GREEN'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'IMPACT'),
        ],
      ),
    );
  }
}

class PageFrame extends StatelessWidget {
  const PageFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
          child: child,
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: WingstarColors.cloudBlue,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.air_rounded,
                    size: 36, color: WingstarColors.navy),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WINGSTAR',
                        style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.3)),
                    Text('WALK FOR ME, WALK FOR EARTH.',
                        style: TextStyle(
                            color: WingstarColors.wingBlue,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 42),
          const Text('오늘의 나를 위한 걸음을\n시작해볼까요?',
              style: TextStyle(
                  fontSize: 31, fontWeight: FontWeight.w900, height: 1.25)),
          const SizedBox(height: 10),
          const Text('마음을 살피고, 걷고, 주변을 돌보고, 변화를 확인해요.',
              style: TextStyle(color: WingstarColors.wingBlue, fontSize: 15)),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('오늘의 FLOW 시작하기'),
          ),
          const SizedBox(height: 30),
          const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Pill(icon: Icons.self_improvement, title: 'MIND', subtitle: '마음 · 명상'),
              Pill(icon: Icons.directions_walk, title: 'MOVE', subtitle: '걸음 · 거리'),
              Pill(icon: Icons.eco_outlined, title: 'CARE', subtitle: '플로깅'),
              Pill(icon: Icons.public, title: 'IMPACT', subtitle: 'ESG · 기록'),
            ],
          ),
          const SizedBox(height: 24),
          const InfoCard(
            icon: Icons.eco_rounded,
            title: 'TODAY · GREEN MISSION',
            body: '걷는 길에서 작은 쓰레기 하나를 치워보세요. 나를 위한 산책이 주변을 위한 행동으로 이어집니다.',
          ),
        ],
      ),
    );
  }
}

class FlowPage extends StatefulWidget {
  const FlowPage({
    super.key,
    required this.stepEngine,
    required this.locationEngine,
  });

  final StepEngine stepEngine;
  final LocationEngine locationEngine;

  @override
  State<FlowPage> createState() => _FlowPageState();
}

class _FlowPageState extends State<FlowPage> {
  bool active = false;
  DateTime? startedAt;
  Timer? timer;
  Duration elapsed = Duration.zero;
  String sensitivity = 'normal';

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> startFlow() async {
    setState(() {
      active = true;
      startedAt = DateTime.now();
      elapsed = Duration.zero;
    });
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || startedAt == null) return;
      setState(() => elapsed = DateTime.now().difference(startedAt!));
    });
    await Future.wait([
      widget.stepEngine.start(),
      widget.locationEngine.start(),
    ]);
  }

  Future<void> stopFlow() async {
    timer?.cancel();
    await Future.wait([
      widget.stepEngine.stop(),
      widget.locationEngine.stop(),
    ]);
    if (mounted) setState(() => active = false);
  }

  String formatDuration(Duration value) {
    final m = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.stepEngine, widget.locationEngine]),
      builder: (context, _) {
        final step = widget.stepEngine;
        final location = widget.locationEngine;
        return PageFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('TODAY FLOW',
                  style: TextStyle(
                      color: WingstarColors.wingBlue,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1)),
              const SizedBox(height: 8),
              const Text('걷는 동안 마음과 주변을 함께 바라봐요.',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: WingstarColors.cloudBlue),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.self_improvement,
                        size: 42, color: WingstarColors.navy),
                    const SizedBox(height: 12),
                    const Text('숨을 천천히 들이마시고,\n발이 땅에 닿는 감각을 느껴보세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, height: 1.45)),
                    if (step.status == StepEngineStatus.calibrating) ...[
                      const SizedBox(height: 20),
                      LinearProgressIndicator(value: step.calibrationProgress),
                    ],
                    const SizedBox(height: 14),
                    Text(step.statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: WingstarColors.wingBlue)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.55,
                children: [
                  MetricCard(icon: Icons.directions_walk, label: '걸음', value: '${step.steps}'),
                  MetricCard(icon: Icons.timer_outlined, label: '시간', value: formatDuration(elapsed)),
                  MetricCard(
                    icon: Icons.route_outlined,
                    label: '거리',
                    value: '${(location.distanceMeters / 1000).toStringAsFixed(2)} km',
                  ),
                  MetricCard(
                    icon: Icons.speed,
                    label: '센서 기준',
                    value: step.gravityBaseline.toStringAsFixed(2),
                    caption: '3~5초 자동 보정',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                value: sensitivity,
                decoration: const InputDecoration(
                  labelText: '걸음 인식 민감도',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('낮음')), 
                  DropdownMenuItem(value: 'normal', child: Text('보통')),
                  DropdownMenuItem(value: 'high', child: Text('높음')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => sensitivity = value);
                  step.setSensitivity(value);
                },
              ),
              const SizedBox(height: 14),
              if (!active)
                FilledButton.icon(
                  onPressed: startFlow,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('FLOW 시작'),
                )
              else
                FilledButton.icon(
                  onPressed: stopFlow,
                  icon: const Icon(Icons.stop_rounded),
                  label: const Text('FLOW 종료'),
                ),
              if (step.isDesktop) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: step.simulateShake,
                  icon: const Icon(Icons.vibration),
                  label: const Text('PC 테스트 · 흔들림 +1'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class GreenPage extends StatelessWidget {
  const GreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('CARE · GREEN MISSION',
              style: TextStyle(color: WingstarColors.wingBlue, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('오늘의 걸음을\n주변을 위한 행동으로.',
              style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, height: 1.25)),
          SizedBox(height: 24),
          InfoCard(
            icon: Icons.delete_outline_rounded,
            title: '작은 플로깅',
            body: '걷는 동안 눈에 보이는 작은 쓰레기를 하나 이상 치워보세요. 숫자 경쟁보다 꾸준한 행동을 목표로 합니다.',
          ),
          SizedBox(height: 14),
          InfoCard(
            icon: Icons.camera_alt_outlined,
            title: '활동 인증',
            body: '정식 버전에서는 FLOW 기록과 사진 인증을 함께 사용해 Green Mission 참여를 기록할 예정입니다.',
          ),
        ],
      ),
    );
  }
}

class ImpactPage extends StatelessWidget {
  const ImpactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('IMPACT',
              style: TextStyle(color: WingstarColors.wingBlue, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('나의 작은 행동이\n쌓이는 곳.',
              style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, height: 1.25)),
          SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Pill(icon: Icons.self_improvement, title: 'MIND', subtitle: '명상 기록'),
              Pill(icon: Icons.directions_walk, title: 'MOVE', subtitle: '걷기 기록'),
              Pill(icon: Icons.eco_outlined, title: 'CARE', subtitle: 'Green Mission'),
              Pill(icon: Icons.public, title: 'IMPACT', subtitle: 'ESG 활동'),
            ],
          ),
          SizedBox(height: 20),
          InfoCard(
            icon: Icons.auto_graph_rounded,
            title: 'MY IMPACT',
            body: '향후 세션 저장 기능을 연결하면 월별 명상 시간, 걸은 거리, 플로깅 참여 횟수와 Green Point를 이 화면에 누적할 수 있습니다.',
          ),
        ],
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill({super.key, required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WingstarColors.cloudBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: WingstarColors.wingBlue),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          Text(subtitle, style: const TextStyle(color: WingstarColors.skyBlue, fontSize: 12)),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WingstarColors.cloudBlue.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: WingstarColors.navy),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(body, style: const TextStyle(color: WingstarColors.wingBlue, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
