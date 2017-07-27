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
    private Integer hardwareId;
    private Integer maxReadNoiseChannel;
    private Double maxReadNoise;
    private Boolean passedReadNoise;
    private String percentDefects;
    private Boolean passedPercentDefects;
    private Integer numTestsPassed;
    private Integer worstHCTIChannel;  // serial charge inefficiency
    private String worstHCTI;
    private Boolean passedHCTI;
    private Integer worstVCTIChannel; // parallel charge inefficiency
    private String worstVCTI;
    private Boolean passedVCTI;
    
   
    public void SensorSummary() {
        lsstId = "";
        hardwareId = 0;
        maxReadNoiseChannel = 0;
        maxReadNoise = 0.0d;
        percentDefects = "";
        numTestsPassed = 0;
        worstHCTIChannel = -999;
        worstVCTIChannel = -999;
        worstHCTI = "";
        worstVCTI = "";
        passedReadNoise = false;
        passedHCTI = false;
        passedVCTI = false;
        passedPercentDefects = false;
    }
    
    public void setLsstId(String id) {
        lsstId = id == null || "".equals(id) ? "NA" : id; 
    }
  
    public void setHardwareId(Integer i) { 
        hardwareId = i;
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
    
    public void setWorstHCTI(String d) {
        worstHCTI = d;
    }
    
    public void setWorstVCTIChannel(Integer c) {
        worstVCTIChannel = c;
    }
    
    public void setWorstVCTI(String d) {
        worstVCTI = d;
    }
    
    public void setPassedReadNoise(Boolean b) {
        passedReadNoise = b;
    }
    
    public void setPassedVCTI(Boolean b) {
        passedVCTI = b;
    }
    
    public void setPassedHCTI(Boolean b) {
        passedHCTI = b;
    }
  
    public void setPassedPercentDefects(Boolean b) {
        passedPercentDefects = b;
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
    
    public Integer getHardwareId() {
        return hardwareId;
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
    
    public String getWorstHCTI () {
        return worstHCTI;
    }
    
    public Integer getWorstHCTIChannel() {
        return worstHCTIChannel;
    }
    
    public String getWorstVCTI() {
        return worstVCTI;
    }
    
    public Integer getWorstVCTIChannel() {
        return worstVCTIChannel;
    }

    public Boolean getPassedReadNoise() {
        return passedReadNoise;
    }

    public Boolean getPassedHCTI() {
        return passedHCTI;
    }

    public Boolean getPassedVCTI() {
        return passedVCTI;
    }
    
    public Boolean getPassedPercentDefects() { 
        return passedPercentDefects;
    }
}
