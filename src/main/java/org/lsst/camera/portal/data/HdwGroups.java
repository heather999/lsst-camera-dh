/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.lsst.camera.portal.data;

import java.util.Map;
/**
 *
 * @author heather
 */
public class HdwGroups {
    
    private String lsstId;
    private Integer hdwTypeId;
    private Map<Integer, String> groupCol;
    private Integer hdwGroupId;
    private String hdwGroupName;
    
   
    public void setLsstId(String id) {
        lsstId = id == null || "".equals(id) ? "NA" : id; 
    }
    public void setHdwGroupName(String name) {
        hdwGroupName = name == null || "".equals(name) ? "NA" : name; 
    }
    public void setHdwTypeId(Integer id) {
        hdwTypeId = id; 
    }
    public void setHdwGroupId(Integer l) {
        hdwGroupId = l; 
    }
    
    public void addGroup(Integer id, String name) {
        groupCol.put(id, name);
    }
    
    public void setValues(String id, String name, Integer typeId, Integer groupId) {
        lsstId = id == null || "".equals(id) ? "NA" : id; 
        hdwGroupName = name == null || "".equals(name) ? "NA" : name; 
        hdwTypeId = typeId;
        hdwGroupId = groupId;
    }
    public String getLsstId() {
        return lsstId;
    }
    public String getHdwGroupName() {
        return hdwGroupName;
    }
    public Integer getHdwTypeId() {
        return hdwTypeId;
    }
    public Integer getHdwGroupId() { 
        return hdwGroupId;
    }
    public Map<Integer, String> getGroupCol() {
        return groupCol;
    }
    
    
}
