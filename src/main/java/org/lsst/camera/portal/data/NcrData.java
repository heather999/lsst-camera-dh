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
public class NcrData {

    private Integer activityId;
    private Integer rootActivityId;
    private Integer hdwId;
    private String lsstNum;
    private String hdwType;
    private java.util.Date beginTime;
    private Boolean finalStatus;
    private Integer statusId;
    private String statusName;
    
    public NcrData(int actId, int rootId, String lsstId, String typeName, int sId, String sName, Date b, Boolean f) {
        this.activityId = actId;
        this.rootActivityId = rootId;
       // this.hdwId = hardwareId;
        this.statusId = sId;
        this.lsstNum = lsstId == null || "".equals(lsstId) ? "NA" : lsstId;
        this.statusName = sName == null || "".equals(sName) ? "NA" : sName;
        this.hdwType = typeName == null || "".equals(typeName) ? "NA" : typeName;
        this.beginTime = b;
        this.finalStatus = f;
       
    }

    public Integer getActivityId() {
        return activityId;
    }

    public void setActivityId(int id) {
        activityId = id;
    }


    public Integer getRootActivityId() {
        return rootActivityId;
    }

    public void setRootActivityId(int pId) {
        rootActivityId = pId;
    }


    public Integer getHdwId() {
        return hdwId;
    }

    public void setHdwId(int hardwareId) {
        hdwId = hardwareId;
    }

    public Integer getStatusId() {
        return statusId;
    }

    public void setStatusId(int sId) {
        statusId = sId;
    }

    public String getStatusName() {
        return statusName;
    }

    public void setStatusName(String name) {
        statusName = name == null || "".equals(name) ? "NA" : name;
    }

    public String getHdwType() {
        return hdwType;
    }

    public void setHdwType(String name) {
        hdwType = name == null || "".equals(name) ? "NA" : name;
    }

    
    public String getLsstNum() {
        return lsstNum;
    }

    public void setLsstNum(String name) {
        lsstNum = name == null || "".equals(name) ? "NA" : name;
    }
    
    public Date getBeginTime() {
        return beginTime;
    }

    public void setBeginTime(Date b) {
        this.beginTime = b;
    }

    public Boolean getFinalStatus() {
       return finalStatus;
    }
    
}
