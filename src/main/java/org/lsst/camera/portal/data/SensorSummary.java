/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.lsst.camera.portal.data;
//import java.util.Date;
//import org.lsst.camera.portal.data.NcrData;
//import java.util.List;
/**
 *
 * @author heather
 */
public class SensorSummary {
    
    private String lsstId;
    private Integer maxReadNoiseChannel;
    private Double maxReadNoise;
    private Double percentDefects;
    private Integer numTestsPassed;
    
   
    public void SensorSummary() {
        lsstId = "";
        maxReadNoiseChannel = 0;
        maxReadNoise = 0.0d;
        percentDefects = 0.0d;
        numTestsPassed = 0;
    }
    
    public void setLsstId(String id) {
        lsstId = id == null || "".equals(id) ? "NA" : id; 
    }
  

    public void setMaxReadNoiseChannel(Integer r) {
        maxReadNoiseChannel = r;
    }
    
    public void setMaxReadNoise(Double val) {
        maxReadNoise = val;
    }
    
    public void setPercentDefects(Double p) {
        percentDefects = p;
    }
    
    public void setNumTestsPassed(Integer num) {
        numTestsPassed = num;
    }
  
    
    public void setValues(String id, Integer readNoiseChannel, Double readNoise, Double defects,
            Integer numTests) {
        lsstId = id == null || "".equals(id) ? "NA" : id; 
        maxReadNoiseChannel = readNoiseChannel;
        maxReadNoise = readNoise;
        percentDefects = defects;
        numTestsPassed = numTests;
    }
    
  
    public String getLsstId() {
        return lsstId;
    }
 
    public Integer getMaxReadNoiseChannel() {
        return maxReadNoiseChannel;
    }
    
    public Double getMaxReadNoise() {
         return maxReadNoise;
    }
    
    public Double getPercentDefects() {
        return percentDefects;
    }
    
    public Integer getNumTestsPassed() {
        return numTestsPassed;
    }
    
}