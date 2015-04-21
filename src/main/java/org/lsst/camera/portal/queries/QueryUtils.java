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
import org.lsst.camera.portal.data.HardwareStatus;
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
               String lsstNumber = r.getString("lsstId");
               TravelerStatus status = travelerStatusMap.get(lsstNumber);
               if ( status == null ) {
                   status = new TravelerStatus(lsstNumber);
                   travelerStatusMap.put(lsstNumber,status);
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
    
    public static String getHardwareStatus(HardwareStatus status, String travelerUniqueId) {
        String s = status.getHardwareStatus(travelerUniqueId);
        return s == null || "".equals(s) ? "NA" : s; 
    }
    
    
    public static List getHardwareStatusTable(HttpSession session, String hardwareTypeId, String ccdId) {
        List<HardwareStatus> result = new ArrayList<>();
        HardwareStatus status = null;
   //     Map<String,HardwareStatus> hardwareStatusMap = new HashMap<>();
        try ( Connection connection = ConnectionManager.getConnection(session) ) {
           
           PreparedStatement hardwareStatusStatement = connection.prepareStatement("SELECT Hardware.lsstId AS lsstId, Process.name AS name,"+
                      "Process.version AS version,Activity.begin,Activity.end,activityFinalStatusId,ActivityFinalStatus.name from Activity,"+
                      "TravelerType,Process,Hardware,ActivityFinalStatus where Activity.processId=TravelerType.id and "+
                      "Process.id=TravelerType.rootProcessId and Hardware.id=Activity.hardwareId and "+
                      "Hardware.lsstId=\"000-00\" and ActivityFinalStatus.id=Activity.activityFinalStatusId and Hardware.hardwareTypeId=? ORDER BY Activity.begin DESC;");
           // hardwareStatusStatement.setString(1, 000-00); 
           hardwareStatusStatement.setInt(1, Integer.valueOf(hardwareTypeId));
           ResultSet r = hardwareStatusStatement.executeQuery();
           r.first();
           String lsstNumber = r.getString("lsstId");
           status = new HardwareStatus(lsstNumber);
           //if ( status == null ) {
           //     status = new HardwareStatus(lsstNumber);
           //     hardwareStatusMap.put(lsstNumber,status);
           // }
            String processName = r.getString("name");
            String processVersion = r.getString("version");
            String uniqueProcessName = processName+"_"+processVersion;
            String finalStatus = r.getString("activityFinalStatusId");
            status.setHardwareStatus(uniqueProcessName, finalStatus);
                       
        } catch (Exception e) {
            e.printStackTrace();
        }
        
     //   for (HardwareStatus status : hardwareStatusMap.values()) {
            result.add(status);
       // }
        
        return result;
    }

    /*
  public static List getHdwStatLocTable(HttpSession session, ArrayList ccdList, String hardwareTypeId) {
        List<TravelerStatus> result = new ArrayList<>();
        Map<String,TravelerStatus> travelerStatusMap = new HashMap<>();
        try ( Connection connection = ConnectionManager.getConnection(session) ) {
            for (String ccd : ccdList.lsstId)
           PreparedStatement hdwStatusStatement = connection.prepareStatement("SELECT Hardware.lsstId,HardwareStatus.name, "+
                   "HardwareStatusHistory.hardwareStatusId from Hardware, HardwareStatusHistory, HardwareStatus "+
                   "where Hardware.id=HardwareStatusHistory.hardwareId and HardwareStatus.id = HardwareStatusHistory.hardwareStatusId "+
                   "and Hardware.lsstId="${ccd.lsstId}" and Hardware.hardwareTypeId="?" order By HardwareStatusHistory.creationTS DESC");
           hdwStatusStatement.setInt(2, Integer.valueOf(hardwareTypeId));
           ResultSet r = travelerStatusStatement.executeQuery();
           while (r.next() ) {
               String lsstNumber = r.getString("lsstId");
               TravelerStatus status = travelerStatusMap.get(lsstNumber);
               if ( status == null ) {
                   status = new TravelerStatus(lsstNumber);
                   travelerStatusMap.put(lsstNumber,status);
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
    
    */
}
