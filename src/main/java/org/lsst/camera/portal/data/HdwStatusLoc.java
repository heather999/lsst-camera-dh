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
    private String site;
    private String creationDate;
    private String curTravelerName;
    
   
    public void setLsstId(String id) {
        lsstId = id == null || "".equals(id) ? "NA" : id; 
    }
    public void setStatus(String s) {
        status = s == null || "".equals(s) ? "NA" : s; 
    }
    public void setLocation(String l) {
        location = l == null || "".equals(l) ? "NA" : l; 
    }
    public void setSite(String l) {
        location = l == null || "".equals(l) ? "NA" : l; 
    }
    public void setCreationDate(String l) {
        creationDate = l == null || "".equals(l) ? "NA" : l; 
    }
    public void setCurTravelerName(String l) {
        curTravelerName = l == null || "".equals(l) ? "NA" : l; 
    }
    public void setValues(String id, String stat, String loc, String s, String c, String name) {
        lsstId = id == null || "".equals(id) ? "NA" : id; 
        status = stat == null || "".equals(stat) ? "NA" : stat; 
        location = loc == null || "".equals(loc) ? "NA" : loc; 
        site = s == null || "".equals(s) ? "NA" : s;
        creationDate = c == null || "".equals(c) ? "NA" : c;
        curTravelerName = name == null || "".equals(name) ? "NA" : name;
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
    public String getSite() { 
        return site;
    }
    public String getCreationDate() {
        return creationDate;
    }
    public String getCurTravelerName() {
        return curTravelerName;
    }
    
}
