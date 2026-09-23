import 'gan_zhi.dart';

class BaziResult {
  final String yearPillar, monthPillar, dayPillar, hourPillar;
  final String dayMaster, dayMasterWuXing, shengXiao, naYin;
  final Map<String, String> tenGods;
  final List<String> luckCycles;
  final String reading;

  BaziResult({
    required this.yearPillar, required this.monthPillar,
    required this.dayPillar, required this.hourPillar,
    required this.dayMaster, required this.dayMasterWuXing,
    required this.tenGods, required this.shengXiao,
    required this.naYin, required this.luckCycles, required this.reading,
  });
}

class BaziCalculator {
  static int _jdn(int y, int m, int d) {
    final a = ((14 - m) / 12).floor();
    final yy = y + 4800 - a;
    final mm = m + 12 * a - 3;
    return d + ((153 * mm + 2) / 5).floor() + 365 * yy +
        (yy ~/ 4) - (yy ~/ 100) + (yy ~/ 400) - 32045;
  }

  static String _yearPillar(int y, int m, int d) {
    int year = y;
    if (m < 2 || (m == 2 && d < 4)) year -= 1;
    final g = (year - 4) % 10;
    final z = (year - 4) % 12;
    return TIAN_GAN[g] + DI_ZHI[z];
  }

  static String _monthPillar(int m, int d, String yearGan) {
    int yinOffset;
    if (m == 1) {
      yinOffset = d >= 6 ? 11 : 10;
    } else if (m == 2) {
      yinOffset = d >= 4 ? 0 : 11;
    } else {
      yinOffset = m - 2;
    }
    final zhiIdx = (2 + yinOffset) % 12;
    final yearGanIdx = TIAN_GAN.indexOf(yearGan);
    final monthGanIdx = ((yearGanIdx % 5) * 2 + 2 + yinOffset) % 10;
    return TIAN_GAN[monthGanIdx] + DI_ZHI[zhiIdx];
  }

  static String _dayPillar(int y, int m, int d) {
    final jdn = _jdn(y, m, d);
    final g = (jdn + 9) % 10;
    final z = (jdn + 1) % 12;
    return TIAN_GAN[g] + DI_ZHI[z];
  }

  static String _hourPillar(int hour, String dayGan) {
    final zhiIdx = ((hour + 1) ~/ 2) % 12;
    final dayGanIdx = TIAN_GAN.indexOf(dayGan);
    final hourGanIdx = ((dayGanIdx % 5) * 2 + zhiIdx) % 10;
    return TIAN_GAN[hourGanIdx] + DI_ZHI[zhiIdx];
  }

  static List<String> _luckCycles(String monthPillar, String yearGan, bool isMale) {
    final monthGanIdx = TIAN_GAN.indexOf(monthPillar[0]);
    final monthZhiIdx = DI_ZHI.indexOf(monthPillar[1]);
    final yearGanIdx = TIAN_GAN.indexOf(yearGan);
    final isYangYear = yearGanIdx % 2 == 0;
    final forward = (isYangYear && isMale) || (!isYangYear && !isMale);

    final result = <String>[];
    for (int i = 1; i <= 8; i++) {
      int g, z;
      if (forward) {
        g = (monthGanIdx + i) % 10;
        z = (monthZhiIdx + i) % 12;
      } else {
        g = (monthGanIdx - i + 10) % 10;
        z = (monthZhiIdx - i + 12) % 12;
      }
      result.add('${TIAN_GAN[g]}${DI_ZHI[z]}');
    }
    return result;
  }

  static BaziResult calculate({
    required int year, required int month, required int day,
    required int hour, required int minute, bool isMale = true,
  }) {
    final yp = _yearPillar(year, month, day);
    final mp = _monthPillar(month, day, yp[0]);
    final dp = _dayPillar(year, month, day);
    final hp = _hourPillar(hour, dp[0]);

    final dayGan = dp[0];
    final tenGods = <String, String>{
      '年干': getTenGod(dayGan, yp[0]),
      '月干': getTenGod(dayGan, mp[0]),
      '时干': getTenGod(dayGan, hp[0]),
    };

    final shengXiao = SHENG_XIAO[DI_ZHI.indexOf(yp[1])];
    final naYinIdx = ((TIAN_GAN.indexOf(yp[0]) - DI_ZHI.indexOf(yp[1])) % 10 + 10) % 10 * 3 % 30;
    final naYin = NA_YIN[naYinIdx];
    final luck = _luckCycles(mp, yp[0], isMale);
    final reading = _generateReading(yp, mp, dp, hp, dayGan,
        GAN_WUXING[dayGan]!, tenGods, shengXiao);

    return BaziResult(
      yearPillar: yp, monthPillar: mp, dayPillar: dp, hourPillar: hp,
      dayMaster: dayGan, dayMasterWuXing: GAN_WUXING[dayGan]!,
      tenGods: tenGods, shengXiao: shengXiao, naYin: naYin,
      luckCycles: luck, reading: reading,
    );
  }

  static String _generateReading(String yp, String mp, String dp, String hp,
      String dayGan, String dayWuXing,
      Map<String, String> tenGods, String shengXiao) {
    final buf = StringBuffer();
    buf.writeln('【命主基本信息】');
    buf.writeln('生肖属$shengXiao，日主为$dayGan（$dayWuXing）。');
    buf.writeln('四柱：$yp $mp $dp $hp');
    buf.writeln();
    buf.writeln('【十神格局】');
    buf.writeln('年干${yp[0]}为${tenGods["年干"]}，月干${mp[0]}为${tenGods["月干"]}，时干${hp[0]}为${tenGods["时干"]}。');

    if (tenGods.containsValue('正官') || tenGods.containsValue('七杀')) {
      buf.writeln('• 官杀透干，适合公职、管理、体制内方向发展。');
    }
    if (tenGods.containsValue('正财') || tenGods.containsValue('偏财')) {
      buf.writeln('• 财星显露，有经商理财天赋，适合金融、贸易、自主创业。');
    }
    if (tenGods.containsValue('食神') || tenGods.containsValue('伤官')) {
      buf.writeln('• 食伤吐秀，才华横溢，适合创意、技术、艺术、教育行业。');
    }
    if (tenGods.containsValue('正印') || tenGods.containsValue('偏印')) {
      buf.writeln('• 印星护身，贵人相助，适合学术、研究、文职、医疗。');
    }
    buf.writeln();
    buf.writeln('【五行喜忌与开运】');
    final wxMap = {'木':'东方','火':'南方','土':'中宫','金':'西方','水':'北方'};
    buf.writeln('日主$dayGan属$dayWuXing，开运方位：${wxMap[dayWuXing]}');
    buf.writeln();
    buf.writeln('【人生使命】');
    buf.writeln('本命以$dayWuXing为体，宜在${wxMap[dayWuXing]}方或相关行业深耕，');
    buf.writeln('以${_xingGe(dayWuXing)}之性格立身，广结善缘，福泽绵长。');
    return buf.toString();
  }

  static String _xingGe(String wx) {
    const m = {'木':'仁德进取','火':'热情礼敬','土':'厚德载物',
      '金':'刚毅果断','水':'智慧灵动'};
    return m[wx] ?? '中和';
  }
}
