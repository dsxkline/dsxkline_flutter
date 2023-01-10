# 大师兄K线图 flutter sdk
基于Dart语言实现，依赖 flutter_inappwebview与Js通信实现，其他语言类似

具体文档可参考：http://www.dsxkline.com

完整的股票金融App demo可参考 http://www.dsxkline.com/cloudstrategy/

<img src="http://www.dsxkline.com/cloudstrategy/1.png">

## 预览
https://user-images.githubusercontent.com/105279193/168729994-1d809611-a9f6-41a8-bd2c-0e8d8051b6da.mp4

# 大师兄K线图

纯JS(ES5)语言进行开发，几乎完美适配所有浏览器平台(ie678除外)，移动端电脑端混合开发媲美原生体验！

dsxkline 支持基本功能，滚动缩放滑动分页实时刷新，支持MA，BOLL、VOL、KDJ、MACD、RSI、WR、CCI、BIAS、PSY等指标

支持主流开发平台 android,ios,flutter,web,h5,c#等

SDK:

web:https://github.com/dsxkline/dsxkline_js

ios:https://github.com/dsxkline/dsxkline_iphone

android:https://github.com/dsxkline/dsxkline_android

flutter:https://github.com/dsxkline/dsxkline_flutter

C#:https://github.com/dsxkline/dsxkline_net

h5:http://www.dsxkline.com/demo/dsxkline/index.html

## 预览
<img src="https://user-images.githubusercontent.com/105279193/169232280-ce4b24d2-3b9d-47ac-9f10-4eaaa5122ff7.gif" width=320>

<img src="https://user-images.githubusercontent.com/105279193/211478784-09c197a6-be5b-4869-8170-3af8e8cf6ffc.jpeg" width=320>

<img src="https://user-images.githubusercontent.com/105279193/169196992-9906ec38-f8a9-447c-9a42-e1c10129ac8f.gif" width=620>

 

## 官方网站
http://www.dsxkline.com

demo: http://www.dsxkline.com/demo/dsxkline/index.html

交流: QQ群1(148556652)

## 开始
    <script src="http://www.dsxkline.com/dsx.kline.js></script>
#### 创建K线图
    <div id="kline"></div>
    var c=document.getElementById("kline"); 
    var kline = new dsxKline({
        element:c,
        onLoading:function(o){
            // 开始请求加载数据
        },
        nextPage:function(data,index){
            // 开始请求加载下一页数据
        },
        onCrossing:function(data,index){
            // 十字线移动数据
        },
        updateComplate:function(){
            // 完成K线一次更新
        }
    });
#### 更新K线图
    kline.update({
        chartType:dsxConfig.chartType.timeSharing,
        //theme:"dark",
        candleType:dsxConfig.candleType.hollow,
        zoomLockType:dsxConfig.zoomLockType.right,
        isShowKlineTipPannel:false,
        sides:kline.chartType<=1?["VOL"]:["VOL","MACD"],
        datas:data,
    });
    kline.finishLoading();
#### 刷新最新数据
    // 周期 cycle=t,d,w,m,y,m1,t5 分别代表 分时,日K,周K,年K,1分钟,五日
    // data为最后一根K线数据，数据结构 分时图=[日期,时间,价格,成交量,成交额] K线图=[日期,开,高,低,收,成交量,成交额] 分钟K线=[日期,时间,开,高,低,收,成交量,成交额]
    kline.refreshLastOneData(data,cycle);

## 属性
|属性|名称|类型|必需|默认值|备注|
|----|----|----|----|----|----|
|theme	|主题	|string|	否	|white|	white,dark|
|chartType	|图标类型|	int|	否	|0	|分时图=0，五日=1，k线图=2|
|market|	交易所	|string	|否	|sh|	sh,sz,bj,hk,us|
|candleType|	蜡烛图类型|	int	|否	|0	|空心=0 实心=1|
|dpr	|屏幕dpr	|float|否	|2	|自动适配|
|element|	画布对象|	dom|	是	|	|
|width|	宽度|	float	|否	|画布宽度|	默认跟element适配|
|height|	高度	|float	|否	|画布高度|	默认跟element适配|
|paddingTop	|顶部间距	|float|	否|	20	||
|paddingMiddle|	主副图间距	|float	|否	|20	||
|paddingBottom	|底部间距	|float	|否	|1	||
|autoSize	|自动大小	|boolean	|否	|false	|为true根据element自动适应|
|datas	|数据	|int	|否|	null	|查看数据规范|
|lastClose|	昨收	|int|	否	|null	|当前股票昨日收盘价|
|mobileCross	|十字线移动端接管	|boolean|	否	|false|	需要移动端实现十字线时启用|
|onCrossing	|滑动十字线回调	|function	|否	|0	|返回十字线当前数据|
|zoomstep	|缩放步长|	float|否	|0.5	|每次缩放多少像素|
|zoomMin	|缩小最小值	|float	|否	|3	||
|zoomMax|	放大最大值	|float|	否	|50	||
|zoomLockType	|缩放类型|	int	|否|	2	|1=左，2=中，3=右，4=跟随鼠标|
|mobileZoom	|缩放手势移动端接管	|boolean|	否	|false	|移动端实现缩放时启用|
|sides|	副图指标	|array|	否	|["MA"]	|支持指标 MA,BOLL|
|main	|主图指标	|array|	否|	["VOL"]	|支持指标 VOL,MACD,KDJ,RSI|
|sideHeight	|副图高度	|float	|否	|height*20%	|默认为高度的20%|
|mainHeight|	主图高度	|float	|否		||
|debug	|debug模式	|boolean|	否	|false	||
|nextPage	|加载下一页|	function|	否	|0	|滚动到最左边的时候加载下一页数据|
|rightEmptyKlineAmount	|右边空数据	|int|	否	|0	|默认图表右边空出多少根K线|
|onLoading	|开始加载回调	|function	|否	|0	|初始化加载数据，首次请求数据需要定义在此|
|updateComplate	|更新完成回调	|function|	否	|0	|图表完成一次更新结束|
|timePeriod	|交易时间段|	string	|否	|9:30-11:30,13:00-15:00	|为空启用系统内置|
|isShowKlineTipPannel	|显示内置K线提示面板	|boolean	|否	|true	|自主实现K线数据提示请关闭|
|page	|页码	|int	|否	|1	|加载下一页数据时需要传入页码|
|theend	|滚动到尽头	|boolean	|否	|false	|下一页没有数据需要标志为true|

## 配置 dsxConfig
#### k线图表类型
    // k线图表类型
    dsxConfig.chartType = {
        timeSharing:0,  // 分时图
        timeSharing5:1, // 五日分时图
        candle:2,       // K线图
    }
#### 蜡烛图空心实心
    // 蜡烛图实心空心
    dsxConfig.candleType = {
        hollow:0, // 空心
        solid:1   // 实心
    }
#### 缩放K线锁定类型
    // 缩放K线锁定类型
    dsxConfig.zoomLockType = {
        left:1,         // 锁定左边进行缩放
        middle:2,       // 锁定中间进行缩放
        right:3,        // 锁定右边进行缩放
        follow:4,       // 跟随鼠标位置进行缩放，web版效果比较好
    }
#### 交易所类型及其交易时间
    // 交易所类型及其交易时间
    dsxConfig.market = {
        sh:"9:30-11:30,13:00-15:00", // 上海
        sz:"9:30-11:30,13:00-15:00", // 深圳
        bj:"9:30-11:30,13:00-15:00", // 北京
        hk:"9:30-12:00,13:00-16:00", // 港股
        us:"9:30-12:00,12:00-16:00", // 美股
        fu:"9:30-12:00,12:00-16:00", // 期货
        sp:"9:30-12:00,12:00-16:00", // 现货
        wh:"9:30-12:00,12:00-16:00", // 外汇
    }
#### 指标配置
    // 指标配置
    dsxConfig.index = {
        VOL:{
            // 显示名称
            title:"成交量",
            // 参数配置值
            value:{VOL:0,MA5:5,MA10:10},
            // 画线配置
            draw:{VOL:{model:"column",color:"CLOSE",hiddenTitle:true},MA5:{model:"line",color:"#FFA500"},MA10:{model:"line",color:"#87CEFA"}},
            // 支持的图形
            chartType:[dsxConfig.chartType.timeSharing,dsxConfig.chartType.timeSharing5,dsxConfig.chartType.candle],
            // 支持的图表位置 主图 main，副图 sides
            location:['sides']

        },
        TMA:{
            title:"",
            value:{"均价":1},
            draw:{ "均价":{model:"line",color:"#FFA500"},"新值":{model:"text",color:"",colorValue:0}},
            chartType:[dsxConfig.chartType.timeSharing,dsxConfig.chartType.timeSharing5],
            location:['main']
        },
        MA:{
            title:"均线",
            value:{ MA5:5, MA10:10, MA30:30,MA60:60},
            draw:{ MA5:{model:"line",color:"#FFA500"}, MA10:{model:"line",color:"#87CEFA"}, MA30:{model:"line",color:"#BA55D3"},MA60:{model:"line",color:"#808000"},},
            chartType:[dsxConfig.chartType.timeSharing,dsxConfig.chartType.timeSharing5,dsxConfig.chartType.candle],
            location:['main']
        },
        MACD:{
            title:"MACD(26,9,12)",
            value:{DIFF:0,DEA:0,MACD:0,long:26,d:9,short:12},
            draw:{DIFF:{model:"line",color:"#FFA500"},DEA:{model:"line",color:"#87CEFA"}, MACD:{model:"column",color:"#BA55D3"}},
            chartType:[dsxConfig.chartType.timeSharing,dsxConfig.chartType.timeSharing5,dsxConfig.chartType.candle],
            location:['sides']
        },
        KDJ:{
            title:"KDJ(9,3,3)",
            value:{K:9,D:3,J:3},
            draw:{K:{model:"line",color:"#FFA500"},D:{model:"line",color:"#87CEFA"},J:{model:"line",color:"#BA55D3"}},
            chartType:[dsxConfig.chartType.candle],
            location:['sides']
        },
        BOLL:{
            title:"BOLL(20,2)",
            value:{UP:0,MID:0,LOW:0,N:20,M:2},
            draw:{UP:{model:"line",color:"#FFA500"},MID:{model:"line",color:"#87CEFA"}, LOW:{model:"line",color:"#BA55D3"}},
            chartType:[dsxConfig.chartType.candle],
            location:['main']
        },
        RSI:{
            title:"RSI(6,12,24)",
            value:{RSI6:6,RSI12:12,RSI24:24},
            draw:{RSI6:{model:"line",color:"#FFA500"},RSI12:{model:"line",color:"#87CEFA"}, RSI24:{model:"line",color:"#BA55D3"}},
            chartType:[dsxConfig.chartType.timeSharing,dsxConfig.chartType.timeSharing5,dsxConfig.chartType.candle],
            location:['sides']
        },
        WR:{
            title:"WR(6,10)",
            value:{WR6:6,WR10:10},
            draw:{WR6:{model:"line",color:"#FFA500"},WR10:{model:"line",color:"#87CEFA"}},
            chartType:[dsxConfig.chartType.candle],
            location:['sides']
        },
        BIAS:{
            title:"BIAS(6,12,24)",
            value:{BIAS6:6,BIAS12:12,BIAS24:24},
            draw:{BIAS6:{model:"line",color:"#FFA500"},BIAS12:{model:"line",color:"#87CEFA"}, BIAS24:{model:"line",color:"#BA55D3"}},
            chartType:[dsxConfig.chartType.candle],
            location:['sides']
        },
        CCI:{
            title:"CCI(14)",
            value:{CCI14:14},
            draw:{CCI14:{model:"line",color:"#FFA500"}},
            chartType:[dsxConfig.chartType.candle],
            location:['sides']
        },
        PSY:{
            title:"PSY(12,6)",
            value:{PSY:12,PSYMA:6},
            draw:{PSY:{model:"line",color:"#FFA500"},PSYMA:{model:"line",color:"#87CEFA"}},
            chartType:[dsxConfig.chartType.candle],
            location:['sides']
        },

    }
#### 主题配置
    // 主题配置
    dsxConfig.theme = {
        white:{
            backgroundColor:"#ffffff", // 背景颜色
            color:"#333333",// 字体颜色
            fontSize:window.devicePixelRatio<=1?12:10,// 字体大小
            redColor:"#F44336",// 蜡烛图红色
            greenColor:"#4CAF50",// 蜡烛图绿色
            crossLineColor:"#2196F3",// 十字线颜色
            crossLineWidth:1.0,// 十字线宽度
            fontBgColor:"#2196F3", // 文字背景颜色 十字线提示的文字背景颜色
            gridLineColor:"#eeeeee",// 网格线颜色
            gridLineCount:3,// 网格线数量
            gridLineWidth:1.0,// 网格线的宽度
            lineWidth:1.0, // 线条的大小 指标线条的大小
            klineWidth:10,// 一根k线的默认宽度
            klinePadding:1,// k线之间的间隔
            timeSharingLineColor:"#2196F3",// 分时图价格线的颜色
            timeSharingLineFillColor:"rgba(65,105,225,0.1)", // 分时图价格线区域填充颜色
        },
        dark:{
            backgroundColor:"rgba(19, 23, 34, 1)", // 背景颜色
            color:"#c5cbce",// 字体颜色
            fontSize:window.devicePixelRatio<=1?12:10,// 字体大小
            redColor:"#F44336",// 蜡烛图红色
            greenColor:"#4CAF50",// 蜡烛图绿色
            crossLineColor:"#2196F3",// 十字线颜色
            crossLineWidth:1.0,// 十字线宽度
            fontBgColor:"#2196F3", // 文字背景颜色
            gridLineColor:"#191b28",// 网格线颜色
            gridLineCount:3,// 网格线数量
            gridLineWidth:1.0,// 网格线的宽度
            lineWidth:1.0, // 线条的大小 指标线条的大小
            klineWidth:10,// 一根k线的默认宽度
            klinePadding:1,// k线之间的间隔
            timeSharingLineColor:"#2196F3",// 分时图价格线的颜色
            timeSharingLineFillColor:"rgba(65,105,225,0.1)", // 分时图价格线区域填充颜色
        }
    }
## 图表数据格式
#### 分时图
    数组 ["日期,时间,报价,成交量,成交额"]
    [
    "20220301,0930,3001.23,453999595,233944858",
    "20220301,0931,3001.23,453999595,233944858",
    "20220301,0932,3001.23,453999595,233944858",
    ]
#### 五日分时图
    数组 ["日期,时间,报价,成交量,成交额"],相当于连续五天的分时图数据
    [
    "20220301,0930,3001.23,453999595,233944858",
    "20220301,0931,3001.23,453999595,233944858",
    "20220301,0932,3001.23,453999595,233944858",
    ...
    "20220302,0930,3001.23,453999595,233944858",
    "20220302,0931,3001.23,453999595,233944858",
    "20220302,0932,3001.23,453999595,233944858",
    ...
    "20220303,0930,3001.23,453999595,233944858",
    "20220303,0931,3001.23,453999595,233944858",
    "20220303,0932,3001.23,453999595,233944858",
    ...
    "20220304,0930,3001.23,453999595,233944858",
    "20220304,0931,3001.23,453999595,233944858",
    "20220304,0932,3001.23,453999595,233944858",
    ...
    "20220305,0930,3001.23,453999595,233944858",
    "20220305,0931,3001.23,453999595,233944858",
    "20220305,0932,3001.23,453999595,233944858",
    ]
#### K线图
    数组 ["日期,开盘价,最高价,最低价,收盘价,成交量,成交额"]
    [
    "20220301,3001.23,3030.21,2989.3,3002.4,453999595,233944858",
    "20220302,3001.23,3030.21,2989.3,3002.4,453999595,233944858",
    "20220303,3001.23,3030.21,2989.3,3002.4,453999595,233944858",
    ]
#### 分钟K线图
    数组 ["日期,时间,开盘价,最高价,最低价,收盘价,成交量,成交额"]
    [
    "20220301,0930,3001.23,3030.21,2989.3,3002.4,453999595,233944858",
    "20220302,0931,3001.23,3030.21,2989.3,3002.4,453999595,233944858",
    "20220303,0932,3001.23,3030.21,2989.3,3002.4,453999595,233944858",
    ]

