package com.example.flutter_baidu_speech_plugin;


public interface WakeUpListener {

    default void wakeUpStop() {
    }

    default void wakeUpSuccess(String result) {
    }

    default void wakeUpError() {
    }

    default void wakeAudio() {
    }

}
