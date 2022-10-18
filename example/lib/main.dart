import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baidu_speech_plugin/flutter_baidu_speech_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _resultString = '';
  String _wakeUpString = '';
  String _btnStatusString = '按住说话';

  @override
  void initState() {
    super.initState();
    //          mWakeUpManager.startWakeUp("24662221",
    //                 "4cbxGXgGja2fpMCrMv1Zb3aA",
    //                 "3GVIkRGY1Bq3QV3yalZiD6QBFSYnIZys");

    FlutterBaiduSpeechPlugin.initSDK(
      // appId: '24662215',
      appId: '24662221',
      // appKey: 'XMG0i4CPCxN6aTvakDZUWVvk',
      appKey: '4cbxGXgGja2fpMCrMv1Zb3aA',
      // appSecret: 'UIyCMX34RRwru6b5db5r8LhuNG9FGIsX',
      appSecret: '3GVIkRGY1Bq3QV3yalZiD6QBFSYnIZys',
      onEvent: (value) {
        if (kDebugMode) {
          print('监听回调 = $value');
        }

        Map<String, dynamic> result = Map.from(value);
        String status = result['status'] as String;
        String? data = result['data'] as String?;
        if (status == BaiduSpeechStatusType.flushData.name) {
          setState(() {
            _resultString = data ?? '';
          });
        } else if (status == BaiduSpeechStatusType.statusFinish.name) {
          setState(() {
            _resultString = data ?? '';
            _wakeUpString = '';
          });
        } else if (status == BaiduSpeechStatusType.volumeChanged.name) {
          print('当前音量 = $data');
        } else if (status == BaiduSpeechStatusType.statusTriggered.name) {
          ///唤醒
          setState(() {
            _wakeUpString = data ?? '';
            FlutterBaiduSpeechPlugin.startRecognition(
                wakeUpWord: _wakeUpString);
          });
        } else if (status == BaiduSpeechStatusType.statusError.name) {
          print('语音识别/唤醒失败');
        }
      },
    );

    ///创建语音识别
    FlutterBaiduSpeechPlugin.create(
      type: BaiduSpeechBuildType.asr,
    );

    ///创建语音唤醒
    FlutterBaiduSpeechPlugin.create(
      type: BaiduSpeechBuildType.wakeUp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '识别结果 \n $_resultString',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              GestureDetector(
                onTapDown: (value) {
                  setState(() {
                    _btnStatusString = '松开停止';
                    FlutterBaiduSpeechPlugin.startRecognition();
                  });
                },
                onTapUp: (value) {
                  setState(() {
                    _btnStatusString = '按住说话';
                    FlutterBaiduSpeechPlugin.stopRecognition();
                  });
                },
                onTapCancel: () {
                  setState(() {
                    _btnStatusString = '按住说话';
                    FlutterBaiduSpeechPlugin.stopRecognition();
                  });
                },
                child: Container(
                  color: _btnStatusString == '松开停止'
                      ? Colors.tealAccent
                      : Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    _btnStatusString,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton(
                  onPressed: () {
                    FlutterBaiduSpeechPlugin.startMonitorWakeUp();
                    setState(() {
                      _wakeUpString = '';
                    });
                  },
                  child: const Text('开始语音唤醒')),
              ElevatedButton(
                  onPressed: () {
                    FlutterBaiduSpeechPlugin.stopMonitorWakeUp();
                    setState(() {
                      _wakeUpString = '';
                    });
                  },
                  child: const Text('关闭语音唤醒')),
              const SizedBox(
                height: 30,
              ),
              Text(
                _wakeUpString.isEmpty ? '' : '已唤醒 $_wakeUpString',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
