import 'gan_zhi.dart';

class QimenPalace {
  final int index;
  final String direction, star, door, god, heavenGan, earthGan;
  QimenPalace({required this.index, required this.direction,
    required this.star, required this.door, required this.god,
    required this.heavenGan, required this.earthGan});
}

class QimenResult {
  final String dun;
  final int ju;
  final String zhiFu, zhiShi;
  final List<QimenPalace> palaces;
  QimenResult({required this.dun, required this.ju,
    required this.zhiFu, required this.zhiShi, required this.palaces});
}

class QimenCalculator {
  static const _jiuXing = ['天蓬','天芮','天冲','天辅','天禽','天心','天柱','天任','天英'];
  static const _baMen   = ['休门','死门','伤门','杜门','中门','开门','惊门','生门','景门'];
  static const _baShen  = ['值符','腾蛇','太阴','六合','白虎','玄武','九地','九天'];
  static const _gongDir = ['北','西南','东','东南','中','西北','西','东北','南'];

  static QimenResult calculate({
    required int year, required int month, required int day, required int hour,
  }) {
    final isYang = (month > 6) || (month < 6) ||
        (month == 6 && day < 21) || (month == 12 && day < 22);
    final dun = isYang ? '阳遁' : '阴遁';

    final jdn = _jdn(year, month, day);
    final ju = (jdn % 9) + 1;

    final dayGanIdx = (jdn + 9) % 10;
    final zhiIdx = ((hour + 1) ~/ 2) % 12;
    final hourGanIdx = ((dayGanIdx % 5) * 2 + zhiIdx) % 10;
    final xunShouIdx = (hourGanIdx - zhiIdx + 10) % 10;

    final zhiFu = _jiuXing[(ju + xunShouIdx) % 9];
    final zhiShi = _baMen[(ju + xunShouIdx) % 8];

    final palaces = <QimenPalace>[];
    for (int i = 1; i <= 9; i++) {
      palaces.add(QimenPalace(
        index: i, direction: _gongDir[i - 1],
        star: _jiuXing[(i + ju) % 9],
        door: _baMen[(i + ju) % 8],
        god: _baShen[(i + ju) % 8],
        heavenGan: TIAN_GAN[(i + ju) % 10],
        earthGan: TIAN_GAN[(i + ju + xunShouIdx) % 10],
      ));
    }

    return QimenResult(dun: dun, ju: ju, zhiFu: zhiFu,
        zhiShi: zhiShi, palaces: palaces);
  }

  static int _jdn(int y, int m, int d) {
    final a = ((14 - m) / 12).floor();
    final yy = y + 4800 - a;
    final mm = m + 12 * a - 3;
    return d + ((153 * mm + 2) / 5).floor() + 365 * yy +
        (yy ~/ 4) - (yy ~/ 100) + (yy ~/ 400) - 32045;
  }

  static String interpret(QimenResult r, String question) {
    final buf = StringBuffer();
    buf.writeln('【奇门遁甲起盘】');
    buf.writeln('${r.dun}第${r.ju}局，值符${r.zhiFu}，值使${r.zhiShi}。');
    buf.writeln();
    buf.writeln('【预测事项】$question');
    buf.writeln();
    buf.writeln('【格局分析】');

    final zhiFuPalace = r.palaces.firstWhere(
      (p) => p.star == r.zhiFu, orElse: () => r.palaces[0]);
    buf.writeln('值符落${zhiFuPalace.direction}宫（${zhiFuPalace.star}），'
        '八门为${zhiFuPalace.door}，八神为${zhiFuPalace.god}。');

    if (zhiFuPalace.door.contains('开') || zhiFuPalace.door.contains('生')) {
      buf.writeln('✓ 开门/生门临宫，主事情顺遂、有贵人相助、财源广进。');
    } else if (zhiFuPalace.door.contains('休')) {
      buf.writeln('• 休门临宫，宜静养、谋划，不宜急进。');
    } else if (zhiFuPalace.door.contains('惊') || zhiFuPalace.door.contains('伤')) {
      buf.writeln('⚠ 惊门/伤门临宫，主有口舌是非或意外变动，宜谨慎。');
    } else if (zhiFuPalace.door.contains('杜')) {
      buf.writeln('• 杜门临宫，主阻塞不通，事宜暂缓。');
    }
    buf.writeln();
    buf.writeln('【行动建议】');
    buf.writeln('以${zhiFuPalace.direction}方为用神方位，可往此方行事。');
    return buf.toString();
  }
}
