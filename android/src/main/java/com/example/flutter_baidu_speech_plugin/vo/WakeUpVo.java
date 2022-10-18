package com.example.flutter_baidu_speech_plugin.vo;


import com.baidu.speech.asr.SpeechConstant;

import java.io.Serializable;

public class WakeUpVo implements Serializable {
    private static int ERROR_NONE = 0;


    private String word;
    private int error = -1;
    private String desc;
    private int errorCode = -1;
    private String errorDesc;

    public String getWord() {
        return word;
    }

    public void setWord(String word) {
        this.word = word;
    }

    public int getError() {
        return error;
    }

    public void setError(int error) {
        this.error = error;
    }

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }

    public int getErrorCode() {
        return errorCode;
    }

    public void setErrorCode(int errorCode) {
        this.errorCode = errorCode;
    }

    public String getErrorDesc() {
        return errorDesc;
    }

    public void setErrorDesc(String errorDesc) {
        this.errorDesc = errorDesc;
    }


    public static boolean hasError(WakeUpVo wakeUpVo, String name) {
        if (SpeechConstant.CALLBACK_EVENT_WAKEUP_SUCCESS.equals(name)) {
            return wakeUpVo.getErrorCode() != ERROR_NONE;
        }
        return wakeUpVo.getError() != ERROR_NONE;
    }
}
