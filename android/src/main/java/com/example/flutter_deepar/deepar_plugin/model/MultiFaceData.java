package com.example.flutter_deepar.deepar_plugin.model;

import com.google.gson.annotations.SerializedName;

import java.util.ArrayList;
import java.util.List;

import ai.deepar.ar.DeepAR;

public class MultiFaceData {

    @SerializedName("PluginFaceData")
    List<PlatformFaceData> pluginFaceData;

    public MultiFaceData(List<DeepAR.FaceData> data) {
        this.pluginFaceData = new ArrayList<>();
        for (int i = 0;i<data.size();i++){
            this.pluginFaceData.add(new PlatformFaceData(i,data.get(i)));
        }
    }

}
