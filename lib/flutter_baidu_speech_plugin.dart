import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_baidu_speech_plugin/models/sdk_data_cache.dart';

enum BaiduSpeechBuildType {
  asr,
  wakeUp,
}

enum BaiduSpeechStatusType {
  ///语音识别中
  flushData,

  ///语音识别完毕
  statusFinish,

  ///音量变化
  volumeChanged,

  ///识别/唤醒失败
  statusError,

  ///唤醒
  statusTriggered,
}

class FlutterBaiduSpeechPlugin {
  static const _methodChannel = MethodChannel('flutter_baidu_speech_plugin');

  /// 声明监听回调通道
  static const EventChannel _eventChannel =
      EventChannel("flutter_baidu_speech_plugin/event");

  /// 监听器
  static Stream<dynamic>? _onListener;

  /// 初始化监听
  static Stream<dynamic>? onChange() {
    _onListener ??= _eventChannel.receiveBroadcastStream();
    return _onListener;
  }

  static initSDK({
    required String appId,
    required String appKey,
    required String appSecret,
    required Function(dynamic) onEvent,
  }) {
    SdkDataCache().appId = appId;
    SdkDataCache().appKey = appKey;
    SdkDataCache().appSecret = appSecret;
    onChange()!.listen(onEvent);
    return;
  }

  ///创建语音识别/唤醒
  static Future create({
    required BaiduSpeechBuildType type,
  }) {
    return _methodChannel.invokeMethod('create', {
      'type': type.index,
      'appId': SdkDataCache().appId ?? '',
      'appKey': SdkDataCache().appKey ?? '',
      'appSecret': SdkDataCache().appSecret ?? '',
    });
  }

  ///开始语音识别
  static Future startRecognition({String? wakeUpWord}) {
    return _methodChannel.invokeMethod('startRecognition', wakeUpWord);
  }

  ///结束语音识别
  static Future stopRecognition() {
    return _methodChannel.invokeMethod('stopRecognition');
  }

  ///开始语音唤醒
  static Future startMonitorWakeUp() {
    return _methodChannel.invokeMethod('startMonitorWakeUp');
  }

  ///结束语音唤醒
  static Future stopMonitorWakeUp() {
    return _methodChannel.invokeMethod('stopMonitorWakeUp');
  }
}
