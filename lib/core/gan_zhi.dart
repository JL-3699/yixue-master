const List<String> TIAN_GAN = ['甲','乙','丙','丁','戊','己','庚','辛','壬','癸'];
const List<String> DI_ZHI   = ['子','丑','寅','卯','辰','巳','午','未','申','酉','戌','亥'];
const List<String> SHENG_XIAO = ['鼠','牛','虎','兔','龙','蛇','马','羊','猴','鸡','狗','猪'];

const Map<String,String> GAN_WUXING = {
  '甲':'木','乙':'木','丙':'火','丁':'火','戊':'土',
  '己':'土','庚':'金','辛':'金','壬':'水','癸':'水',
};

const Map<String,List<String>> ZHI_CANG_GAN = {
  '子':['癸'], '丑':['己','癸','辛'], '寅':['甲','丙','戊'],
  '卯':['乙'], '辰':['戊','乙','癸'], '巳':['丙','戊','庚'],
  '午':['丁','己'], '未':['己','丁','乙'], '申':['庚','壬','戊'],
  '酉':['辛'], '戌':['戊','辛','丁'], '亥':['壬','甲'],
};

const List<String> NA_YIN = [
  '海中金','炉中火','大林木','路旁土','剑锋金','山头火',
  '涧下水','城头土','白蜡金','杨柳木','泉中水','屋上土',
  '霹雳火','松柏木','长流水','沙中金','山下火','平地木',
  '壁上土','金箔金','覆灯火','天河水','大驿土','钗钏金',
  '桑柘木','大溪水','沙中土','天上火','石榴木','大海水',
];

String getTenGod(String dayGan, String otherGan) {
  final dw = GAN_WUXING[dayGan]!;
  final ow = GAN_WUXING[otherGan]!;
  final dayYin = ['乙','丁','己','辛','癸'].contains(dayGan);
  final otherYin = ['乙','丁','己','辛','癸'].contains(otherGan);
  final sameYinYang = dayYin == otherYin;

  if (dw == ow) return sameYinYang ? '比肩' : '劫财';
  if (_sheng(dw) == ow) return sameYinYang ? '食神' : '伤官';
  if (_ke(dw) == ow) return sameYinYang ? '偏财' : '正财';
  if (_ke(ow) == dw) return sameYinYang ? '七杀' : '正官';
  if (_sheng(ow) == dw) return sameYinYang ? '偏印' : '正印';
  return '?';
}

String _sheng(String w) {
  const m = {'木':'火','火':'土','土':'金','金':'水','水':'木'};
  return m[w]!;
}
String _ke(String w) {
  const m = {'木':'土','土':'水','水':'火','火':'金','金':'木'};
  return m[w]!;
}
