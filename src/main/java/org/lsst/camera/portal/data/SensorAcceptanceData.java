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
    private Integer parentActId;
    private java.util.Date vendorIngestDate;
    private java.util.Date sreot2Date;
    private java.util.Date met05Date;
    private java.util.Date bnlSensorReceipt;
    private Boolean bnlEo;
    private String bnlEoStatus;
    private Boolean bnlMet;
    private String bnlMetStatus;
    private String bnlSensorReceiptStatus;
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
    
    public void setVendorIngestDate(java.util.Date d) {
        vendorIngestDate = d;
    }
    
    public void setSreot2Date(java.util.Date d) {
        sreot2Date = d;
    }
    
    public void setMet05Date(java.util.Date d) {
        met05Date = d;
    }
    
    public void setBnlSensorReceipt(java.util.Date d) {
        bnlSensorReceipt = d;
    }
    
    public void setBnlEo(Boolean b) {
        bnlEo = b;
    }
    public void setBnlEoStatus(String s) {
        bnlEoStatus = s == null || "".equals(s) ? "NA" : s; 
    }
    
    public void setBnlMet(Boolean b) {
        bnlMet = b;
    }
    public void setBnlMetStatus(String s) {
        bnlMetStatus = s == null || "".equals(s) ? "NA" : s; 
    }
    
    public void setBnlSensorReceiptStatus(String s) {
        bnlSensorReceiptStatus = s == null || "".equals(s) ? "NA" : s; 
    }
    
    public void setValues(String id, String ver, Integer i) {
        lsstId = id == null || "".equals(id) ? "NA" : id; 
        vendorEoTestVer = ver == null || "".equals(ver) ? "NA" : ver; 
        parentActId = i;
        ts3EoTestVer = "NA";
        bnlEo = false;
        bnlMet = false;
        bnlSensorReceiptStatus = null;
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
    
    public java.util.Date getVendorIngestDate() {
        return vendorIngestDate;
    }
    
    public java.util.Date getSreot2Date() {
        return sreot2Date;
    }
    
    public java.util.Date getMet05Date() {
        return met05Date;
    }
    
    public java.util.Date getBnlSensorReceipt() {
        return bnlSensorReceipt;
    }
    
    public String getBnlSensorReceiptStatus() {
        return bnlSensorReceiptStatus;
    }
    
    public Boolean getBnlEo() {
        return bnlEo;
    }
    public String getBnlEoStatus() {
        return bnlEoStatus;
    }
    
    public Boolean getBnlMet() {
        return bnlMet;
    }
    
    public String getBnlMetStatus() {
        return bnlMetStatus;
    }
}