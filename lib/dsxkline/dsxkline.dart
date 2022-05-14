// ignore_for_file: unnecessary_type_check

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dsx.kline.js.dart' show dsxKlineScript;

String html =
    '<!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=0" /><style>*{padding:0;margin:0;-webkit-touch-callout:none;-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none;}html{overflow:hidden;}body{position:fixed;top:0;left:0;overflow:hidden;width:100%;height:100%;}</style></head><body><div id="kline" style="display: block;"></div></body></html>';

// ignore: must_be_immutable
class DsxKline extends StatefulWidget {
  DsxKline({
    Key? key,
    this.initBackgroundColor = Colors.transparent,
    this.theme = "white",
    this.chartType = 0,
    this.candleType = 0,
    this.zoomLockType = 3,
    this.zoomStep = 2.0,
    this.height = 0.0,
    this.width = 0.0,
    this.sideHeight = 50.0,
    this.klineWidth = 5,
    this.isShowKlineTipPannel = true,
    this.main = const ["MA"],
    this.sides = const ["VOL", "MACD", "KDJ"],
    this.datas,
    this.lastClose,
    this.rightEmptyKlineAmount = 1,
    this.page = 1,
    this.onLoading,
    this.nextPage,
    this.onCrossing,
    this.captureAllGestures = false,
    this.captureHorizontalGestures = true,
    this.captureVerticalGestures = false,
  }) : super(key: key);

  /// K线数据
  List<String>? datas;

  /// 初始化背景色
  Color initBackgroundColor;

  /// 主题 white dark 等
  String theme;

  /// 图表类型 0=分时图 1=五日图 2=k线图
  int chartType;

  /// 蜡烛图k线样式 0=空心 1=实心
  int candleType;

  /// 缩放类型 1=左 2=中 3=右 4=跟随
  int zoomLockType;

  /// 每次缩放大小
  double zoomStep;

  /// k线默认宽度
  double klineWidth;

  /// 是否显示默认k线提示
  bool isShowKlineTipPannel;

  /// 副图高度
  double sideHeight;

  /// 高度
  double height;

  /// 宽度
  double width;

  /// 默认主图指标
  List main;

  /// 默认副图指标 副图数组代表副图数量
  List sides;

  /// 昨日收盘价
  double? lastClose;

  /// 首次加载回调
  Function? onLoading;

  /// 滚动到左边尽头回调 通常用来加载下一页数据
  Function? nextPage;

  /// 提示数据返回
  Function? onCrossing;

  // 右边空出k线数量
  int rightEmptyKlineAmount;

  /// 手势
  bool captureAllGestures;

  ///横轴手势
  bool captureHorizontalGestures;

  /// 竖轴手势
  bool captureVerticalGestures;

  /// K线上下文
  BuildContext? subContext;

  /// 当前页码
  int page = 1;

  @override
  _DsxKlineState createState() => _DsxKlineState();
}

class _DsxKlineState extends State<DsxKline> {
  InAppWebViewController? _webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        transparentBackground: true,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  double _opacity = 1.0;

  bool _isCreatedKline = false;

  bool _iscrossing = false;

  Timer? _timer;

  double scale = -1;

  bool _isFinished = true;
  List<String>? lastDatas;

  Function? onPanDown;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void update() async {
    if (_webViewController != null) {
      if (widget.datas != lastDatas) {
        updateKline();
        lastDatas = widget.datas;
      }
    }
  }

  @override
  void didUpdateWidget(DsxKline oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    update();
    return NotificationListener<DsxKlineNotification>(
      onNotification: (notification) {
        //print("通知更新：${notification.data}");
        if (notification.theend == true) {
          scrollTheend();
          return true;
        }
        if (notification.lastData != null) {
          refreshLastOneData(notification.lastData!, notification.cycle!);
          return true;
        }
        if (notification.startLoad) {
          startLoading(notification.chartType!, notification.width!);
        } else {
          widget.page = notification.page!;
          widget.datas = notification.data;
          //print("通知更新：${widget.page}");
          //setState(() {});
          updateKline();
        }

        return true;
      },
      child: Builder(builder: (context) {
        widget.subContext = context;

        return GestureDetector(
          //onPanDown: onPanDown,
          // onTap: () {
          //   print("onTap");
          //   crossHidden();
          // },
          // onTapDown: (details) {
          //   print("onTapDown");
          //   // 点击屏幕，十字架消失
          //   crossHidden();
          // },
          onScaleStart: (details) {
            _isFinished = true;
            onPanDown = null;
            scale = -1;
          },
          onScaleUpdate: (details) {
            if (scale == -1) {
              scale = details.scale;
            } else {
              double s = details.scale - scale;
              if (s.abs() > 0) {
                if (Platform.isAndroid) {
                  zoom(s > 0 ? widget.zoomStep : -widget.zoomStep);
                } else {
                  zoom(s > 0 ? widget.zoomStep : -widget.zoomStep);
                }
                scale = details.scale;
              }
            }
          },
          onScaleEnd: (details) {
            scale = -1;
          },
          onLongPress: () {},
          onLongPressStart: (details) {
            clearTimeout();
            _iscrossing = true;
            _isFinished = true;
            onPanDown = null;
            //print('onLongPressStart');
            cross(details.localPosition.dx, details.localPosition.dy);
          },
          onLongPressMoveUpdate: (details) {
            clearTimeout();
            _iscrossing = true;
            //print('onLongPressMoveUpdate');
            cross(details.localPosition.dx, details.localPosition.dy);
          },
          onLongPressEnd: (details) {
            //print('onLongPressEnd');
            _iscrossing = false;
          },
          onLongPressUp: () {
            _iscrossing = false;
            //print('onLongPressUp');
            // onPanDown = (detail) {
            //   crossHidden();
            //   onPanDown = null;
            //   setState(() {});
            // };

            delayHiddenCross();
            //setState(() {});
          },
          child: createInerWebView(context),
        );
      }),
    );
  }

  void delayHiddenCross() {
    _timer = Timer(const Duration(seconds: 3), () {
      if (!_iscrossing) crossHidden();
    });
    // and later, before the timer goes off...
  }

  void clearTimeout() {
    if (_timer != null) _timer!.cancel();
  }

  Widget createInerWebView(BuildContext context) {
    DsxKlineNotification.initContext = context;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        InAppWebView(
          initialOptions: options,
          initialData: InAppWebViewInitialData(data: html),
          onWebViewCreated: (controller) {
            _opacity = 1.0;
            _webViewController = controller;

            // 监听JS回调
            controller.addJavaScriptHandler(
                handlerName: 'nextPage',
                callback: (args) {
                  //print("收到来自web的消息" + args.toString());
                  if (nextPage is Function) nextPage(args);
                });
            controller.addJavaScriptHandler(
                handlerName: 'onLoading',
                callback: (args) {
                  //print("收到来自web的消息" + args.toString());
                  if (onLoading is Function) onLoading();
                });
            controller.addJavaScriptHandler(
                handlerName: 'showTipCallback',
                callback: (args) {
                  //print("收到来自web的消息" + args.toString());
                  if (onCrossing is Function) {
                    onCrossing(context, args[0], args[1]);
                  }
                });
          },
          onLoadResource: (controller, soure) {},
          onLoadStop: (controller, uri) {
            webViewComplate();
          },
          gestureRecognizers: getGestureRecognizers(),
          // onConsoleMessage: (InAppWebViewController controller,
          //     ConsoleMessage consoleMessage) {
          //   print("""
          //     console output:
          //       message: ${consoleMessage.message}
          //       messageLevel: ${consoleMessage.messageLevel}
          //     """);
          // },
        ),
        if (_opacity > 0)
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: _opacity,
              child: Container(
                color: widget.initBackgroundColor,
              ),
            ),
          ),
      ],
    );
  }

  webViewComplate() {
    loadCss();
    loadJs();
    showOpacity();
  }

  Set<Factory<OneSequenceGestureRecognizer>> getGestureRecognizers() {
    Set<Factory<OneSequenceGestureRecognizer>> set = Set();
    if (widget.captureAllGestures || widget.captureHorizontalGestures) {
      set.add(Factory<HorizontalDragGestureRecognizer>(() {
        return HorizontalDragGestureRecognizer()
          ..onStart = (DragStartDetails details) {}
          ..onUpdate = (DragUpdateDetails details) {}
          ..onDown = (DragDownDetails details) {}
          ..onCancel = () {}
          ..onEnd = (DragEndDetails details) {};
      }));
    }
    if (widget.captureAllGestures || widget.captureVerticalGestures) {
      set.add(Factory<VerticalDragGestureRecognizer>(() {
        return VerticalDragGestureRecognizer()
          ..onStart = (DragStartDetails details) {}
          ..onUpdate = (DragUpdateDetails details) {}
          ..onDown = (DragDownDetails details) {}
          ..onCancel = () {}
          ..onEnd = (DragEndDetails details) {};
      }));
    }
    return set;
  }

  showOpacity() async {
    await Future.delayed(const Duration(milliseconds: 100), () {
      _opacity = 0.0;
      setState(() {});
    });
  }

  loadJs() {
    String js = dsxKlineScript;
    eval(js, () {
      // 创建K线图
      createHtml();
    }, title: "执行K线图核心文件");
  }

  loadCss() {
    String js = '''
    var head = document.getElementsByTagName("head")[0];         
    var style = document.createElement('style');
    head.appendChild(style);
    style.innerHTML = '*{padding:0;margin:0;-webkit-touch-callout:none;-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none;}html{overflow:hidden;}body{position:fixed;top:0;left:0;overflow:hidden;width:100%;height:100%;}';
    ''';
    eval(js, () {}, title: "加载css样式");
  }

  createHtml() {
    String js = '''
        if(typeof(dsxKline)=="function"){
          dsxConfig.theme.white.klineWidth = ${widget.klineWidth};
          dsxConfig.theme.dark.klineWidth = ${widget.klineWidth};
          var c=document.getElementById("kline"); 
          var kline = new dsxKline({
              element:c,
              chartType:${widget.chartType},
              theme:"${widget.theme}",
              candleType:${widget.candleType},
              zoomLockType:${widget.zoomLockType},
              klineWidth:${widget.klineWidth},
              isShowKlineTipPannel:${widget.isShowKlineTipPannel},
              rightEmptyKlineAmount:${widget.rightEmptyKlineAmount},
              lastClose:${widget.lastClose},
              //dpr:2,
              sideHeight:${widget.sideHeight},
              // width:${widget.width},
              autoSize:true,
              //debug:true,
              main:${jsonEncode(widget.main)},
              sides:${jsonEncode(widget.sides)},
              mobileCross:true,
              //mobileZoom:true,
              // 调用正在加载
              onLoading:function(o){
                window.flutter_inappwebview.callHandler('onLoading',o).then(function(result) {});
              },
              // 滚动到最左边，进行加载下一页数据
              nextPage:function(data,index){
                window.flutter_inappwebview.callHandler('nextPage',data,index).then(function(result) {});
              },
              // 显示当前数据回调
              showTipCallback:function(data,index){
                  window.flutter_inappwebview.callHandler('onCrossing',data,index).then(function(result) {});
              },
          });
        }else{
          //document.body.innerHTML = "window.devicePixelRatio="+window.devicePixelRatio+" dsxKline="+typeof(dsxKline);
        }
    ''';
    eval(js, () {
      _isCreatedKline = true;
      if (widget.datas == null) {
        onLoading();
        return;
      }
      if (widget.datas!.isNotEmpty) updateKline();
    }, title: "创建K线图");
  }

  updateKline() {
    if (!_isCreatedKline) {
      return false;
    }
    String datas = widget.datas == null ? "[]" : jsonEncode(widget.datas);
    String js = '''
      function update(datas){
        try{
          var data = datas;
          if(data!=''){
            data = JSON.parse(data);
            if(kline!=null){
                kline.update({
                  theme:"${widget.theme}",
                  candleType:${widget.candleType},
                  zoomLockType:${widget.zoomLockType},
                  isShowKlineTipPannel:${widget.isShowKlineTipPannel},
                  lastClose:${widget.lastClose},
                  // main:${jsonEncode(widget.main)},
                  sides:${jsonEncode(widget.sides)},
                  page:${widget.page},
                  // width:${widget.width},
                  sideHeight:${widget.sideHeight},
                  //debug:true,
                  datas:data
                });
                kline.finishLoading();
            }
          }
          data = null;
        }catch(e){
          kline.finishLoading();
        }
      }
      update('$datas');
      ''';
    //print(datas);
    eval(js, () {}, title: "更新k线图");
  }

  onCrossing(BuildContext context, dynamic datas, int index) {
    //print(cross);
    if (widget.onCrossing is Function) {
      widget.onCrossing!(context, datas, index);
    }
  }

  onLoading() {
    if (widget.onLoading is Function) {
      widget.onLoading!(widget.subContext, widget);
    }
  }

  startLoading(int charType, double width) {
    widget.chartType = charType;
    if (width > 0) widget.width = width;
    String js =
        "if(kline) {kline.chartType=${widget.chartType};kline.startLoading();}";
    eval(js, () {
      //onLoading();
    });
  }

  /// 滚动到最左边，一般用来加载下一页
  nextPage(dynamic params) {
    //print(params);
    if (widget.nextPage is Function) {
      widget.nextPage!(widget.subContext, widget);
    }
  }

  cross(double x, double y) {
    String js = "if(kline) kline.cross($x,$y)";
    evalSync(js);
    //eval(js, (result) {}, title: "十字线");
  }

  crossHidden() {
    String js = "if(kline) kline.crossHidden();";
    evalSync(js);
    //eval(js, (result) {}, title: "十字线隐藏");
  }

  // 到尽头
  scrollTheend() {
    String js = "if(kline) kline.scrollThenend();";
    evalSync(js);
  }

  zoom(double n) {
    //print("缩放$n");
    String js = "if(kline) {kline.zoom($n,kline.width);}";
    evalSync(js);
    //eval(js, (result) {}, title: "缩放");
  }

  refreshLastOneData(String data, String cycle) {
    //print("refreshLastOneData");
    String js = "if(kline) {kline.refreshLastOneData('$data','$cycle');}";
    evalSync(js);
    //eval(js, (result) {}, title: "缩放");
  }

  eval(js, Function fn, {title: ""}) async {
    if (_webViewController == null) return;
    await _webViewController!
        .evaluateJavascript(source: js, contentWorld: ContentWorld.PAGE)
        .then((result) {}, onError: (error) {})
        .whenComplete(() {
      fn();
    });
  }

  evalSync(js) {
    if (_webViewController == null) return;
    if (_isFinished) {
      _isFinished = false;
      _webViewController!
          .evaluateJavascript(source: js, contentWorld: ContentWorld.PAGE)
          .whenComplete(() => _isFinished = true);
    }
  }
}

class DsxKlineNotification extends Notification {
  final String msg;
  final List<String>? data;
  final int? page;
  final bool startLoad;
  final int? chartType;
  final bool? theend;
  final String? lastData;
  final String? cycle;
  final double? width;
  static BuildContext? initContext;
  DsxKlineNotification(
    this.msg, {
    this.data,
    this.page,
    this.startLoad = false,
    this.chartType,
    this.theend,
    this.lastData,
    this.cycle,
    this.width,
  });

  static updateKline(datas, page) {
    if (DsxKlineNotification.initContext == null) return;
    Future.delayed(const Duration(milliseconds: 100), () {
      DsxKlineNotification(
        "开始更新K线图数据",
        page: page,
        data: datas,
      ).dispatch(DsxKlineNotification.initContext);
    });
  }

  // 通知开始加载数据
  static startLoading(chartType, width) {
    if (DsxKlineNotification.initContext == null) return;
    Future.delayed(const Duration(milliseconds: 100), () {
      DsxKlineNotification(
        "开始加载数据",
        startLoad: true,
        chartType: chartType,
        width: width,
      ).dispatch(DsxKlineNotification.initContext);
    });
  }

  static scrollTheend() {
    if (DsxKlineNotification.initContext == null) return;
    DsxKlineNotification("尽头", theend: true)
        .dispatch(DsxKlineNotification.initContext);
  }

  static refreshLastOneData(String data, String cycle) {
    //print(DsxKlineNotification.initContext);
    if (DsxKlineNotification.initContext == null) return;
    DsxKlineNotification("更新最后一个数据", lastData: data, cycle: cycle)
        .dispatch(DsxKlineNotification.initContext);
  }
}
