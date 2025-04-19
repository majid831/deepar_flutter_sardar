package com.example.flutter_deepar.deepar_plugin;

import android.content.Context;

import androidx.annotation.NonNull;

import com.example.flutter_deepar.deepar_plugin.model.PlatformMessage;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.util.HashMap;
import java.util.Map;

import ai.deepar.ar.DeepAR;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import timber.log.Timber;

public class DeeparMethodExecutor implements MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    DeepAR deepAR;
    Context context;
    MethodChannel methodChannel;
    EventChannel eventChannel;
    EventChannel.EventSink eventSink;
    ICameraController ICameraController;

    public DeeparMethodExecutor(Context context, BinaryMessenger messenger, DeepAR deepAR, ICameraController ICameraController) {
        this.deepAR = deepAR;
        this.context = context;
        this.methodChannel = new MethodChannel(messenger, "flutter_deepar");
        this.methodChannel.setMethodCallHandler(this);
        this.eventChannel = new EventChannel(messenger, "event_chanel_deepar");;
        this.eventChannel.setStreamHandler(this);
        this.ICameraController = ICameraController;
    }

    public void dispose(){
        Timber.i("Releasing method executor");
        this.deepAR = null;
        this.ICameraController = null;
        this.methodChannel.setMethodCallHandler(null);
        this.methodChannel = null;
        this.context = null;
        this.eventSink = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Timber.i("Method Call: %s args: %s",call.method,call.arguments);
        switch (call.method){
            case "flip_camera":
                ICameraController.flipCamera();
                break;
            case "take_screenshot":
                deepAR.takeScreenshot();;
                break;
            case "switch_effect_absolute_path":
            case "switch_effect_asset":
                if (call.arguments instanceof Map){
                    Map map = ((Map) call.arguments);
                    if (map.containsKey("path") && map.containsKey("slot") && map.containsKey("face_id")){
                        String path = map.get("path").toString();
                        String slot = map.get("slot").toString();
                        int faceId = Integer.parseInt(String.valueOf(map.get("face_id")));
                        switchEffect(path,slot,faceId,call.method.equals("switch_effect_absolute_path"));
                    }
                }
                break;
            case "start_video_recording":
                ICameraController.startVideoRecording();
                break;
            case "finish_video_recording":
                deepAR.stopVideoRecording();
                break;
            case "pause_video_recording":
                deepAR.pauseVideoRecording();
                break;
            case "resume_video_recording":
                deepAR.resumeVideoRecording();
                break;
            case "clear_effect":
                if (call.arguments instanceof Map){
                    Map map = ((Map) call.arguments);
                    if (map.containsKey("slot") && map.containsKey("face_id")){
                        String slot = map.get("slot").toString();
                        int faceId = Integer.parseInt(String.valueOf(map.get("face_id")));
                        switchEffect(null,slot,faceId,true);
                    }
                }
                break;
            case "pause_camera":
                deepAR.setPaused(true);
                return;
            case "resume_camera":
                deepAR.setPaused(false);
                break;
            case "orientation_changed":
                break;
            case "on_stop_app":
                break;
            case "on_resume_app":

                break;
        }
    }

    public void sendMessageToFlutter(PlatformMessage message){
        final HashMap<String,Object> msg = message.toMap();
        AssetProvider.getInstance().getContext().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (eventSink != null){
                    eventSink.success(msg);
                }
            }
        });
    }

    private void switchEffect(String path, String slot, int faceId,boolean isAbsolutePath){
        String slotName = slot+"_f"+faceId;
        if (path == null){
            Timber.i("Removing Effect from Slot: %s",slotName);
            deepAR.switchEffect(slotName,"none",faceId);
        }else{
            String effectPath = isAbsolutePath ? path : AssetProvider.getInstance().getAssetEffectCachePath(path);
            deepAR.switchEffect(slotName,effectPath,faceId);
        }
        sendMessageToFlutter(new PlatformMessage("did_switch_effect",slot,"Did Switch Effect"));
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.eventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        this.eventSink = null;
    }

    public interface ICameraController {
        void flipCamera();
        void startVideoRecording();
    }
}
