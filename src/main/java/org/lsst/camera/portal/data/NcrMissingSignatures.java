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
public class NcrMissingSignatures {

    private String runNum;
    private Integer activityId;
    private String group;
    
    public NcrMissingSignatures(int actId, String r, String groupName) {
        this.activityId = actId;
        this.runNum = r == null || "".equals(r) ? "NA" : r;
        this.group = groupName == null || "".equals(groupName) ? "NA" : groupName;
    }

    public Integer getActivityId() {
        return activityId;
    }

    public void setActivityId(int id) {
        activityId = id;
    }

    public String getRunNum() {
        return runNum;
    }

    public void setRunNum(String run) {
        group = run == null || "".equals(run) ? "NA" : run;

    }
    
    public void setGroup(String p) {
        group = p == null || "".equals(p) ? "NA" : p;
    }
    
    public String getGroup() {
        return group;
    }
    
}
