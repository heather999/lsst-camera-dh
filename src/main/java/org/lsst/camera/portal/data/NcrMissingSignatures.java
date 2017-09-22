/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.lsst.camera.portal.data;
import java.util.List;
import java.util.ArrayList;
import java.util.Iterator;

//import org.srs.groupmanager.UserInfo;
/**
 *
 * @author heather
 */
public class NcrMissingSignatures {

    private String runNum;
    private Integer activityId;
    private String group;
    private List<String> gmNames;
    
    public NcrMissingSignatures(int actId, String r, String groupName, List<String> names) {
        this.activityId = actId;
        this.runNum = r == null || "".equals(r) ? "NA" : r;
        this.group = groupName == null || "".equals(groupName) ? "NA" : groupName;
        
        if (!names.isEmpty()) {   
            gmNames = new ArrayList<>();
            gmNames.addAll(names);
        } else
            gmNames = null;
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
    
    public String getGmNames() {
        if (gmNames == null) return "";
        String str = "";
        Iterator<String> iterator = gmNames.iterator();
        while (iterator.hasNext()) 
            str += iterator.next() + "<br>";
        return str;
    }
}
