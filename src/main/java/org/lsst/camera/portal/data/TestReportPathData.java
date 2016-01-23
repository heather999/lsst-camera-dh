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
public class TestReportPathData {
    
    private String lsst_num;
    private java.util.Date creationDate;
    private Integer activityId;
    private Integer catalogKey;
    private String testReportPath;
    private String testReportDirPath;
    
    public TestReportPathData() {
        lsst_num = "";
        testReportPath = "NA";
        testReportDirPath = "NA";
        activityId = -999;
        catalogKey=-999;
    }
   
    public TestReportPathData(String num, Date c, Integer id, Integer catKey, String tPath, String tDirPath) {
        this.lsst_num = num == null || "".equals(num) ? "NA" : num;
        this.creationDate = c;
        this.activityId = id;
        this.catalogKey = catKey;
        this.testReportPath = tPath == null || "".equals(tPath) ? "NA" : tPath;
        this.testReportDirPath = tDirPath == null || "".equals(tDirPath) ? "NA" : tDirPath;
    }
   
    public void setLsst_num(String id) {
        lsst_num = id == null || "".equals(id) ? "NA" : id; 
    }
    
    public void setCreationDate(Date l) {
        creationDate = l; 
    }
    
    public void setActivityId(Integer id) {
        activityId = id;
    }
    
    public void setCatalogKey(Integer key){
        catalogKey = key;
    }
    
    public void setValues(String id, Date c, Integer actid, Integer catKey, String tPath, String tDirPath) {
        lsst_num = id == null || "".equals(id) ? "NA" : id; 
        creationDate = c;
        activityId = actid;
        catalogKey = catKey;
        testReportPath = tPath == null || "".equals(tPath) ? "NA" : tPath;
        testReportDirPath = tDirPath == null || "".equals(tDirPath) ? "NA" : tDirPath;

    }
    
    public String getLsst_num() {
        return lsst_num;
    }
    
    public Date getCreationDate() {
        return creationDate;
    }
   
    public Integer getActivityId() {
        return activityId;
    }
    
    public Integer getCatalogKey() {
        return catalogKey;
    }
    public String getTestReportPath() {
         return testReportPath;
    }
    
    public String getTestReportDirPath() {
        return testReportDirPath;
    }
    
} 