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
import com.example.flutter_baidu_speech_plugin.vo.WakeUpVo;
import com.google.gson.Gson;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class WakeUpManager implements LifecycleEventObserver {
    private static final String TAG = "WakeUpManager";

    private Context mContext;
    private WakeUpListener mWakeUpListener;
    private EventManager mWakeUpEventManager;
    private WakeUpEventListener mWakeUpEventListener;

    private WakeUpManager(Context context) {
        mContext = context;
    }

    public static WakeUpManager with(Context context) {
        return new WakeUpManager(context);
    }

    public WakeUpManager addListener(WakeUpListener wakeUpListener) {
        mWakeUpListener = wakeUpListener;
        return this;
    }

    public WakeUpManager addLifecycleOwner(LifecycleOwner owner) {
        if (owner != null) {
            owner.getLifecycle().addObserver(this);
        }
        return this;
    }

    public WakeUpManager build() {
        initVoiceWakeUpManager();
        return this;
    }


    private void initVoiceWakeUpManager() {
        if (mWakeUpEventManager == null) {
            mWakeUpEventManager = EventManagerFactory.create(mContext, "wp");
            mWakeUpEventManager.registerListener(mWakeUpEventListener = new WakeUpEventListener());
        }

    }

    public void startWakeUp(String appId, String appKey, String secret) {
        Map<String, Object> params = new HashMap<>();
        params.put(SpeechConstant.APP_ID, appId);
        params.put(SpeechConstant.APP_KEY, appKey);
        params.put(SpeechConstant.SECRET, secret);
        params.put(SpeechConstant.WP_WORDS_FILE, "assets:///WakeUp.bin");
        String json = new JSONObject(params).toString();
        Log.d(TAG, "start json:" + json);
        if (mWakeUpEventManager != null) {
            mWakeUpEventManager.send(SpeechConstant.WAKEUP_START, json, null, 0, 0);
        }
    }


    public void stopWakeUp() {
        if (mWakeUpEventManager != null) {
            mWakeUpEventManager.send(SpeechConstant.WAKEUP_STOP, null, null, 0, 0);
        }
    }


    public void wakeUpRelease() {
        stopWakeUp();
        if (mWakeUpEventManager != null) {
            mWakeUpEventManager.unregisterListener(mWakeUpEventListener);
            mWakeUpEventManager = null;
        }
    }


    class WakeUpEventListener implements EventListener {

        @Override
        public void onEvent(String name, String params, byte[] data, int offset, int length) {
            Log.d(TAG, "onEvent name:" + name + "  params:" + params + " ");
            if (mWakeUpListener == null) return;
            if (SpeechConstant.CALLBACK_EVENT_WAKEUP_SUCCESS.equals(name)) {
                WakeUpVo wakeUpVo = new Gson().fromJson(params, WakeUpVo.class);
                if (wakeUpVo == null) {
                    Log.d(TAG, "WAKEUP_SUCCESS wakeUpVo  is null !");
                    return;
                }
                if (WakeUpVo.hasError(wakeUpVo, name)) {
                    mWakeUpListener.wakeUpError();

                } else {
                    mWakeUpListener.wakeUpSuccess(wakeUpVo.getWord());
                }

            } else if (SpeechConstant.CALLBACK_EVENT_WAKEUP_ERROR.equals(name)) {
                mWakeUpListener.wakeUpError();

            } else if (SpeechConstant.CALLBACK_EVENT_WAKEUP_STOPED.equals(name)) {
                mWakeUpListener.wakeUpStop();

            } else if (SpeechConstant.CALLBACK_EVENT_WAKEUP_AUDIO.equals(name)) {
                mWakeUpListener.wakeAudio();
//                listener.onASrAudio(data, offset, length);
            }
        }
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
