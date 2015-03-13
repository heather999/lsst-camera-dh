/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.lsst.camera.portal.queries;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpSession;
import org.lsst.camera.portal.data.TravelerStatus;
import org.srs.web.base.db.ConnectionManager;

/**
 *
 * @author heather
 */
public class QueryUtils {
    
    
    public static Map getHardwareTypes(HttpSession session) {
        HashMap<Integer,String> result = new HashMap<>();
        
       try ( Connection connection = ConnectionManager.getConnection(session) ) {
           
           PreparedStatement localHardwareTypesStatement = connection.prepareStatement("select id, name from HardwareType");
           ResultSet r = localHardwareTypesStatement.executeQuery();
           while (r.next() ) {
               result.put(r.getInt("id"), r.getString("name"));
           }            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return result;
    }
        

    public static String getTravelerStatus(TravelerStatus status, String travelerUniqueId) {
        String s = status.getTravelerStatus(travelerUniqueId);
        return s == null || "".equals(s) ? "NA" : s; 
    }
    
    
    
    public static List getTravelerStatusTable(HttpSession session, String hardwareTypeId) {
        List<TravelerStatus> result = new ArrayList<>();
        Map<String,TravelerStatus> travelerStatusMap = new HashMap<>();
        try ( Connection connection = ConnectionManager.getConnection(session) ) {
           
           PreparedStatement travelerStatusStatement = connection.prepareStatement("select  Hardware.lsstId, Process.name,Process.version,Activity.begin,Activity.end,activityFinalStatusId "+
                   "from Activity,TravelerType,Process,Hardware where Activity.processId=TravelerType.id and Process.id=TravelerType.rootProcessId "+
                   "and Hardware.id=Activity.hardwareId and Hardware.hardwareTypeId=?");
           travelerStatusStatement.setInt(1, Integer.valueOf(hardwareTypeId));
           ResultSet r = travelerStatusStatement.executeQuery();
           while (r.next() ) {
               String serialNumber = r.getString("lsstId");
               TravelerStatus status = travelerStatusMap.get(serialNumber);
               if ( status == null ) {
                   status = new TravelerStatus(serialNumber);
                   travelerStatusMap.put(serialNumber,status);
               }
               String travelerName = r.getString("name");
               String travelerVersion = r.getString("version");
               String uniqueTravelerName = travelerName+"_"+travelerVersion;
               String travelerFinalStatus = r.getString("activityFinalStatusId");
               status.setTravelerStatus(uniqueTravelerName, travelerFinalStatus);
           }            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        for (TravelerStatus status : travelerStatusMap.values()) {
            result.add(status);
        }
        
        return result;
    }
    
    
    
}
