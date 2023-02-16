package com.example.flutter_baidu_speech_plugin;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleEventObserver;
import androidx.lifecycle.LifecycleOwner;

import com.baidu.speech.EventListener;
import com.baidu.speech.EventManager;
import com.baidu.speech.EventManagerFactory;
import com.baidu.speech.asr.SpeechConstant;
import com.example.flutter_baidu_speech_plugin.vo.AsrVo;
import com.google.gson.Gson;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class AsrManager implements LifecycleEventObserver {
    private static final String TAG = "AsrManager";
    private Context mContext;
    private EventManager mAsrEventManager;
    private AsrEventListener mAsrEvenListener;
    private AsrListener mAsrListener;

    private AsrManager(Context context) {
        mContext = context;
    }

    public static AsrManager with(Context context) {
        return new AsrManager(context);
    }

    public AsrManager addListener(AsrListener asrListener) {
        mAsrListener = asrListener;
        return this;
    }

    public AsrManager addLifecycleOwner(LifecycleOwner owner) {
        if (owner != null) {
            owner.getLifecycle().addObserver(this);
        }
        return this;
    }

    public AsrManager build() {
        initAsrManager();
        return this;
    }


    private void initAsrManager() {
        if (mAsrEventManager == null) {
            mAsrEventManager = EventManagerFactory.create(mContext, "asr");
            mAsrEventManager.registerListener(mAsrEvenListener = new AsrEventListener());
        }
    }

    public void asrStart(String appId, String appKey, String secret) {
        Map<String, Object> params = new HashMap<>();
        params.put(SpeechConstant.APP_ID, appId);
        params.put(SpeechConstant.APP_KEY, appKey);
        params.put(SpeechConstant.SECRET, secret);

        //是否激活音量回调
        params.put(SpeechConstant.ACCEPT_AUDIO_VOLUME, true);
        params.put(SpeechConstant.VAD, SpeechConstant.VAD_DNN);
        // 使用1537中文模型。其它PID参数请看文档
        params.put(SpeechConstant.PID, 1537);
        //是否禁用标点
        params.put(SpeechConstant.DISABLE_PUNCTUATION, true);
        String json = new JSONObject(params).toString();
        Log.i(TAG, "start json:" + json);
        asrCancel();
        if (mAsrEventManager != null) {
            mAsrEventManager.send(SpeechConstant.ASR_START, json, null, 0, 0);
        }
    }

    public void asrStop() {
        if (mAsrEventManager != null) {
            mAsrEventManager.send(SpeechConstant.ASR_STOP, "{}", null, 0, 0);
        }
    }

    private void asrCancel() {
        if (mAsrEventManager != null) {
            mAsrEventManager.send(SpeechConstant.ASR_CANCEL, "{}", null, 0, 0);
        }
    }

    public void asrRelease() {
        if (mAsrEventManager == null) {
            return;
        }
        asrCancel();
        mAsrEventManager.unregisterListener(mAsrEvenListener);
        mAsrEventManager = null;
    }


    class AsrEventListener implements EventListener {
        @Override
        public void onEvent(String name, String params, byte[] data, int offset, int length) {
            Log.d(TAG, "onEvent name:" + name + "  params:" + params + " ");
            if (mAsrListener == null) return;

            if (name.equals(SpeechConstant.CALLBACK_EVENT_ASR_READY)) {
                mAsrListener.asrReady();

            } else if (name.equals(SpeechConstant.CALLBACK_EVENT_ASR_BEGIN)) {
                mAsrListener.asrBegin();

            } else if (name.equals(SpeechConstant.CALLBACK_EVENT_ASR_END)) {
                mAsrListener.asrEnd();

            } else if (name.equals(SpeechConstant.CALLBACK_EVENT_ASR_PARTIAL)) {
//                LogUtils.i(TAG, "ASR_PARTIAL params:" + params);
                AsrVo asrVo = new Gson().fromJson(params, AsrVo.class);
//
                if (asrVo == null) {
                    Log.d(TAG, "ASR_PARTIAL recognizerVo  is null !");
                    return;
                }
                if (AsrVo.isFinalResult(asrVo)) {
                    Log.d(TAG, "ASR_PARTIAL isFinalResult:" + new Gson().toJson(asrVo.getResultsRecognition()));
                    mAsrListener.asrFinalResult(asrVo.getResultsRecognition());
                } else if (AsrVo.isNluResult(asrVo)) {
                    Log.d(TAG, "ASR_PARTIAL isNluResult:" + new Gson().toJson(asrVo.getResultsRecognition()));

                } else if (AsrVo.isPartialResult(asrVo)) {
                    Log.d(TAG, "ASR_PARTIAL isPartialResult:" + new Gson().toJson(asrVo.getResultsRecognition()));
                    mAsrListener.asrPartialResult(asrVo.getResultsRecognition());
                }
                mAsrListener.asrPartial(params);

            } else if (name.equals(SpeechConstant.CALLBACK_EVENT_ASR_FINISH)) {
//                // 识别结束
                AsrVo asrVo = new Gson().fromJson(params, AsrVo.class);
                if (asrVo == null) {
                    Log.d(TAG, "ASR_PARTIAL recognizerVo  is null !");
                    return;
                }
                if (AsrVo.hasError(asrVo)) {
//                    int errorCode = asrVo.getError();
//                    int subErrorCode = asrVo.getSubError();
                    Log.d(TAG, "ASR_PARTIAL recognizerVo  error");
                    mAsrListener.asrErrorFinish();
                } else {
                    Log.d(TAG, "ASR_PARTIAL CALLBACK_EVENT_ASR_FINISH:" + new Gson().toJson(asrVo.getResultsRecognition()));
                    mAsrListener.asrFinish();
                }
            } else if (name.equals(SpeechConstant.CALLBACK_EVENT_ASR_EXIT)) {
                mAsrListener.asrExit();

            } else if (name.equals(SpeechConstant.CALLBACK_EVENT_ASR_VOLUME)) {
                Volume vol = parseVolumeJson(params);
                mAsrListener.asrVolume(vol.volumePercent, vol.volume);
            } else if (name.equals(SpeechConstant.CALLBACK_EVENT_ASR_AUDIO)) {
                if (data.length != length) {
                    Log.d(TAG, "CALLBACK_EVENT_ASR_AUDIO " + "internal error: asr.audio callback data length is not equal to length param");
                }
                mAsrListener.asrAudio();
            }


        }
    }
    private Volume parseVolumeJson(String jsonStr) {
        Volume vol = new Volume();
        vol.origalJson = jsonStr;
        try {
            JSONObject json = new JSONObject(jsonStr);
            vol.volumePercent = json.getInt("volume-percent");
            vol.volume = json.getInt("volume");
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return vol;
    }

    private class Volume {
        private int volumePercent = -1;
        private int volume = -1;
        private String origalJson;
    }

    @Override
    public void onStateChanged(@NonNull LifecycleOwner source, @NonNull Lifecycle.Event event) {
        Log.d(TAG, "onStateChanged  event:" + event.name());
        switch (event) {
            case ON_RESUME:
//                onResume();
                break;
            case ON_PAUSE:
//                onPause();
                break;
            case ON_DESTROY:
//                onDestroy();
                break;
            default:
                break;
        }
    }
}
