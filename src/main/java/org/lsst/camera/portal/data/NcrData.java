/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.lsst.camera.portal.data;
import org.lsst.camera.portal.data.NcrMissingSignatures;
import java.util.Date;
import java.util.List;
import java.util.ArrayList;

/**
 *
 * @author heather
 */
public class NcrData {

    private Integer activityId;
    private Integer rootActivityId;
    private String runNum;
    private Integer hdwId;
    private String lsstNum;
    private String hdwType;
    private String subsystem;
    private String description;
    private java.util.Date beginTime;
    private Boolean finalStatus;
    private Integer statusId;
    private String statusName;
    private java.util.Date ncrCreationTime;
    private String priority;
    private String currentStep;
    private int numMissingSigs;
    private List<NcrMissingSignatures> missingSigs;

    // the whole enchilada
    public NcrData(int actId, int rootId, String runN, String lsstId, String typeName, int sId,
                   String sName, Date b, Boolean f,
                   Date create, String subsystem, String description) {
        this.activityId = actId;
        this.rootActivityId = rootId;
       // this.hdwId = hardwareId;
        this.statusId = sId;
        this.runNum = runN == null || "".equals(runN) ? "NA" : runN;
        this.lsstNum = lsstId == null || "".equals(lsstId) ? "NA" : lsstId;
        this.statusName = sName == null || "".equals(sName) ? "NA" : sName;
        this.hdwType = typeName == null || "".equals(typeName) ? "NA" : typeName;
        this.beginTime = b;
        this.finalStatus = f;
        this.ncrCreationTime = create;
        this.priority = "";
        this.currentStep = "";
        this.missingSigs = new ArrayList<>();
        this.numMissingSigs = 0;
        this.subsystem = subsystem;
        this.description = description;
    }
    
    public NcrData(int actId, int rootId, String runN, String lsstId, String typeName, int sId,
                   String sName, Date b, Boolean f, Date create) {
        this.activityId = actId;
        this.rootActivityId = rootId;
       // this.hdwId = hardwareId;
        this.statusId = sId;
        this.runNum = runN == null || "".equals(runN) ? "NA" : runN;
        this.lsstNum = lsstId == null || "".equals(lsstId) ? "NA" : lsstId;
        this.statusName = sName == null || "".equals(sName) ? "NA" : sName;
        this.hdwType = typeName == null || "".equals(typeName) ? "NA" : typeName;
        this.beginTime = b;
        this.finalStatus = f;
        this.ncrCreationTime = create;
        this.priority = "";
        this.currentStep = "";
        this.missingSigs = new ArrayList<>();
        this.numMissingSigs = 0;
    }

    public NcrData(int actId, int rootId, String runN, String lsstId, String typeName, Date create) {
        // truncated data for signatures only
        this.activityId = actId;
        this.rootActivityId = rootId;
        this.statusId = 0;
        this.runNum = runN == null || "".equals(runN) ? "NA" : runN;
        this.lsstNum = lsstId == null || "".equals(lsstId) ? "NA" : lsstId;
        this.statusName = "";
        this.hdwType = typeName == null || "".equals(typeName) ? "NA" : typeName;
        this.finalStatus = null;
        this.ncrCreationTime = create;
        this.priority = "";
        this.currentStep = "";
        this.missingSigs = new ArrayList<>();
        this.numMissingSigs = 0;
    }
    
    public NcrData(int rootId, String runN, String lsstId) {
        // truncated data for signatures only
        this.activityId = 0;
        this.rootActivityId = rootId;
        this.statusId = 0;
        this.runNum = runN == null || "".equals(runN) ? "NA" : runN;
        this.lsstNum = lsstId == null || "".equals(lsstId) ? "NA" : lsstId;
        this.statusName = "";
        this.hdwType = "NA";
        this.finalStatus = null;
        this.ncrCreationTime = null;
        this.priority = "";
        this.currentStep = "";
        this.missingSigs = new ArrayList<>();
        this.numMissingSigs = 0;
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

    public String getRunNum() {
        return runNum;
    }
    
    public void setRunNum(String r) {
        runNum = r == null || "".equals(r) ? "NA" : r;
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
    
    public Date getNcrCreationTime() {
        return ncrCreationTime;
    }

    public void setNcrCreationTime(Date b) {
        this.ncrCreationTime = b;
    }
    
    public String getPriority() {
        return priority;
    }
    
    public void setPriority(String p) {
        priority = p == null || "".equals(p) ? "NA" : p;
    }
    
    public String getCurrentStep() {
        return currentStep;
    }
    
    public void setCurrentStep(String p) {
        currentStep = p == null || "".equals(p) ? "NA" : p;
    }
    
   
    public void setMissingSigs(List<NcrMissingSignatures> m) {
        if (!m.isEmpty()) {
            missingSigs.addAll(m);
            numMissingSigs = missingSigs.size();
        }
    }
    
    public List<NcrMissingSignatures> getMissingSigs() {
        return missingSigs;
    }
    
    public int getNumMissingSigs() {
        return numMissingSigs;
    }

    public String getSubsystem() {
        return subsystem;
    }
    public void setSubsystem(String s) {
        subsystem = s == null || "".equals(s) ? "NA" : s;
    }
    public String getDescription() {
        return description;
    }
    public void setDescription(String d) {
        description = d == null || "".equals(d) ? "NA" : d;
    }
}
