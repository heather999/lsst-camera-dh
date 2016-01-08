/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.lsst.camera.portal.data;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import org.lsst.camera.portal.data.TestReportPathData;
/**
 *
 * @author heather
 */
public class ReportData {
    
    private String lsst_num;
    private java.util.Date creationDate;
    private String vendDataPath;
    private Integer offlineReportCatKey;
    private String testReportOfflinePath;
    private String testReportOfflineDirPath;
    private List<TestReportPathData> offlineReportCol = new ArrayList<>();
   
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
    
    public void setOfflineReportCatKey(Integer catKey) {
        offlineReportCatKey = catKey;
    }
    
    public void setValues(String id, Date c, String vDataPath) {
        lsst_num = id == null || "".equals(id) ? "NA" : id; 
        creationDate = c;
        vendDataPath = vDataPath == null || "".equals(vDataPath) ? "NA" : vDataPath;
    }
    
    public void setTestReportOfflinePath(String path) {
        testReportOfflinePath = path == null || "".equals(path) ? "NA" : path;
    }
    
    public void setTestReportOfflineDirPath(String path) {
        testReportOfflineDirPath = path == null || "".equals(path) ? "NA" : path;
    }
    
    public void addTestReportPathData(TestReportPathData data) {
        offlineReportCol.add(data);
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
   
    public Integer getOfflineReportCatKey() {
        return offlineReportCatKey;
    }
    
    public String getTestReportOfflinePath(){
        return testReportOfflinePath;
    }
    
    public String getTestReportOfflineDirPath() {
        return testReportOfflineDirPath;
    }
    
    public List getOfflineReportCol() {
        return offlineReportCol;
    }
}