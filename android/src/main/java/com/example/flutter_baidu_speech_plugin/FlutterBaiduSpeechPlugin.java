package com.example.flutter_baidu_speech_plugin;

import android.content.Context;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterSpeechPlugin
 */
public class FlutterBaiduSpeechPlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private EventChannel evenChannel;
    private EventChannel.EventSink eventSink;
    private Context applicationContext;
    private String appId;
    private String appKey;
    private String appSecret;
    private AsrManager asrManager;
    private WakeUpManager wakeUpManager;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_baidu_speech_plugin");
        channel.setMethodCallHandler(this);
        evenChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_baidu_speech_plugin/event");
        evenChannel.setStreamHandler(this);
        applicationContext = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("create")) {
            if (call.arguments instanceof Map) {
                Map<String, Object> map = (Map) call.arguments;
                int type = Integer.parseInt(map.get("type").toString());
                appId = map.get("appId").toString();
                appKey = map.get("appKey").toString();
                appSecret = map.get("appSecret").toString();
                if (0 == type) {
                    asrManager = AsrManager.with(applicationContext)
                            .addListener(new AsrListener() {
                                @Override
                                public void asrReady() {
                                    log("asrReady");
                                }

                                @Override
                                public void asrFinalResult(List<String> result) {
                                    log("asrFinalResult:" + result.get(0));
                                    if (eventSink != null) {
                                        HashMap<String, String> map = new HashMap<>();
                                        map.put("status", "statusFinish");
                                        map.put("data", result.get(0));
                                        map.put("type", String.valueOf(type));
                                        eventSink.success(map);
                                    }
                                }

                                @Override
                                public void asrErrorFinish() {
                                    log("asrErrorFinish");
                                    if (eventSink != null) {
                                        HashMap<String, String> map = new HashMap<>();
                                        map.put("status", "statusError");
                                        map.put("data", "");
                                        map.put("type", String.valueOf(type));
                                        eventSink.success(map);
                                    }
                                }

                                @Override
                                public void asrPartialResult(List<String> result) {
                                    log("asrPartialResult:" + result.get(0));
                                    if (eventSink != null) {
                                        HashMap<String, String> map = new HashMap<>();
                                        map.put("status", "flushData");
                                        map.put("data", result.get(0));
                                        map.put("type", String.valueOf(type));
                                        eventSink.success(map);
                                    }

                                }

                                @Override
                                public void asrVolume(int volumePercent, int volume) {
                                    if (eventSink != null) {
                                        HashMap<String, String> map = new HashMap<>();
                                        map.put("status", "volumeChanged");
                                        map.put("data", String.valueOf(volumePercent));
                                        map.put("type", String.valueOf(type));
                                        eventSink.success(map);
                                    }
                                }
                            }).build();
                }
                if (1 == type) {
                    wakeUpManager = WakeUpManager.with(applicationContext)
                            .addListener(new WakeUpListener() {
                                @Override
                                public void wakeUpError() {
                                    if (eventSink != null) {
                                        HashMap<String, String> map = new HashMap<>();
                                        map.put("status", "statusError");
                                        map.put("data", "");
                                        map.put("type", String.valueOf(type));
                                        eventSink.success(map);
                                    }
                                }

                                @Override
                                public void wakeUpSuccess(String result) {
                                    log("wakeUpSuccess:" + result);
                                    if (eventSink != null) {
                                        HashMap<String, String> map = new HashMap<>();
                                        map.put("status", "statusTriggered");
                                        map.put("data", result);
                                        map.put("type", String.valueOf(type));
                                        eventSink.success(map);
                                    }
                                }
                            }).build();
                }
            }

        } else if (call.method.equals("startRecognition")) {
            log("startRecognition");
            if (asrManager != null) {
                asrManager.asrStart(appId, appKey, appSecret);
            }


        } else if (call.method.equals("stopRecognition")) {
            log("stopRecognition");
            if (asrManager != null) {
                asrManager.asrStop();
            }

        } else if (call.method.equals("startMonitorWakeUp")) {
            log("startMonitorWakeUp");
            if (wakeUpManager != null) {
                wakeUpManager.startWakeUp(appId, appKey, appSecret);
            }

        } else if (call.method.equals("stopMonitorWakeUp")) {
            log("stopMonitorWakeUp");
            if (wakeUpManager != null) {
                wakeUpManager.stopWakeUp();
            }

        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
        applicationContext = null;
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        eventSink = events;

    }

    @Override
    public void onCancel(Object arguments) {
        evenChannel.setStreamHandler(null);
        evenChannel = null;
        eventSink = null;
        Log.d("onCancel", arguments.toString());
    }

    private void log(String msg) {
        Log.d("FlutterBaiduSpeechPlugin", msg);
    }


}