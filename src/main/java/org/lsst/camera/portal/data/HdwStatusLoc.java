/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.lsst.camera.portal.data;
/**
 *
 * @author heather
 */
public class HdwStatusLoc {
    
    private String lsstId;
    private String status;
    private String location;
    
   
    public void setLsstId(String id) {
        lsstId = id == null || "".equals(id) ? "NA" : id; 
    }
    public void setStatus(String s) {
        status = s == null || "".equals(s) ? "NA" : s; 
    }
    public void setLocation(String l) {
        location = l == null || "".equals(l) ? "NA" : l; 
    }
    public String getLsstId() {
        return lsstId;
    }
    public String getStatus() {
        return status;
    }
    public String getLocation() {
        return location;
    }
    
    
    
}
