package com.example.flutter_deepar.deepar_plugin;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.graphics.Insets;
import android.os.Build;
import android.util.DisplayMetrics;
import android.util.Size;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.WindowInsets;
import android.view.WindowMetrics;

import androidx.annotation.NonNull;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageProxy;
import androidx.camera.core.Preview;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.LifecycleOwner;

import com.google.common.util.concurrent.ListenableFuture;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.HashMap;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executor;

import ai.deepar.ar.CameraResolutionPreset;
import ai.deepar.ar.DeepAR;
import ai.deepar.ar.DeepARImageFormat;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformView;
import timber.log.Timber;

public class DeepArView implements PlatformView, SurfaceHolder.Callback, DeeparMethodExecutor.ICameraController {

    DeepAR deepAR;
    SurfaceView arView;
    Context context;
    String licenseKey;
    boolean isFrontCamera = true;
    boolean willSendFaceTrackData = false;
    private DeeparMethodExecutor methodExecutor;
    private DeeparAREventListener arEventListener;

    private final int defaultLensFacing = CameraSelector.LENS_FACING_FRONT;
    private int lensFacing = defaultLensFacing;
    private ListenableFuture<ProcessCameraProvider> cameraProviderFuture;
    private ByteBuffer[] buffers;
    private int currentBuffer = 0;
    private static final int NUMBER_OF_BUFFERS=2;
    private ProcessCameraProvider processCameraProvider;
    private ARSurfaceProvider surfaceProvider = null;
    CameraResolutionPreset cameraResolutionPreset = CameraResolutionPreset.P1920x1080;
    private boolean useExternalCameraTexture = false;

    DeepArView(Context context, BinaryMessenger messenger, int id,Object args){
        this.context = context;
        if (args instanceof HashMap){
            licenseKey = ((HashMap) args).get("license").toString();
            isFrontCamera = ((HashMap) args).get("initial_camera_position").toString().equals("DeepARCameraPosition.front");
            String willSendFaceTrackData= ((HashMap)args).get("will_send_face_track_data").toString();
            if ("true".equals(willSendFaceTrackData)){
                this.willSendFaceTrackData = true;
            }
            if(((HashMap)args).containsKey("camera_resolution_preset")){
                setCameraResolutionPreset(((HashMap)args).get("camera_resolution_preset").toString());
            }
            String willUseExternalCameraTextureArg = ((HashMap)args).get("will_use_external_camera_texture").toString();
            if ("true".equals(willUseExternalCameraTextureArg)){
                this.useExternalCameraTexture = true;
            }
        }
        deepAR = new DeepAR(this.context);
        deepAR.setLicenseKey(licenseKey);
        methodExecutor = new DeeparMethodExecutor(context,messenger,deepAR,this);
        this.arEventListener = new DeeparAREventListener(deepAR,methodExecutor);
        deepAR.initialize(context,this.arEventListener);
        if(willSendFaceTrackData){
            deepAR.setFaceTrackedCallback(this.arEventListener);
        }
        setupCamera();
        arView = new SurfaceView(context);
        arView.setVisibility(View.GONE);
        arView.setVisibility(View.VISIBLE);
        arView.getHolder().addCallback(this);
    }

    void setCameraResolutionPreset(String preset){
        switch (preset){
            case "RESOLUTION_PRESET_10920x1080":
                cameraResolutionPreset = CameraResolutionPreset.P1920x1080;
                break;
            case "RESOLUTION_PRESET_1280x720":
                cameraResolutionPreset = CameraResolutionPreset.P1280x720;
                break;
            case "RESOLUTION_PRESET_640x480":
                cameraResolutionPreset = CameraResolutionPreset.P640x480;
                break;
            case "RESOLUTION_PRESET_DEVICE":
                cameraResolutionPreset = null;
        }
    }

    /* Platform View Methods Begin */
    @Override
    public View getView() {
        return arView;
    }

    @Override
    public void dispose() {



        if(surfaceProvider != null) {
            surfaceProvider.stop();
            surfaceProvider = null;
        }
        arView.setVisibility(View.GONE);
        deepAR.setAREventListener(null);
        deepAR.setRenderSurface(null,0,0);
        deepAR.setFaceTrackedCallback(null);
        deepAR.release();
        deepAR = null;
        arView = null;
        arEventListener.dispose();
        arEventListener = null;
        methodExecutor.dispose();
        this.context = null;
        if(processCameraProvider != null) {
            processCameraProvider.unbindAll();
            processCameraProvider = null;
        }

        imageAnalyzer = null;
        cameraProviderFuture = null;
        methodExecutor = null;
        buffers = null;
    }
    /* Platform View Methods END */

    /* CameraX Methods Begin */
    private void setupCamera() {
        Executor executor;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
            executor = AssetProvider.getInstance().context.getMainExecutor();
        }else{
            executor = ContextCompat.getMainExecutor(AssetProvider.getInstance().context);
        }
        cameraProviderFuture = ProcessCameraProvider.getInstance(context);
        cameraProviderFuture.addListener(new Runnable() {
            @Override
            public void run() {
                try {
                    ProcessCameraProvider cameraProvider = cameraProviderFuture.get();
                    processCameraProvider = cameraProvider;
                    bindImageAnalysis(cameraProvider);
                } catch (ExecutionException | InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }, executor);
    }

    public int getScreenWidth(@NonNull Activity activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            WindowMetrics windowMetrics = activity.getWindowManager().getCurrentWindowMetrics();
            Insets insets = windowMetrics.getWindowInsets()
                    .getInsetsIgnoringVisibility(WindowInsets.Type.systemBars());
            return windowMetrics.getBounds().width() - insets.left - insets.right;
        } else {
            DisplayMetrics displayMetrics = new DisplayMetrics();
            activity.getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
            return displayMetrics.widthPixels;
        }
    }

    public int getScreenHeight(@NonNull Activity activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            WindowMetrics windowMetrics = activity.getWindowManager().getCurrentWindowMetrics();
            Insets insets = windowMetrics.getWindowInsets()
                    .getInsetsIgnoringVisibility(WindowInsets.Type.systemBars());
            return windowMetrics.getBounds().height() - insets.top - insets.bottom;
        } else {
            DisplayMetrics displayMetrics = new DisplayMetrics();
            activity.getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
            return displayMetrics.heightPixels;
        }
    }

    private void bindImageAnalysis(ProcessCameraProvider cameraProvider) {
        int width;
        int height;
        boolean shouldSwapWidthAndHeightOnPortrait = false;
        if(cameraResolutionPreset == null){
            width = getScreenWidth(AssetProvider.getInstance().getContext());
            height = getScreenHeight(AssetProvider.getInstance().getContext());
        }else{
            shouldSwapWidthAndHeightOnPortrait = true;
            width = cameraResolutionPreset.getWidth();
            height = cameraResolutionPreset.getHeight();
        }
        int orientation = getScreenOrientation();
        if (orientation == ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE || orientation == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE){
            //Nothing needs to be done.
        } else {
            if(shouldSwapWidthAndHeightOnPortrait){
                int tempWidth = width;
                width = height;
                height = tempWidth;
            }
        }

        Size cameraResolution = new Size(width, height);
        CameraSelector cameraSelector = new CameraSelector.Builder().requireLensFacing(lensFacing).build();

        if(useExternalCameraTexture) {
            Preview preview = new Preview.Builder()
                    .setTargetResolution(cameraResolution)
                    .build();

            cameraProvider.unbindAll();
            cameraProvider.bindToLifecycle((LifecycleOwner)AssetProvider.getInstance().context, cameraSelector, preview);
            if(surfaceProvider == null) {
                surfaceProvider = new ARSurfaceProvider(AssetProvider.getInstance().context, deepAR);
            }
            preview.setSurfaceProvider(surfaceProvider);
            surfaceProvider.setMirror(lensFacing == CameraSelector.LENS_FACING_FRONT);
        }else{
            buffers = new ByteBuffer[NUMBER_OF_BUFFERS];
            for (int i = 0; i < NUMBER_OF_BUFFERS; i++) {
                buffers[i] = ByteBuffer.allocateDirect(width * height * 3);
                buffers[i].order(ByteOrder.nativeOrder());
                buffers[i].position(0);
            }

            ImageAnalysis imageAnalysis = new ImageAnalysis.Builder().setTargetResolution(new Size(width, height)).setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST).build();
            Executor executor;
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
                executor = AssetProvider.getInstance().context.getMainExecutor();
            }else{
                executor = ContextCompat.getMainExecutor(AssetProvider.getInstance().context);
            }
            imageAnalysis.setAnalyzer(executor, getImageAnalyzer());
//            CameraSelector cameraSelector = new CameraSelector.Builder().requireLensFacing(lensFacing).build();
            cameraProvider.unbindAll();
            cameraProvider.bindToLifecycle((LifecycleOwner)AssetProvider.getInstance().context, cameraSelector, imageAnalysis);
        }
    }

    private ImageAnalysis.Analyzer imageAnalyzer;
    private ImageAnalysis.Analyzer getImageAnalyzer(){
        if(imageAnalyzer == null){
            imageAnalyzer = new ImageAnalysis.Analyzer() {
                @Override
                public void analyze(@NonNull ImageProxy image) {
                    byte[] byteData;
                    ByteBuffer yBuffer = image.getPlanes()[0].getBuffer();
                    ByteBuffer uBuffer = image.getPlanes()[1].getBuffer();
                    ByteBuffer vBuffer = image.getPlanes()[2].getBuffer();

                    int ySize = yBuffer.remaining();
                    int uSize = uBuffer.remaining();
                    int vSize = vBuffer.remaining();

                    byteData = new byte[ySize + uSize + vSize];

                    //U and V are swapped
                    yBuffer.get(byteData, 0, ySize);
                    vBuffer.get(byteData, ySize, vSize);
                    uBuffer.get(byteData, ySize + vSize, uSize);

                    buffers[currentBuffer].put(byteData);
                    buffers[currentBuffer].position(0);
                    if (deepAR != null) {
                        deepAR.receiveFrame(buffers[currentBuffer],
                                image.getWidth(), image.getHeight(),
                                image.getImageInfo().getRotationDegrees(),
                                lensFacing == CameraSelector.LENS_FACING_FRONT,
                                DeepARImageFormat.YUV_420_888,
                                image.getPlanes()[1].getPixelStride()
                        );
                    }
                    currentBuffer = (currentBuffer + 1) % NUMBER_OF_BUFFERS;
                    image.close();
                }
            };
        }
        return imageAnalyzer;
    }



    private int getScreenOrientation() {
        int rotation = AssetProvider.getInstance().getContext().getWindowManager().getDefaultDisplay().getRotation();
        DisplayMetrics dm = new DisplayMetrics();
        AssetProvider.getInstance().getContext().getWindowManager().getDefaultDisplay().getMetrics(dm);
        int width = dm.widthPixels;
        int height = dm.heightPixels;
        int orientation;
        // if the device's natural orientation is portrait:
        if ((rotation == Surface.ROTATION_0
                || rotation == Surface.ROTATION_180) && height > width ||
                (rotation == Surface.ROTATION_90
                        || rotation == Surface.ROTATION_270) && width > height) {
            switch(rotation) {
                case Surface.ROTATION_0:
                    orientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;
                    break;
                case Surface.ROTATION_90:
                    orientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
                    break;
                case Surface.ROTATION_180:
                    orientation =
                            ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT;
                    break;
                case Surface.ROTATION_270:
                    orientation =
                            ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE;
                    break;
                default:
                    orientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;
                    break;
            }
        }
        // if the device's natural orientation is landscape or if the device
        // is square:
        else {
            switch(rotation) {
                case Surface.ROTATION_0:
                    orientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
                    break;
                case Surface.ROTATION_90:
                    orientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;
                    break;
                case Surface.ROTATION_180:
                    orientation =
                            ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE;
                    break;
                case Surface.ROTATION_270:
                    orientation =
                            ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT;
                    break;
                default:
                    orientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
                    break;
            }
        }

        return orientation;
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {

    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
        // If we are using on screen rendering we have to set surface view where DeepAR will render
        Timber.i(">>>>>> Surface Changed");
        deepAR.setRenderSurface(holder.getSurface(), width, height);
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        Timber.i(">>>>>> Surface Destroyed");
        if (deepAR != null) {
            deepAR.setRenderSurface(null, 0, 0);
            Timber.i(">>>>>> Surface Destroyed -> DEEPAR RELEASE");
        }
    }

    @Override
    public void flipCamera() {
        lensFacing = lensFacing == CameraSelector.LENS_FACING_FRONT ? CameraSelector.LENS_FACING_BACK : CameraSelector.LENS_FACING_FRONT;
        ProcessCameraProvider cameraProvider;
        try {
            cameraProvider = cameraProviderFuture.get();
            cameraProvider.unbindAll();
        } catch (ExecutionException | InterruptedException e) {
            e.printStackTrace();
        }
        setupCamera();
    }

    @Override
    public void startVideoRecording() {
        arEventListener.startVideoRecording();

    }

    /* CameraX Methods END */
}
