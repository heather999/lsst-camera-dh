/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.lsst.camera.portal.data;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
/**
 *
 * @author heather
 */
public class CatalogFileData {
    
    private Integer activityId;
    private java.util.Date creationDate;
    private String virtualPath;
    private Integer catalogKey;
    private String createdBy;
    
   
    public CatalogFileData(Integer actId, Date c, String vPath, Integer catKey, String creator) {
        this.activityId = actId;
        this.virtualPath = vPath == null || "".equals(vPath) ? "NA" : vPath;
        this.creationDate = c;
        this.catalogKey = catKey;
        this.createdBy = creator == null || "".equals(creator) ? "NA" : creator;
    }
    
    public void setActivityId(Integer id) {
        activityId = id;
    }
   
    public void setVirtualPath(String vPath) {
        virtualPath = vPath == null || "".equals(vPath) ? "NA" : vPath; 
    }
    
    public void setCreationDate(Date l) {
        creationDate = l; 
    }
    
    public void setCatalogKey(Integer catKey) {
        catalogKey = catKey;
    }
    
    public void setCreatedBy(String creator) {
        createdBy = creator == null || "".equals(creator) ? "NA" : creator; 
    }
    
    
    public Integer getActivityId() {
        return activityId;
    }
    
    public Date getCreationDate() {
        return creationDate;
    }
   
    public String getVirtualPath() {
         return virtualPath;
    }
   
    public Integer getCatalogKey() {
        return catalogKey;
    }
    
    public String getCreatedBy() {
        return createdBy;
    }
}