/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.lsst.camera.portal.data;
import java.util.Date;

/**
 *
 * @author heather
 */
public class ComponentData {
    
    private String lsst_num;
    private String manufacturer;
    private Integer hdwId;
    private java.util.Date registrationDate;
   
    
   public ComponentData(String num, String m, Integer id, java.util.Date d) {
       this.lsst_num = num == null || "".equals(num) ? "NA" : num; 
       this.manufacturer = m == null || "".equals(m) ? "NA" : m; 
       this.hdwId = id;
       this.registrationDate = d;
   }
   
    public void setLsst_num(String num) {
        lsst_num = num == null || "".equals(num) ? "NA" : num; 
    }
    
    public void setHdwId(Integer id) {
        hdwId = id; 
    }
    
    public void setManufacturer(String m) {
        manufacturer = m == null || "".equals(m) ? "NA" : m; 
    }
    
    public void setRegistrationDate(java.util.Date d) {
            registrationDate = d;
    }
    
    public void setValues(String id, String m, Integer hid, java.util.Date d) {
        lsst_num = id == null || "".equals(id) ? "NA" : id; 
        manufacturer = m == null || "".equals(m) ? "NA" : m;
        hdwId = hid;
        registrationDate = d;
    }
    
    public String getLsst_num() {
        return lsst_num;
    }
    
    public Integer getHdwId() {
         return hdwId;
    }
   
    public String getManufacturer() {
         return manufacturer;
    }
    
    public java.util.Date getRegistrationDate() {
        return registrationDate;
    }
}