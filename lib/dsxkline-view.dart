import 'package:dsxkline_flutter/dsxkline/hqmodel.dart';
import 'package:dsxkline_flutter/dsxkline/qq.hq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dsxkline/dsxkline.dart';

class DsxklineView extends StatefulWidget {
  const DsxklineView({Key? key}) : super(key: key);
  @override
  _DsxklineViewState createState() => _DsxklineViewState();
}

class _DsxklineViewState extends State<DsxklineView>
    with TickerProviderStateMixin {
  TabController? mController;
  static final List<String> _tabs = [
    '分时',
    '五日',
    '日K',
    '周K',
    '月K',
    '分钟',
  ];
  HqModel model = HqModel();
  // 历史k线周期类型
  String cycle = "timeline";
  // 复权
  String fq = "data";
  int page = 1;
  int pageSize = 300;

  List<String> datas = [];
  double klineHeight = 350;
  double sideHeight = 100;
  // 主图指标
  List<String> main = ["MA"];
  // 副图指标
  List<String> sides = ["VOL", "MACD", "KDJ"];

  ScrollController scrollController = ScrollController();
  // 上一次滚动的地方
  double lastScrollY = 0;
  bool isScroll = true;

  Future<void> _onRefresh() async {}

  @override
  void initState() {
    model = HqModel(
      name: "上证指数",
      code: "sh000001",
    );
    mController = TabController(length: 6, vsync: this);
    _getQuotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //print("卖档：$sellList");
    return SafeArea(
      bottom: false,
      top: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("上证指数"),
        ),
        body: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Container(
      child: buildRefreshView(context),
    );
  }

  // 刷新控件
  Widget buildRefreshView(BuildContext context) {
    //print("isScroll=${isScroll}");
    // bool isstop = true;
    return ListView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      children: [
        buildTabbar(),
        buildKline(),
      ],
    );
  }

  Widget buildTabbar() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      height: 35,
      child: TabBar(
        onTap: (value) {
          if (value == 0) cycle = "timeline";
          if (value == 1) cycle = "timeline5";
          if (value == 2) cycle = "day";
          if (value == 3) cycle = "week";
          if (value == 4) cycle = "month";
          if (value == 5) cycle = "m1";
          // 更新状态
          setState(() {});
          EasyLoading.show();
          // 开始 onLoading 方法
          DsxKlineNotification.startLoading(value >= 2 ? 2 : value, 0.0);
        },
        isScrollable: false,
        controller: mController,
        labelColor: Colors.black,
        indicatorColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.label,
        automaticIndicatorColorAdjustment: true,
        tabs: _tabs.map((title) => Tab(text: title)).toList(),
      ),
    );
  }

  Widget buildKline() {
    sides = ["VOL", "MACD", "KDJ", "RSI", "WR", "BIAS", "CCI", "PSY"];
    //print("model.type=${model.type}");
    klineHeight = 200 + sides.length * 60;
    if (cycle.startsWith("t")) {
      // 分时图高度
      sides = ["VOL", "MACD", "RSI"];
      klineHeight = 200 + sides.length * sideHeight;
    }
    return SizedBox(
      height: klineHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              height: klineHeight,
              child: DsxKline(
                theme: "white",
                chartType: cycle == "timeline"
                    ? 0
                    : cycle == "timeline5"
                        ? 1
                        : 2,
                sideHeight: cycle.startsWith("t") ? sideHeight : 60,
                lastClose: double.parse(model.lastClose ?? "0.0"),
                main: const ["MA"],
                sides: sides,
                onLoading: (BuildContext context, DsxKline dsxKline) {
                  // 开始加载数据
                  page = 1;
                  datas = [];
                  _getKlineDatas();
                },
                nextPage: (BuildContext context, DsxKline dsxKline) {
                  // 滚动到最左边的时候加载下一页数据
                  _getKlineDatas();
                },
                onCrossing: (context, datas, index) {
                  Map d = datas as Map;
                  //print(d["DATE"] + "-" + d["CLOSE"]);
                  //print(jsonEncode(d));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getKlineDatas() {
    print("开始请求K线图数据$cycle");
    if (cycle == "timeline") _getQuotes();
    if (cycle == "timeline5") _getTimeLine5();
    if (cycle == "day" || cycle == "week" || cycle == "month") {
      _getKline();
    }
    if (cycle == "m1") {
      _getMinKline();
    }
  }

  Future<void> _getQuotes() async {
    QqHq.getQuote(model.code!, (List<HqModel> quotes) {
      model = quotes.first;
      setState(() {});
      _getTimeLine();
    }, (error) {
      EasyLoading.showError("网络不给力");
    });
  }

  Future<void> _getTimeLine() async {
    QqHq.getTimeLine(model.code, (data) {
      if (data is List) {
        datas.insertAll(0, data as List<String>);
        if (datas.isNotEmpty) {
          //print(datas);
          DsxKlineNotification.updateKline(datas, page);
        }
        //updateKlineLastData();
      }
      data.clear();
      EasyLoading.dismiss();
    }, (error) {
      EasyLoading.showError("网络不给力");
    });
  }

  Future<void> _getTimeLine5() async {
    QqHq.getFdayLine(model.code, (data) {
      model.lastClose = data["lastClose"].toString();
      data = data["data"];
      if (data is List) {
        datas = data as List<String>;
        if (datas.isNotEmpty) {
          //print(datas);
          DsxKlineNotification.updateKline(datas, page);
        }
        //updateKlineLastData();
      }
      EasyLoading.dismiss();
    }, (error) {
      EasyLoading.showError("网络不给力");
    });
  }

  Future<void> _getKline() async {
    QqHq.getKLine(model.code, cycle, "", "", 320, "qfq", (data) {
      if (data is List) {
        if (data.isNotEmpty) {
          datas.insertAll(0, data as List<String>);
          //print(datas);
          DsxKlineNotification.updateKline(datas, page);
          page++;
        } else {
          if (page > 1) {
            // 到尽头了
            DsxKlineNotification.scrollTheend();
          }
        }
        //updateKlineLastData();
      }
      data.clear();
      EasyLoading.dismiss();
    }, (error) {
      EasyLoading.showError("网络不给力");
    });
  }

  Future<void> _getMinKline() async {
    QqHq.getMinLine(model.code, cycle, 320, (data) {
      if (data is List) {
        if (data.isNotEmpty) {
          datas.insertAll(0, data as List<String>);
          //print(datas);
          DsxKlineNotification.updateKline(datas, page);
          page++;
        } else {
          if (page > 1) {
            // 到尽头了
            DsxKlineNotification.scrollTheend();
          }
        }
        //updateKlineLastData();
      }
      data.clear();
      EasyLoading.dismiss();
    }, (error) {
      EasyLoading.showError("网络不给力");
    });
  }

  updateKlineLastData() {
    if (!mounted) return;
    // 更新K线图实时行情
    String data =
        "${model.date!.replaceAll("-", "")},${model.time!.replaceAll(":", "").substring(0, 4)},${model.price},${model.vol},${model.volAmount}";
    if (cycle.startsWith("t")) {
      data =
          "${model.date!.replaceAll("-", "")},${model.open},${model.high},${model.low},${model.price},${model.vol},${model.volAmount}";
    }
    String c = "";
    if (cycle == "timeline") c = "t";
    if (cycle == "timeline5") c = "t5";
    if (cycle == "day") c = "d";
    if (cycle == "week") c = "w";
    if (cycle == "month") c = "m";
    if (cycle == "m1") c = "m1";
    DsxKlineNotification.refreshLastOneData(data, c);
  }
}
