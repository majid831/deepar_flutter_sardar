package com.example.flutter_deepar.deepar_plugin;

import android.graphics.Bitmap;
import android.media.Image;

import com.example.flutter_deepar.deepar_plugin.model.MultiFaceData;
import com.example.flutter_deepar.deepar_plugin.model.PlatformMessage;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.util.Arrays;
import java.util.Date;
import java.util.UUID;

import ai.deepar.ar.ARErrorType;
import ai.deepar.ar.AREventListener;
import ai.deepar.ar.DeepAR;
import timber.log.Timber;


public class DeeparAREventListener implements AREventListener, DeepAR.FaceTrackedCallback {

    final DeepAR deepAR;
    final DeeparMethodExecutor methodExecutor;
    final boolean willSendFaceTrackData = false;

    private int numberOfFacesTracked = -1;
    private Gson gson = new GsonBuilder().serializeSpecialFloatingPointValues().create();
    private String videoRecordPath;

    public DeeparAREventListener(DeepAR deepAR,DeeparMethodExecutor methodExecutor) {
        this.deepAR = deepAR;
        this.methodExecutor = methodExecutor;

    }

    public void dispose(){

    }

    public void startVideoRecording(){
        videoRecordPath = AssetProvider.getAssetCachePath(AssetProvider.getInstance().context,"video_"+new Date().getTime()+".mp4");
        deepAR.startVideoRecording(videoRecordPath);
    }

    @Override
    public void screenshotTaken(Bitmap bitmap) {
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 60, bos);
        byte[] bitmapdata = bos.toByteArray();
        ByteArrayInputStream bs = new ByteArrayInputStream(bitmapdata);
        String filePath = AssetProvider.getInstance().getInputSavePath("screenshot_"+UUID.randomUUID().toString().replace("-","") +".jpg",bs);
        methodExecutor.sendMessageToFlutter(new PlatformMessage("screenshot",filePath,"Screenshot taken"));
    }

    @Override
    public void videoRecordingStarted() {
        methodExecutor.sendMessageToFlutter(new PlatformMessage("did_start_video_recording","","Video Record Started"));
    }

    @Override
    public void videoRecordingFinished() {
        methodExecutor.sendMessageToFlutter(new PlatformMessage("did_finish_video_recording",videoRecordPath,"Video Record Started"));
    }

    @Override
    public void videoRecordingFailed() {
        PlatformMessage message = new PlatformMessage("error_video_recording","","Error Video Record");
        message.setIsSuccess(false);
        methodExecutor.sendMessageToFlutter(message);
    }

    @Override
    public void videoRecordingPrepared() {
        methodExecutor.sendMessageToFlutter(new PlatformMessage("finish_prepare_video_recording","","Video Record Prepared"));
    }

    @Override
    public void shutdownFinished() {
        methodExecutor.sendMessageToFlutter(new PlatformMessage("did_finish_shutdown","","Did Finish ShutDown DeepAr"));
    }

    @Override
    public void initialized() {
        methodExecutor.sendMessageToFlutter(new PlatformMessage("did_initialize","","DÄ±d Initialize DeepAr"));
    }

    @Override
    public void faceVisibilityChanged(boolean faceVisible) {
        methodExecutor.sendMessageToFlutter(new PlatformMessage("face_visible",faceVisible ? 1 : 0,"Face Visibility Changed"));
    }

    @Override
    public void imageVisibilityChanged(String gameObjectName, boolean isVisible) {
        PlatformMessage message = new PlatformMessage("image_visibility_changed",gameObjectName,"Image Visibility Changed");
        message.setNumValue(isVisible ? 1 : 0);
        methodExecutor.sendMessageToFlutter(message);
    }

    @Override
    public void frameAvailable(Image image) {

    }

    @Override
    public void error(ARErrorType arErrorType, String s) {
        Timber.i("Deepar Error Type: %s\nContent:%s",arErrorType,s);
    }

    @Override
    public void effectSwitched(String slot) {
       methodExecutor.sendMessageToFlutter(new PlatformMessage("did_switch_effect",slot,"Did Switch Effect"));
    }

    @Override
    public void faceTracked(DeepAR.FaceData[] faceData) {
        if (this.willSendFaceTrackData){
            MultiFaceData multiFaceData = new MultiFaceData(Arrays.asList(faceData));
            PlatformMessage message = new PlatformMessage("face_tracked",gson.toJson(multiFaceData),"Face Tracked");
            methodExecutor.sendMessageToFlutter(message);
        }
        int numberOfFaces = 0;
        for (DeepAR.FaceData data:faceData){
            numberOfFaces += data.faceDetected ? 1 : 0;
        }
        if (numberOfFaces != this.numberOfFacesTracked){
            this.numberOfFacesTracked = numberOfFaces;
            PlatformMessage message = new PlatformMessage("number_of_visible_faces_changed",numberOfFaces,"Number of faces changed");
            methodExecutor.sendMessageToFlutter(message);
        }
    }
}
