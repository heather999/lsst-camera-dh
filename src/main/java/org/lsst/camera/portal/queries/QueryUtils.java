/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.lsst.camera.portal.queries;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import javax.servlet.http.HttpSession;
import org.lsst.camera.portal.data.TravelerStatus;
import org.lsst.camera.portal.data.HardwareStatus;
import org.lsst.camera.portal.data.HdwStatusLoc;
import org.lsst.camera.portal.data.Activity;
import org.srs.web.base.db.ConnectionManager;

/**
 *
 * @author heather
 */
public class QueryUtils {

    public static Map getHardwareTypes(HttpSession session) throws SQLException {
        HashMap<Integer, String> result = new HashMap<>();

        Connection c = null;
        try {
            c = ConnectionManager.getConnection(session);

            PreparedStatement localHardwareTypesStatement = c.prepareStatement("select id, name from HardwareType");
            ResultSet r = localHardwareTypesStatement.executeQuery();
            while (r.next()) {
                result.put(r.getInt("id"), r.getString("name"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (c != null) {
                //Close the connection
                c.close();
            }
        }
        return result;
    }

    public static TreeMap getActivityMap(HttpSession session, Integer hdwId) throws SQLException {
        TreeMap<Integer, Activity> activityMap = new TreeMap<>();
        Connection c = null;
        try {
            c = ConnectionManager.getConnection(session);

            PreparedStatement idStatement = c.prepareStatement("SELECT A.id, "
                    + "A.hardwareId, A.processId, A.parentActivityId, ASH.activityStatusId, "
                    + "AFS.name, A.end, A.begin FROM "
                    + "Activity A INNER JOIN ActivityStatusHistory ASH ON ASH.activityId=A.id AND "
                    + "ASH.id=(select max(id) FROM ActivityStatusHistory WHERE activityId=A.id) "
                    + "INNER JOIN ActivityFinalStatus AFS ON AFS.id=ASH.activityStatusId "
                    + "WHERE hardwareId=? ORDER BY A.id DESC");
            idStatement.setInt(1, hdwId);
            ResultSet r = idStatement.executeQuery();
            int index = 0;
            while (r.next()) {
                // Need to check for null values in the parentId column
                int parentId = r.getInt("parentActivityId");
                if (parentId == 0 && r.wasNull()) {
                    parentId = -999;
                }
                // Use the keep track of order by activity Id
                activityMap.put(r.getInt("id"), new Activity(r.getInt("id"), r.getInt("processId"), parentId, r.getInt("hardwareId"),
                        r.getInt("activityStatusId"), r.getString("name"), r.getTimestamp("begin"), r.getTimestamp("end"),index));
                index++;
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (c != null) {
                //Close the connection
                c.close();
            }
        }

        return activityMap;
    }

    // Retrieve all the LsstIds of a certain HardwareType
    // Return a Map of id, LsstId
    public static Map getComponentIds(HttpSession session, Integer hdwType) throws SQLException {
        HashMap<Integer, String> result = new HashMap<>();

        Connection c = null;
        try {
            c = ConnectionManager.getConnection(session);
           // Construct Query selection using the list of input hardware types
            //String str="";
            //Iterator itr = hdwTypeCol.iterator();
            //while(itr.hasNext()) {
            //    Integer i = itr.next();
            //    str+="Hardware.hardwareTypeId=" + Integer.toString(i);
            //    if (itr.hasNext()) str += " OR ";
            // }
            PreparedStatement idStatement = c.prepareStatement("select Hardware.id,Hardware.lsstId "
                    + "from Hardware,HardwareType where Hardware.hardwareTypeId=HardwareType.id and (HardwareType.id=? OR HardwareType.id=9 OR HardwareType.id=10)");
          // PreparedStatement idStatement = connection.prepareStatement("SELECT Hardware.id,Hardware.lsstId "+
            //        "FROM Hardware,HardwareType WHERE Hardware.hardwareTypeId=HardwareType.id AND " + str);
            idStatement.setInt(1, hdwType);
            ResultSet r = idStatement.executeQuery();
            while (r.next()) {
                result.put(r.getInt("id"), r.getString("lsstId"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (c != null) {
                //Close the connection
                c.close();
            }
        }

        return result;

    }

    public static String getTravelerStatus(TravelerStatus status, String travelerUniqueId) {
        String s = status.getTravelerStatus(travelerUniqueId);
        return s == null || "".equals(s) ? "NA" : s;
    }

    public static List getTravelerStatusTable(HttpSession session, String hardwareTypeId) throws SQLException {
        List<TravelerStatus> result = new ArrayList<>();
        Map<String, TravelerStatus> travelerStatusMap = new HashMap<>();
        Connection c = null;
        try {
            c = ConnectionManager.getConnection(session);
            PreparedStatement travelerStatusStatement = c.prepareStatement("select  Hardware.lsstId, Process.name,Process.version,Activity.begin,Activity.end,activityFinalStatusId "
                    + "from Activity,TravelerType,Process,Hardware where Activity.processId=TravelerType.id and Process.id=TravelerType.rootProcessId "
                    + "and Hardware.id=Activity.hardwareId and Hardware.hardwareTypeId=?");
            travelerStatusStatement.setInt(1, Integer.valueOf(hardwareTypeId));
            ResultSet r = travelerStatusStatement.executeQuery();
            while (r.next()) {
                String lsstNumber = r.getString("lsstId");
                TravelerStatus status = travelerStatusMap.get(lsstNumber);
                if (status == null) {
                    status = new TravelerStatus(lsstNumber);
                    travelerStatusMap.put(lsstNumber, status);
                }
                String travelerName = r.getString("name");
                String travelerVersion = r.getString("version");
                String uniqueTravelerName = travelerName + "_" + travelerVersion;
                String travelerFinalStatus = r.getString("activityFinalStatusId");
                status.setTravelerStatus(uniqueTravelerName, travelerFinalStatus);
            }

            for (TravelerStatus status : travelerStatusMap.values()) {
                result.add(status);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (c != null) {
                //Close the connection
                c.close();
            }
        }
        return result;
    }

    public static String getHardwareStatus(HardwareStatus status, String travelerUniqueId) {
        String s = status.getHardwareStatus(travelerUniqueId);
        return s == null || "".equals(s) ? "NA" : s;
    }

    public static List getHardwareStatusTable(HttpSession session, String hardwareTypeId, String ccdId) throws SQLException {
        List<HardwareStatus> result = new ArrayList<>();
        HardwareStatus status = null;
        //     Map<String,HardwareStatus> hardwareStatusMap = new HashMap<>();
        Connection c = null;
        try {
            c = ConnectionManager.getConnection(session);

            PreparedStatement hardwareStatusStatement = c.prepareStatement("SELECT Hardware.lsstId AS lsstId, Process.name AS name,"
                    + "Process.version AS version,Activity.begin,Activity.end,activityFinalStatusId,ActivityFinalStatus.name from Activity,"
                    + "TravelerType,Process,Hardware,ActivityFinalStatus where Activity.processId=TravelerType.id and "
                    + "Process.id=TravelerType.rootProcessId and Hardware.id=Activity.hardwareId and "
                    + "Hardware.lsstId=\"000-00\" and ActivityFinalStatus.id=Activity.activityFinalStatusId and Hardware.hardwareTypeId=? ORDER BY Activity.begin DESC;");
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
            String uniqueProcessName = processName + "_" + processVersion;
            String finalStatus = r.getString("activityFinalStatusId");
            status.setHardwareStatus(uniqueProcessName, finalStatus);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (c != null) {
                //Close the connection
                c.close();
            }
        }
        //   for (HardwareStatus status : hardwareStatusMap.values()) {
        result.add(status);
       // }

        return result;
    }

    public static List getHdwStatLocTable(HttpSession session, Integer hardwareTypeId) throws SQLException {
        List<HdwStatusLoc> result = new ArrayList<>();
        // Map<String,HdwStatLoc> travelerStatusMap = new HashMap<>(); 

        Connection c = null;
        try {
            c = ConnectionManager.getConnection(session);

            Map<Integer, String> compIds = getComponentIds(session, hardwareTypeId);

            for (String lsstId : compIds.values()) { // Loop over all the ccd LSST ids
                // Retrieve list of statuses for this CCD, ordered by creation time, in descending order
                PreparedStatement hdwStatusStatement = c.prepareStatement("SELECT Hardware.lsstId,HardwareStatus.name, "
                        + "HardwareStatusHistory.hardwareStatusId from Hardware, HardwareStatusHistory, HardwareStatus "
                        + "where Hardware.id=HardwareStatusHistory.hardwareId and HardwareStatus.id = HardwareStatusHistory.hardwareStatusId "
                        + "and Hardware.lsstId=? and (Hardware.hardwareTypeId=? OR Hardware.hardwareTypeId=9 OR Hardware.hardwareTypeId=10) order By HardwareStatusHistory.creationTS DESC");
                hdwStatusStatement.setString(1, lsstId);
                hdwStatusStatement.setInt(2, Integer.valueOf(hardwareTypeId));

                ResultSet statusResult = hdwStatusStatement.executeQuery();
                statusResult.first();

                // Retrieve the list of locations associated with this CCD, ordered by creation time in descending order
                PreparedStatement hdwLocStatement = c.prepareStatement("SELECT Hardware.lsstId, Hardware.id, Hardware.creationTS,"
                        + " Hardware.hardwareTypeId, Location.name, Site.name AS sname, "
                        + "HardwareLocationHistory.locationId from Hardware, HardwareLocationHistory, Location, Site "
                        + "where Hardware.id=HardwareLocationHistory.hardwareId and Location.id = HardwareLocationHistory.locationId and Location.siteId = Site.id "
                        + "and Hardware.lsstId=? and (Hardware.hardwareTypeId=? OR Hardware.hardwareTypeId=9 OR Hardware.hardwareTypeId=10) order By HardwareLocationHistory.creationTS DESC");
                hdwLocStatement.setString(1, lsstId);
                hdwLocStatement.setInt(2, Integer.valueOf(hardwareTypeId));
                ResultSet locResult = hdwLocStatement.executeQuery();
                locResult.first();

                // Retrieve most recent Traveler
                TreeMap<Integer, Activity> activityMap = getActivityMap(session, locResult.getInt("id"));
                
                String travelerName = "NA";
                String curActProcName = "NA";
                String curActStatusName = "NA";
                Date curActLastTime = null;
                java.util.Date travStartTime = null;
                int processId = -1;
                boolean found = false;
                Activity a = null;
                // Find the starting activity by searching for the one with index == 0
                // This loop isn't really necessary - since we know the first element in the map is index == 0
                if (activityMap.size() > 0) {
                    Integer lastKey = activityMap.lastKey();
                    a = activityMap.get(lastKey);
                }
                //for (Map.Entry<Integer, Activity> entry : activityMap.entrySet()) {
                //    Activity act = entry.getValue();
                //    if (act.getIndex() == 0) {
                //        a = act;
                //        break;
                //   }
                //}
                if (a != null) {
                    // Starting with this child activity, find the parent activity and the processId
                    curActStatusName = a.getStatusName();
                    //  curActLastTime = a.getEndTime() == null ? a.getBeginTime() : a.getEndTime();
                    PreparedStatement curProcessStatement = c.prepareStatement("SELECT Process.name FROM "
                            + "Process WHERE Process.id=?");
                    curProcessStatement.setInt(1, Integer.valueOf(a.getProcessId()));
                    ResultSet curProcessResult = curProcessStatement.executeQuery();
                    curProcessResult.first();
                    if (curProcessResult != null) {
                        curActProcName = curProcessResult.getString("name");
                    }
                    while (!found) {
                        // Sometimes the last activity has null begin and end times - check to find the most recent 
                        // non-null timestamp
                        // Since we're working with a SortedMap, we know we are iterating on the actvities in reverse order
                        // from most recent to earlier in time
                        if (curActLastTime == null) {
                            curActLastTime = a.getEndTime() == null ? a.getBeginTime() : a.getEndTime();
                        }
                        if (a.isParent()) {
                            found = true;
                            processId = a.getProcessId();
                            travStartTime = a.getBeginTime();
                            break;
                        } else {
                            int actId = a.getParentActivityId();
                            a = activityMap.get(actId);
                            if (a == null) {
                                found = true; // bail out at this point, if we have a null activity
                            }

                        }

                    }
                    PreparedStatement travelerStatement = c.prepareStatement("SELECT Process.name FROM "
                            + "Process WHERE Process.id=?");
                    travelerStatement.setInt(1, Integer.valueOf(processId));
                    ResultSet travelerResult = travelerStatement.executeQuery();
                    travelerResult.first();
                    if (travelerResult != null) {
                        travelerName = travelerResult.getString("name");
                    }
                }

                HdwStatusLoc hsl = new HdwStatusLoc();
                hsl.setValues(locResult.getString("lsstId"), statusResult.getString("name"), locResult.getString("name"),
                        locResult.getString("sname"), locResult.getString("creationTS"),
                        travelerName, curActProcName, curActStatusName, curActLastTime, travStartTime);
                result.add(hsl);

            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (c != null) {
                //Close the connection
                c.close();
            }
        }

        return result;
    }

    //
//    public static Map getHdwGroup(HttpSession session, String lsstId) {
    //   }
}
