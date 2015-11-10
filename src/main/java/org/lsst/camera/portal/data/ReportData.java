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
public class ReportData {
    
    private String lsst_num;
    private java.util.Date creationDate;
    private String vendDataPath;
   
    public ReportData(String num, Date c, String vData) {
        this.lsst_num = num == null || "".equals(num) ? "NA" : num;
        this.creationDate = c;
        this.vendDataPath = vData == null || "".equals(vData) ? "NA" : vData;
    }
   
    public void setLsst_num(String id) {
        lsst_num = id == null || "".equals(id) ? "NA" : id; 
    }
    
    public void setCreationDate(Date l) {
        creationDate = l; 
    }
    
    
    public void setValues(String id, Date c, String vDataPath) {
        lsst_num = id == null || "".equals(id) ? "NA" : id; 
        creationDate = c;
        vendDataPath = vDataPath == null || "".equals(vDataPath) ? "NA" : vDataPath;
    }
    
    public String getLsst_num() {
        return lsst_num;
    }
    
    public Date getCreationDate() {
        return creationDate;
    }
   
    public String getVendDataPath() {
         return vendDataPath;
    }
    
}