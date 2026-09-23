import 'package:flutter/material.dart';
import 'core/bazi.dart';
import 'core/qimen.dart';
import 'core/almanac.dart';

void main() => runApp(const YixueApp());

class YixueApp extends StatelessWidget {
  const YixueApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '万能易学',
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;
  final _screens = const [BaziScreen(), QimenScreen(), AlmanacScreen(), AboutScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person), label: '八字'),
          NavigationDestination(icon: Icon(Icons.grid_on), label: '奇门'),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: '黄历'),
          NavigationDestination(icon: Icon(Icons.info), label: '关于'),
        ],
      ),
    );
  }
}

class BaziScreen extends StatefulWidget {
  const BaziScreen({super.key});
  @override
  State<BaziScreen> createState() => _BaziScreenState();
}

class _BaziScreenState extends State<BaziScreen> {
  DateTime _date = DateTime(1990, 1, 1);
  TimeOfDay _time = const TimeOfDay(hour: 12, minute: 0);
  bool _isMale = true;
  BaziResult? _result;

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _date,
      firstDate: DateTime(1900), lastDate: DateTime(2100));
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  void _calc() {
    setState(() {
      _result = BaziCalculator.calculate(
        year: _date.year, month: _date.month, day: _date.day,
        hour: _time.hour, minute: _time.minute, isMale: _isMale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('八字排盘')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          ListTile(
            title: Text('公历：${_date.year}-${_date.month.toString().padLeft(2,"0")}-${_date.day.toString().padLeft(2,"0")}'),
            trailing: const Icon(Icons.calendar_month), onTap: _pickDate),
          ListTile(
            title: Text('时间：${_time.hour.toString().padLeft(2,"0")}:${_time.minute.toString().padLeft(2,"0")}'),
            trailing: const Icon(Icons.access_time), onTap: _pickTime),
          Row(children: [
            const Text('性别：'),
            Radio<bool>(value: true, groupValue: _isMale,
              onChanged: (v) => setState(() => _isMale = v!)),
            const Text('男'),
            Radio<bool>(value: false, groupValue: _isMale,
              onChanged: (v) => setState(() => _isMale = v!)),
            const Text('女'),
          ]),
          const SizedBox(height: 8),
          FilledButton.icon(onPressed: _calc,
            icon: const Icon(Icons.auto_awesome), label: const Text('开始排盘')),
        ]))),
        if (_result != null) ...[
          const SizedBox(height: 16),
          Card(color: Colors.deepPurple.shade50, child: Padding(
            padding: const EdgeInsets.all(16), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('四柱', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _pillar('年柱', _result!.yearPillar),
                _pillar('月柱', _result!.monthPillar),
                _pillar('日柱', _result!.dayPillar),
                _pillar('时柱', _result!.hourPillar),
              ]),
              const Divider(height: 24),
              Text('日主：${_result!.dayMaster}（${_result!.dayMasterWuXing}）  生肖：${_result!.shengXiao}'),
              const SizedBox(height: 8),
              Text('十神：${_result!.tenGods.entries.map((e) => "${e.key}${e.value}").join(" / ")}'),
              const SizedBox(height: 16),
              const Text('大运（8步）', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(spacing: 8, runSpacing: 8,
                children: _result!.luckCycles.map((l) => Chip(label: Text(l))).toList()),
              const Divider(height: 24),
              Text(_result!.reading, style: const TextStyle(height: 1.6)),
            ]))),
        ],
      ]),
    );
  }

  Widget _pillar(String label, String value) => Column(children: [
    Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
  ]);
}

class QimenScreen extends StatefulWidget {
  const QimenScreen({super.key});
  @override
  State<QimenScreen> createState() => _QimenScreenState();
}

class _QimenScreenState extends State<QimenScreen> {
  final _qCtrl = TextEditingController();
  QimenResult? _result;
  String? _reading;

  void _calc() {
    final now = DateTime.now();
    final r = QimenCalculator.calculate(
      year: now.year, month: now.month, day: now.day, hour: now.hour);
    setState(() {
      _result = r;
      _reading = QimenCalculator.interpret(r,
        _qCtrl.text.isEmpty ? '今日运势' : _qCtrl.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('奇门遁甲')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _qCtrl,
          decoration: const InputDecoration(
            labelText: '预测事项（留空则测今日运势）',
            border: OutlineInputBorder())),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: _calc,
          icon: const Icon(Icons.casino), label: const Text('现时起盘')),
        if (_result != null) ...[
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
            Text('${_result!.dun} 第${_result!.ju}局',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('值符：${_result!.zhiFu}  值使：${_result!.zhiShi}'),
          ]))),
          const SizedBox(height: 12),
          GridView.count(crossAxisCount: 3, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _result!.palaces.map((p) => Card(
              color: Colors.amber.shade50,
              child: Padding(padding: const EdgeInsets.all(4), child: Column(
                mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(p.star, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(p.door, style: const TextStyle(fontSize: 12, color: Colors.red)),
                Text(p.god, style: const TextStyle(fontSize: 11)),
                Text('${p.heavenGan}/${p.earthGan}',
                  style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
              ])))).toList()),
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(16),
            child: Text(_reading ?? '', style: const TextStyle(height: 1.6)))),
        ],
      ]),
    );
  }
}

class AlmanacScreen extends StatefulWidget {
  const AlmanacScreen({super.key});
  @override
  State<AlmanacScreen> createState() => _AlmanacScreenState();
}

class _AlmanacScreenState extends State<AlmanacScreen> {
  late AlmanacResult _result;
  @override
  void initState() {
    super.initState();
    _result = AlmanacCalculator.calculate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('每日黄历')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(color: Colors.red.shade50, child: Padding(
          padding: const EdgeInsets.all(16), child: Column(children: [
          Text(_result.dateStr, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(_result.ganZhiDay, style: const TextStyle(fontSize: 32,
            fontWeight: FontWeight.bold, color: Colors.red)),
          Text('纳音：${_result.wuxingNaYin}'),
          Text(_result.chong, style: const TextStyle(color: Colors.deepOrange)),
        ]))),
        const SizedBox(height: 12),
        Card(child: ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: const Text('宜'), subtitle: Text(_result.yi))),
        Card(child: ListTile(
          leading: const Icon(Icons.cancel, color: Colors.red),
          title: const Text('忌'), subtitle: Text(_result.ji))),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('今日运程', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(_result.dailyFortune, style: const TextStyle(height: 1.6)),
        ]))),
      ]),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: const Padding(padding: EdgeInsets.all(24), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('万能易学 v1.0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Text('功能：\n• 八字排盘（四柱/十神/大运/纳音）\n• 奇门遁甲现时起盘\n• 每日黄历与运程\n• 跨平台：Windows / Android'),
        SizedBox(height: 24),
        Text('免责声明：\n本程序内容仅供参考与文化研究之用，不构成任何决策依据。命运掌握在自己手中。',
          style: TextStyle(color: Colors.grey, height: 1.6)),
      ])),
    );
  }
}
