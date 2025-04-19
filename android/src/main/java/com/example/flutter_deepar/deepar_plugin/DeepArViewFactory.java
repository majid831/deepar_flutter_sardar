package com.example.flutter_deepar.deepar_plugin;

import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class DeepArViewFactory extends  PlatformViewFactory{

    private final BinaryMessenger messenger;

    public DeepArViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @NonNull
    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        return new DeepArView(context,messenger,viewId,args);
    }
}
