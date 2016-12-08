/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.lsst.camera.portal.data;
import java.util.Date;
//import java.util.HashMap;
/**
 *
 * @author heather
 */
public class SensorAcceptanceData {
    
    private String lsstId;
    private String vendorEoTestVer;
    private String ts3EoTestVer;
    public Integer parentActId;
//    private String status;
//    private String location;
//    private String site;
//    private java.util.Date creationDate;
//    private String curTravelerName;
 //   private String curActivityProcName;
 //   private String curActivityStatus;
 //   private java.util.Date curTravBeginTime;
 //   private java.util.Date curActivityLastTime;
    //private Boolean inNCR;
    //private HashMap<Integer,String> labelMap = new HashMap<>();
    
   
    public void setLsstId(String id) {
        lsstId = id == null || "".equals(id) ? "NA" : id; 
    }
  
 
    public void setVendorEoTestVer(String ver) {
        vendorEoTestVer = ver == null || "".equals(ver) ? "NA" : ver; 
    }
    
    public void setParentActId(Integer i) {
        parentActId = i;
    }
    
    public void setTs3EoTestVer(String ver) {
        ts3EoTestVer = ver == null || "".equals(ver) ? "NA" : ver; 
    }
    
    public void setValues(String id, String ver, Integer i) {
        lsstId = id == null || "".equals(id) ? "NA" : id; 
        vendorEoTestVer = ver == null || "".equals(ver) ? "NA" : ver; 
        parentActId = i;
        ts3EoTestVer = "NA";
    }
    
  
    public String getLsstId() {
        return lsstId;
    }
 
    public String getVendorEoTestVer () {
        return vendorEoTestVer;
    }
    
    public Integer getParentActId() {
        return parentActId;
    }
    
    public String getTs3EoTestVer() {
        return ts3EoTestVer;
    }
    
}