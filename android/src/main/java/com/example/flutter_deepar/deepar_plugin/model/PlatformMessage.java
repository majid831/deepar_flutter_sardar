package com.example.flutter_deepar.deepar_plugin.model;

//
//	PlatformMessage.java
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import com.google.gson.annotations.SerializedName;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;


public class PlatformMessage{

    @SerializedName("action")
    private String action;
    @SerializedName("description")
    private String description;
    @SerializedName("isSuccess")
    private boolean isSuccess;
    @SerializedName("numValue")
    private int numValue;
    @SerializedName("strValue")
    private String strValue;

    public void setAction(String action){
        this.action = action;
    }
    public String getAction(){
        return this.action;
    }
    public void setDescription(String description){
        this.description = description;
    }
    public String getDescription(){
        return this.description;
    }
    public void setIsSuccess(boolean isSuccess){
        this.isSuccess = isSuccess;
    }
    public boolean isIsSuccess()
    {
        return this.isSuccess;
    }
    public void setNumValue(int numValue){
        this.numValue = numValue;
    }
    public int getNumValue(){
        return this.numValue;
    }
    public void setStrValue(String strValue){
        this.strValue = strValue;
    }
    public String getStrValue(){
        return this.strValue;
    }

    public PlatformMessage(String action, String strValue,String description) {
        this.action = action;
        this.strValue = strValue;
        this.description = description;
        this.isSuccess = true;
    }

    public PlatformMessage(String action, int numValue,String description) {
        this.action = action;
        this.description = description;
        this.numValue = numValue;
        this.isSuccess = true;
    }

    /**
     * Instantiate the instance using the passed jsonObject to set the properties values
     */
    public PlatformMessage(JSONObject jsonObject){
        if(jsonObject == null){
            return;
        }
        action = jsonObject.optString("action");
        description = jsonObject.optString("description");
        isSuccess = jsonObject.optBoolean("isSuccess");
        numValue = jsonObject.optInt("numValue");
        strValue = jsonObject.optString("strValue");
    }

    /**
     * Returns all the available property values in the form of JSONObject instance where the key is the approperiate json key and the value is the value of the corresponding field
     */
    public JSONObject toJsonObject()
    {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("action", action);
            jsonObject.put("description", description);
            jsonObject.put("isSuccess", isSuccess);
            jsonObject.put("numValue", numValue);
            jsonObject.put("strValue", strValue);
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return jsonObject;
    }

    public HashMap<String,Object> toMap(){
        HashMap<String,Object> jsonObject = new HashMap<>();
        jsonObject.put("action", action);
        jsonObject.put("description", description);
        jsonObject.put("isSuccess", isSuccess);
        jsonObject.put("numValue", numValue);
        jsonObject.put("strValue", strValue);
        return jsonObject;
    }
}