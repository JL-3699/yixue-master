import 'gan_zhi.dart';

class AlmanacResult {
  final String dateStr, ganZhiDay, yi, ji, chong, wuxingNaYin, dailyFortune;
  AlmanacResult({required this.dateStr, required this.ganZhiDay,
    required this.yi, required this.ji, required this.chong,
    required this.wuxingNaYin, required this.dailyFortune});
}

class AlmanacCalculator {
  static const _yiJi = {
    '子':['祈福','出行','开市','动土'],
    '丑':['祭祀','嫁娶','纳财','安床'],
    '寅':['开市','交易','立券','纳畜'],
    '卯':['嫁娶','纳采','订盟','安葬'],
    '辰':['祭祀','祈福','求嗣','开光'],
    '巳':['开市','交易','立券','纳财'],
    '午':['嫁娶','安床','出行','求财'],
    '未':['祭祀','祈福','出行','开市'],
    '申':['嫁娶','纳财','开市','动土'],
    '酉':['祭祀','纳采','订盟','安葬'],
    '戌':['祈福','求嗣','开光','出行'],
    '亥':['开市','交易','纳财','立券'],
  };

  static AlmanacResult calculate(DateTime d) {
    final jdn = _jdn(d.year, d.month, d.day);
    final g = (jdn + 9) % 10;
    final z = (jdn + 1) % 12;
    final gz = TIAN_GAN[g] + DI_ZHI[z];

    final yi = _yiJi[DI_ZHI[z]] ?? ['祈福'];
    final jiZhi = DI_ZHI[(z + 6) % 12];
    final ji = _yiJi[jiZhi] ?? ['嫁娶'];

    final chongSX = SHENG_XIAO[(z + 6) % 12];
    final chong = '冲$chongSX';
    final naYin = NA_YIN[(jdn % 30).abs()];
    final fortune = _dailyFortune(g, z);

    return AlmanacResult(
      dateStr: '${d.year}年${d.month}月${d.day}日',
      ganZhiDay: gz, yi: yi.join('、'), ji: ji.join('、'),
      chong: chong, wuxingNaYin: naYin, dailyFortune: fortune);
  }

  static String _dailyFortune(int g, int z) {
    final sheng = SHENG_XIAO[z];
    final wx = GAN_WUXING[TIAN_GAN[g]]!;
    final buf = StringBuffer();
    buf.writeln('今日属$sheng人值日，天干五行属$wx。');
    switch (z % 6) {
      case 0: buf.writeln('整体运势平稳，宜按部就班，不宜冒进。'); break;
      case 1: buf.writeln('贵人运旺，适合谈判、签单、社交。'); break;
      case 2: buf.writeln('财运上升，适合投资理财、拓展业务。'); break;
      case 3: buf.writeln('情绪易波动，宜静心养性，避免争执。'); break;
      case 4: buf.writeln('事业有进展，适合主动出击、争取机会。'); break;
      case 5: buf.writeln('健康需注意，宜早睡、清淡饮食。'); break;
    }
    return buf.toString();
  }

  static int _jdn(int y, int m, int d) {
    final a = ((14 - m) / 12).floor();
    final yy = y + 4800 - a;
    final mm = m + 12 * a - 3;
    return d + ((153 * mm + 2) / 5).floor() + 365 * yy +
        (yy ~/ 4) - (yy ~/ 100) + (yy ~/ 400) - 32045;
  }
}
