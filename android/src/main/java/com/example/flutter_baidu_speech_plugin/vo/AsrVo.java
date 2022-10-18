package com.example.flutter_baidu_speech_plugin.vo;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.List;

public class AsrVo implements Serializable {
    private static final int ERROR_NONE = 0;

    private int error = -1;
    @SerializedName("sub_error")
    private int subError = -1;
    private String desc;
    @SerializedName("result_type")
    private String resultType;

    @SerializedName("origin_result")
    private Object originResult;

    @SerializedName("results_recognition")
    private List<String> resultsRecognition;


    public int getError() {
        return error;
    }

    public void setError(int error) {
        this.error = error;
    }

    public int getSubError() {
        return subError;
    }

    public void setSubError(int subError) {
        this.subError = subError;
    }

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }

    public String getResultType() {
        return resultType;
    }

    public void setResultType(String resultType) {
        this.resultType = resultType;
    }

    public Object getOriginResult() {
        return originResult;
    }

    public void setOriginResult(Object originResult) {
        this.originResult = originResult;
    }

    public List<String> getResultsRecognition() {
        return resultsRecognition;
    }

    public void setResultsRecognition(List<String> resultsRecognition) {
        this.resultsRecognition = resultsRecognition;
    }


    public static boolean hasError(AsrVo recognizerVo) {
        return ERROR_NONE != recognizerVo.getError();
    }

    // 最终识别结果 长语音每一句话会回调一次
    public static boolean isFinalResult(AsrVo asrVo) {
        return "final_result".equals(asrVo.getResultType());
    }

    // 临时识别结果
    public static boolean isPartialResult(AsrVo asrVo) {
        return "partial_result".equals(asrVo.getResultType());
    }

    // 语义理解结果
    public static boolean isNluResult(AsrVo asrVo) {
        return "nlu_result".equals(asrVo.getResultType());
    }
}
