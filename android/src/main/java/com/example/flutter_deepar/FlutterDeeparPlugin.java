package com.example.flutter_deepar;

import android.app.Activity;

import com.example.flutter_deepar.deepar_plugin.AssetProvider;
import com.example.flutter_deepar.deepar_plugin.DeepArViewFactory;

import org.jetbrains.annotations.NotNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import timber.log.Timber;

/** FlutterDeeparPlugin */
public class FlutterDeeparPlugin implements FlutterPlugin, ActivityAware {

  static  boolean didRegisterView = false;
  Activity activity;

  @Override
  public void onAttachedToEngine(@NotNull FlutterPluginBinding flutterPluginBinding) {
    Timber.plant(new Timber.DebugTree());
    Timber.i("Adding Deepar View attached");
    if (!didRegisterView){
      didRegisterView = true;
      AssetProvider.getInstance().setFlutterAssets(flutterPluginBinding.getFlutterAssets());
      flutterPluginBinding.getPlatformViewRegistry()
              .registerViewFactory("plugin_deep_ar_view",new DeepArViewFactory(flutterPluginBinding.getBinaryMessenger()));
    }

  }


  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    Timber.i("Attached to activity");
      this.activity = binding.getActivity();
      AssetProvider.getInstance().setContext(this.activity);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    Timber.i("Detached from activity");
      this.activity = null;
      AssetProvider.getInstance().setContext(null);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NotNull ActivityPluginBinding binding) {
      Timber.i("Config Changed");
  }

  @Override
  public void onDetachedFromActivity() {

  }

  @Override
  public void onDetachedFromEngine(@NotNull FlutterPluginBinding binding) {

  }

}
