/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.lsst.camera.portal.data;

import java.util.HashMap;
import java.util.Map;

/**
 *
 * @author heather
 */
public class HardwareStatus {
    
    private final String lsstNumber;
    private Map<String,String> hardwareStatusMap = new HashMap<>();
    
    public HardwareStatus(String lsstNumber) {
        this.lsstNumber = lsstNumber;
    }
    
    public String getLsstNumber() {
        return lsstNumber;
    }
    
    public void setHardwareStatus(String hardwareId, String hardwareStatus) {
        hardwareStatusMap.put(hardwareId,hardwareStatus);
    }
    
    public String getHardwareStatus(String hardwareId) {
        return hardwareStatusMap.get(hardwareId);
    }
    
    
}
