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
public class TravelerInfo {

    private String name;
    private Integer actId;
    private Integer hdwId;
    private Integer statusId;
    private String statusName;

    private java.util.Date beginTime;
    private java.util.Date endTime;
    private Boolean inNCR;

    public TravelerInfo(String tName, int activityId, int hardwareId, int sId, String sName, Date b, Date e, Boolean ncr) {
        this.hdwId = hardwareId;
        this.actId = activityId;
        this.statusId = sId;
        this.name = tName == null || "".equals(tName) ? "NA" : tName;
        this.statusName = sName == null || "".equals(sName) ? "NA" : sName;
        this.beginTime = b;
        this.endTime = e;
        this.inNCR = ncr;
    }

    public String getName() {
        return name;
    }

    public void setName(String tName) {
        this.name = tName == null || "".equals(tName) ? "NA" : tName;
    }

    public Integer getActId() {
        return actId;
    }
    public void setActId(Integer id) {
        actId = id;
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

    public Date getBeginTime() {
        return beginTime;
    }

    public void setBeginTime(Date b) {
        this.beginTime = b;
    }

    public Date getEndTime() {
        return endTime;
    }

    public void setEndTime(Date e) {
        this.endTime = e;
    }

    public Date getLastTime() {
        return (this.endTime == null ? this.beginTime : this.endTime);
    }

    public Boolean getInNCR() {
        return inNCR;
    }

    public void setInNCR(Boolean ncr) {
        inNCR = ncr;
    }
}
