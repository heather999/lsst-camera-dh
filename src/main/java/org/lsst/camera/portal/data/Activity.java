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
public class Activity {

    private Integer activityId;
    private Integer processId;
    private Integer parentActivityId;
    private Integer rootActivityId;
    private Integer hdwId;
    private Integer statusId;
    private String statusName;
    private java.util.Date beginTime;
    private java.util.Date endTime;
    private Boolean inNCR;
    private Integer index;

    public Activity(int id, int pId, int parentId, int rootId, int hardwareId, int sId, String sName, Date b, Date e, Boolean ncr, int ind) {
        this.activityId = id;
        this.processId = pId;
        this.rootActivityId = rootId;
        this.parentActivityId = parentId;
        this.hdwId = hardwareId;
        this.statusId = sId;
        this.statusName = sName == null || "".equals(sName) ? "NA" : sName;
        this.beginTime = b;
        this.endTime = e;
        this.inNCR = ncr;
        this.index = ind;
    }

    public Integer getActivityId() {
        return activityId;
    }

    public void setActivityId(int id) {
        activityId = id;
    }

    public Integer getProcessId() {
        return processId;
    }

    public void setProcessId(int pId) {
        processId = pId;
    }

    public Integer getParentActivityId() {
        return parentActivityId;
    }

    public void setParentActivityId(int pId) {
        parentActivityId = pId;
    }
    
    public Integer getRootActivityId() {
        return rootActivityId;
    }
    
    public void setRootActivityId(int rId) {
        rootActivityId = rId;
    }

    public boolean isParent() {
        if (parentActivityId == -999) {
            return true;
        } else {
            return false;
        }
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

    public Integer getIndex() {
        return index;
    }

    public void setIndex(int ind) {
        index = ind;
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
