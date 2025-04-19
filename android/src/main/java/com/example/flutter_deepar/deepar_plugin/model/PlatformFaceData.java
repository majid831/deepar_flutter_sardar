package com.example.flutter_deepar.deepar_plugin.model;

import ai.deepar.ar.DeepAR;

public class PlatformFaceData {

    int faceNumber;
    public boolean faceDetected = false;
    public float[] translation = new float[3];
    public float[] rotation = new float[3];
    public float[] poseMatrix = new float[16];
    public float[] landmarks = new float[204];
    public float[] landmarks2d = new float[136];
    public float[] faceRect = new float[4];

    public PlatformFaceData(int faceNumber, DeepAR.FaceData faceData){
        this.faceNumber = faceNumber;
        this.faceDetected = faceData.faceDetected;
        this.rotation = faceData.rotation;
        this.translation = faceData.translation;
        this.poseMatrix = faceData.poseMatrix;
        this.landmarks = faceData.landmarks;
        this.landmarks2d = faceData.landmarks2d;
        this.faceRect = faceData.faceRect;
    }

}
