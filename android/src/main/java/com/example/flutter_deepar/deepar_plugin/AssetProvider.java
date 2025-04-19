package com.example.flutter_deepar.deepar_plugin;

import android.app.Activity;
import android.content.Context;
import android.os.Environment;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Timer;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.PluginRegistry;
import timber.log.Timber;

public class AssetProvider {
    private  static AssetProvider instance = new AssetProvider();

    FlutterPlugin.FlutterAssets flutterAssets;
    PluginRegistry.Registrar registrar;
    Activity context;

    public Activity getContext() {
        return context;
    }

    public void setContext(Activity context) {
        this.context = context;
    }

    public void setFlutterAssets(FlutterPlugin.FlutterAssets flutterAssets) {
        this.flutterAssets = flutterAssets;
    }

    public void setRegistrar(PluginRegistry.Registrar registrar) {
        this.registrar = registrar;
    }

    private AssetProvider(){}

    public static AssetProvider getInstance(){
        return instance;
    }


    public String getAssetEffectCachePath(String assetPath){
        String[] fileNameComponents = assetPath.split("/");
        String realFileName = "temp_effect";
        boolean didFindFileComponent = false;
        if (fileNameComponents.length > 0){
            realFileName = fileNameComponents[fileNameComponents.length-1];
            didFindFileComponent = true;
        }else{
            Timber.e("Didn't file file component, using temp file name");
        }
        String cachePath = getAssetCachePath(context,realFileName);
        Timber.i("CachePath = %s",cachePath);
        File file = new File(cachePath);
        boolean isSuccess = true;
//        if(file.exists()){
//            Timber.i(">>>> TEST Deleting cached file");
//            file.delete();
//        }
        if (!file.exists() || !didFindFileComponent){
            Timber.i("Copying File");
            isSuccess = saveInputStreamToFile(file,getInputStream(assetPath));
        }else{
            Timber.i("Effect file already exists in temp folder");
        }

        checkAssetSubFoldersAndCopyIfNeeded(context,assetPath);

        if (!isSuccess){
            Timber.e("File create error");
        }
        return cachePath;
    }

    public String getInputSavePath(String fileName, InputStream inputStream){
        String path = getAssetCachePath(context,fileName);
        File file = new File(path);
        if (file.exists()){
            if(!file.delete()){
                Timber.e("Error deleting file: %s",path);
            }
        }
        boolean isSaveSuccess = saveInputStreamToFile(file,inputStream);
        if (!isSaveSuccess){
            Timber.e("Error saving file to path");
        }
        return path;
    }

    private boolean saveInputStreamToFile(File file, InputStream inputStream){
        boolean isSuccess = false;
        try{
            OutputStream outputStream = null;

            try {
                byte[] fileReader = new byte[4096];
                outputStream = new FileOutputStream(file);

                while (true) {
                    int read = inputStream.read(fileReader);

                    if (read == -1) {
                        break;
                    }
                    outputStream.write(fileReader, 0, read);
                }
                outputStream.flush();

                isSuccess =  true;
            } catch (IOException e) {
                e.printStackTrace();
                Timber.e(e,"Error writing file");
                isSuccess = false;
            } finally {
                if (inputStream != null) {
                    inputStream.close();
                }

                if (outputStream != null) {
                    outputStream.close();
                }
            }
        }catch (IOException e){
            e.printStackTrace();
            Timber.e(e,"Error closing streams");
            isSuccess = false;
        }
        return isSuccess;
    }


    public InputStream getInputStream(String assetPath){
        String path = "";
        if (flutterAssets != null){

            path = flutterAssets.getAssetFilePathBySubpath(assetPath);
        }else{
            path = registrar.lookupKeyForAsset(assetPath);
        }
        try {
            return  context.getAssets().open(path);
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    public static String getAssetCachePath(Context context,String filename){
        String filePath = context.getExternalFilesDir(null) + File.separator +"temp"+File.separator+ filename;
        String folderPath = context.getExternalFilesDir(null) + File.separator +"temp";

        if (!isExternalStorageWritable()){
            filePath = context.getFilesDir() + File.separator +"temp"+File.separator+ filename;
            folderPath = context.getFilesDir() + File.separator +"temp";
        }

        File folder = new File(folderPath);
        if (!folder.exists()) {
            folder.mkdirs();
        }
        Timber.i("File Path: %s",filePath);
        return filePath;
    }

    private void checkAssetSubFoldersAndCopyIfNeeded(Context context, String assetPath){
        String[] components = assetPath.split("/");
        String realEffectName = "";
        if (components.length > 0){
            realEffectName = components[components.length-1];
        }
        assetPath = assetPath+"_assets";
        String path;
        if (flutterAssets != null){
            path = flutterAssets.getAssetFilePathBySubpath(assetPath);
        }else{
            path = registrar.lookupKeyForAsset(assetPath);
        }
        try {
            String[] contents = context.getAssets().list(path);
            if (contents != null && contents.length > 0){
                String folderPath = context.getExternalFilesDir(null) + File.separator +"temp" + File.separator+realEffectName+"_assets";
                if (!isExternalStorageWritable()){
                    folderPath = context.getFilesDir() + File.separator +"temp"+ File.pathSeparator+assetPath+"_assets";
                }
                File tempFolder = new File(folderPath);
                if (!tempFolder.exists()){
                    boolean didCreate = tempFolder.mkdir();
                    Timber.i("Created Asset Folder: %s - status: %s",folderPath,didCreate);
                }
                for (String asset:contents){
                    String assetCachePath = getAssetCachePath(context,realEffectName+"_assets/"+asset);
                    File file = new File(assetCachePath);
                    if (file.exists()){
                        boolean delete = file.delete();
                        Timber.i("File Deleted: %s",delete);
                    }
                    boolean didSave = saveInputStreamToFile(file,getInputStream(assetPath+"/"+asset));
                    Timber.i("Did Save Sub Asset: %s",didSave);
                }
            }

        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    /* Checks if external storage is available for read and write */
    public static boolean isExternalStorageWritable() {
        String state = Environment.getExternalStorageState();
        if (Environment.MEDIA_MOUNTED.equals(state)) {
            return true;
        }
        return false;
    }
}
