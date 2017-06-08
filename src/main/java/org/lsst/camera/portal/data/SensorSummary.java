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
    private String percentDefects;
    private Integer numTestsPassed;
    private Integer worstHCTIChannel;  // serial charge inefficiency
    private Integer worstVCTIChannel; // parallel charge inefficiency
    
   
    public void SensorSummary() {
        lsstId = "";
        maxReadNoiseChannel = 0;
        maxReadNoise = 0.0d;
        percentDefects = "";
        numTestsPassed = 0;
        worstHCTIChannel = -999;
        worstVCTIChannel = -999;
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
    
    public void setPercentDefects(String p) {
        percentDefects = p;
    }
    
    public void setNumTestsPassed(Integer num) {
        numTestsPassed = num;
    }
    
    public void setWorstHCTIChannel(Integer c) {
        worstHCTIChannel = c;
    }
    
    public void setWorstVCTIChannel(Integer c) {
        worstVCTIChannel = c;
    }
  
    public void setValues(String id, Integer readNoiseChannel, Double readNoise, String defects,
            Integer numTests) {
        lsstId = id == null || "".equals(id) ? "NA" : id; 
        maxReadNoiseChannel = readNoiseChannel;
        maxReadNoise = readNoise;
        percentDefects = defects == null || "".equals(defects) ? "NA" : defects;
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
    
    public String getPercentDefects() {
        return percentDefects;
    }
    public Integer getNumTestsPassed() {
        return numTestsPassed;
    }
    
    public Integer getWorstHCTIChannel() {
        return worstHCTIChannel;
    }
    
    public Integer getWorstVCTIChannel() {
        return worstVCTIChannel;
    }
}