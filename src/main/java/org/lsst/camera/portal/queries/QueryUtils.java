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
import java.util.Iterator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpSession;
import org.lsst.camera.portal.data.TravelerStatus;
import org.lsst.camera.portal.data.HardwareStatus;
import org.lsst.camera.portal.data.HdwStatusLoc;
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
        
    // Retrieve all the LsstIds of a certain HardwareType
    // Return a Map of id, LsstId
    public static Map getComponentIds(HttpSession session, Integer hdwType) {
        HashMap<Integer,String> result = new HashMap<>();
        
       try ( Connection connection = ConnectionManager.getConnection(session) ) {
           // Construct Query selection using the list of input hardware types
           //String str="";
           //Iterator itr = hdwTypeCol.iterator();
           //while(itr.hasNext()) {
           //    Integer i = itr.next();
           //    str+="Hardware.hardwareTypeId=" + Integer.toString(i);
           //    if (itr.hasNext()) str += " OR ";
          // }
           PreparedStatement idStatement = connection.prepareStatement("select Hardware.id,Hardware.lsstId "+
                   "from Hardware,HardwareType where Hardware.hardwareTypeId=HardwareType.id and (HardwareType.id=? OR HardwareType.id=9 OR HardwareType.id=10)");
          // PreparedStatement idStatement = connection.prepareStatement("SELECT Hardware.id,Hardware.lsstId "+
           //        "FROM Hardware,HardwareType WHERE Hardware.hardwareTypeId=HardwareType.id AND " + str);
           idStatement.setInt(1, hdwType);
           ResultSet r = idStatement.executeQuery();
           while (r.next() ) {
               result.put(r.getInt("id"), r.getString("lsstId"));
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

    public static List getHdwStatLocTable(HttpSession session, Integer hardwareTypeId) {
        List<HdwStatusLoc> result = new ArrayList<>();
        // Map<String,HdwStatLoc> travelerStatusMap = new HashMap<>(); 

        try (Connection connection = ConnectionManager.getConnection(session)) {

            Map<Integer, String> compIds = getComponentIds(session, hardwareTypeId);

            for (String lsstId : compIds.values()) { // Loop over all the ccd LSST ids
                // Retrieve list of statuses for this CCD, ordered by creation time, in descending order
                PreparedStatement hdwStatusStatement = connection.prepareStatement("SELECT Hardware.lsstId,HardwareStatus.name, "
                        + "HardwareStatusHistory.hardwareStatusId from Hardware, HardwareStatusHistory, HardwareStatus "
                        + "where Hardware.id=HardwareStatusHistory.hardwareId and HardwareStatus.id = HardwareStatusHistory.hardwareStatusId "
                        + "and Hardware.lsstId=? and (Hardware.hardwareTypeId=? OR Hardware.hardwareTypeId=9 OR Hardware.hardwareTypeId=10) order By HardwareStatusHistory.creationTS DESC");
                hdwStatusStatement.setString(1, lsstId);
                hdwStatusStatement.setInt(2, Integer.valueOf(hardwareTypeId));

                ResultSet statusResult = hdwStatusStatement.executeQuery();
                statusResult.first();

                // Retrieve the list of locations associated with this CCD, ordered by creation time in descending order
                PreparedStatement hdwLocStatement = connection.prepareStatement("SELECT Hardware.lsstId, Hardware.creationTS,"
                        + " Hardware.hardwareTypeId, Location.name, Site.name AS sname, "
                        + "HardwareLocationHistory.locationId from Hardware, HardwareLocationHistory, Location, Site "
                        + "where Hardware.id=HardwareLocationHistory.hardwareId and Location.id = HardwareLocationHistory.locationId and Location.siteId = Site.id "
                        + "and Hardware.lsstId=? and (Hardware.hardwareTypeId=? OR Hardware.hardwareTypeId=9 OR Hardware.hardwareTypeId=10) order By HardwareLocationHistory.creationTS DESC");
                hdwLocStatement.setString(1,lsstId);
                hdwLocStatement.setInt(2, Integer.valueOf(hardwareTypeId));
                ResultSet locResult = hdwLocStatement.executeQuery();
                locResult.first();
                HdwStatusLoc hsl = new HdwStatusLoc();
                hsl.setValues(locResult.getString("lsstId"), statusResult.getString("name"), locResult.getString("name"), locResult.getString("sname"), locResult.getString("creationTS"));
                result.add(hsl);

            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return result;
    }
    
    //
//    public static Map getHdwGroup(HttpSession session, String lsstId) {
        
 //   }

}
