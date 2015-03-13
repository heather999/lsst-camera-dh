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
public class TravelerStatus {
    
    private final String serialNumber;
    private Map<String,String> travelerStatusMap = new HashMap<>();
    
    public TravelerStatus(String serialNumber) {
        this.serialNumber = serialNumber;
    }
    
    public String getSerialNumber() {
        return serialNumber;
    }
    
    public void setTravelerStatus(String travelerId, String travelerStatus) {
        travelerStatusMap.put(travelerId,travelerStatus);
    }
    
    public String getTravelerStatus(String travelerId) {
        return travelerStatusMap.get(travelerId);
    }
    
    
}
