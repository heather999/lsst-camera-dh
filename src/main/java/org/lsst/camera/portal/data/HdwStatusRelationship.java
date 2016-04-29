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
public class HdwStatusRelationship {
    
    private String lsstId;
    private String status;
    private String location;
    private String site;
    private java.util.Date creationDate;
    private String curTravelerName;
    private String curActivityProcName;
    private String curActivityStatus;
    private java.util.Date curTravBeginTime;
    private java.util.Date curActivityLastTime;
    private long elapsedTravTime;
    private Boolean inNCR;
    private String actionName;
    private Boolean iAmMinor;
    private String otherHdwName;
    private Integer otherHdwId;
   
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
    public void setCreationDate(Date l) {
        creationDate = l; 
    }
    public void setCurTravelerName(String l) {
        curTravelerName = l == null || "".equals(l) ? "NA" : l; 
    }
    public void setCurActivityProcName(String l) {
        curActivityProcName = l == null || "".equals(l) ? "NA" : l; 
    }
    public void setCurActivityStatus(String l) {
        curActivityStatus = l == null || "".equals(l) ? "NA" : l; 
    }
    public void setCurActivityLastTime(Date l) {
        curActivityLastTime = l; 
    }
    public void setTravBeginTime(Date l) {
        curTravBeginTime = l;
    }
    
    public void setActionName(String l) {
        actionName = l == null || "".equals(l) ? "NA" : l; 
    }
    public void setIAmMinor(Boolean b) {
        iAmMinor = b;
    }
    public void setOtherHdwId(Integer i) {
        otherHdwId = i;
    }
    public void setOtherHdwName(String l) {
        otherHdwName = l == null || "".equals(l) ? "NA" : l; 
    }
    
    public void setValues(String id, String stat, String loc, String s, Date c, String name,
            String actName, String actStat, Date actLastTime, Date travBeginTime, Boolean ncr) {
        lsstId = id == null || "".equals(id) ? "NA" : id; 
        status = stat == null || "".equals(stat) ? "NA" : stat; 
        location = loc == null || "".equals(loc) ? "NA" : loc; 
        site = s == null || "".equals(s) ? "NA" : s;
        creationDate = c;
        curTravelerName = name == null || "".equals(name) ? "NA" : name;
        curActivityProcName = actName == null || "".equals(actName) ? "NA" : actName;
        curActivityStatus = actStat == null || "".equals(actStat) ? "NA" : actStat;
        curTravBeginTime = travBeginTime;
        curActivityLastTime = actLastTime;
        inNCR = ncr;
    }
    public void setRelationship(String actName, Boolean minor, Integer otherId, String otherName) {
        actionName = actName == null || "".equals(actName) ? "NA" : actName;
        iAmMinor = minor;
        otherHdwId = otherId;
        otherHdwName = otherName == null || "".equals(otherName) ? "NA" : otherName;
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
    public Date getCreationDate() {
        return creationDate;
    }
    public String getCurTravelerName() {
        return curTravelerName;
    }
    public String getCurActivityProcName() {
        return curActivityProcName;
    }
    public String getCurActivityStatus(){
        return curActivityStatus;
    }
    public Date getCurActivityLastTime(){
        return curActivityLastTime;
    }
    public Date getCurTravBeginTime () {
        return curTravBeginTime;
    }
    public long getElapsedTravTime() {
        long secondsInMilli = 1000;
        if (curTravBeginTime != null && curActivityLastTime != null) 
            return ( (curActivityLastTime.getTime() - curTravBeginTime.getTime()) / secondsInMilli );
        else
            return -1;
                    
    }
    public Boolean getInNCR() {
        return inNCR;
    }
    public void setInNCR(Boolean ncr) {
        inNCR = ncr;
    }
    
    public String getActionName() {
        return actionName;
    }
    public Boolean getIAmMinor() {
        return iAmMinor;
    }
    public Integer getOtherHdwId() {
        return otherHdwId;
    }
    public String getOtherHdwName() {
        return otherHdwName;
    }
}