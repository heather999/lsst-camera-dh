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
public class Activity {
    private Integer activityId;
    private Integer processId;
    private Integer parentActivityId;
    private Integer hdwId;
    private Integer statusId;
    private String statusName;
    private Integer index;
    
    
    public Activity(int id, int pId, int parentId, int hardwareId, int sId, String sName, int ind) {
        this.activityId = id;
        this.processId = pId;
        this.parentActivityId = parentId;
        this.hdwId = hardwareId;
        this.statusId=sId;
        this.statusName=sName;
        this.index=ind;
    }
    

    public Integer getActivityId() {
        return activityId;
    }
    public void setActivityId(int id) {
        activityId = id;
    }
    public Integer getProcessId(){
        return processId;
    }
    public void setProcessId(int pId){
        processId = pId;
    }
    public Integer getParentActivityId(){
        return parentActivityId;
    }
    public void setParentActivityId(int pId) {
        parentActivityId = pId; 
    }
    public boolean isParent() {
        if (parentActivityId == -999) return true;
        else return false;
    }
    public Integer getHdwId(){
        return hdwId;
    }
    public void setHdwId(int hardwareId) {
        hdwId = hardwareId;
    }
    public Integer getStatusId(){
        return statusId;
    }
    public void setStatusId(int sId) {
        statusId = sId;
    }
    public String getStatusName(){
        return statusName;
    }
    public void setStatusName(String name) {
        statusName = name == null || "".equals(name) ? "NA" : name; 
    }
      public Integer getIndex(){
      return index;
  }
  public void setIndex(int ind){
      index = ind;
  }
}
