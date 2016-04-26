package org.lsst.camera.portal.queries;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.Iterator;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import javax.servlet.ServletException;
import javax.servlet.http.HttpSession;
import org.lsst.camera.portal.data.TravelerStatus;
import org.lsst.camera.portal.data.HardwareStatus;
import org.lsst.camera.portal.data.HdwStatusLoc;
import org.lsst.camera.portal.data.Activity;
import org.lsst.camera.portal.data.TravelerInfo;
import org.lsst.camera.portal.data.ReportData;
import org.lsst.camera.portal.data.TestReportPathData;
import org.lsst.camera.portal.data.ComponentData;
import org.lsst.camera.portal.data.CatalogFileData;
import org.srs.web.base.db.ConnectionManager;

/**
 *
 * @author heather
 */
public class QueryUtils {

    public static Map getHardwareTypes(HttpSession session) throws SQLException, ServletException {
        HashMap<Integer, String> result = new HashMap<>();

        try (Connection c = ConnectionManager.getConnection(session)) {

            PreparedStatement localHardwareTypesStatement = c.prepareStatement("select id, name from HardwareType");
            ResultSet r = localHardwareTypesStatement.executeQuery();
            while (r.next()) {
                result.put(r.getInt("id"), r.getString("name"));
            }
        }
        return result;
    }

    public static String getCCDHardwareTypes(HttpSession session) throws SQLException, ServletException {
        List<Integer> typeList = new ArrayList<>();
        String result = "";

        try (Connection c = ConnectionManager.getConnection(session)) {

            PreparedStatement findGroupStatement = c.prepareStatement("SELECT id, name FROM "
                    + "HardwareGroup WHERE name = 'Generic-CCD'");
            ResultSet r = findGroupStatement.executeQuery();
            while (r.next()) {
                Integer groupId = r.getInt("id");
                PreparedStatement findHdwTypeStatement = c.prepareStatement("SELECT hardwareTypeId FROM "
                        + "HardwareTypeGroupMapping WHERE hardwareGroupId = ?");
                findHdwTypeStatement.setInt(1, groupId);
                ResultSet r2 = findHdwTypeStatement.executeQuery();
                while (r2.next()) {
                    typeList.add(r2.getInt("hardwareTypeId"));
                }
            }
            // Create String to use in Queries
            Iterator<Integer> iterator = typeList.iterator();
            int counter = 0;
            while (iterator.hasNext()) {
                if (counter == 0) {
                    result += "(";
                }
                ++counter;
                result += (iterator.next());
                if (counter == typeList.size()) {
                    result += ")";
                } else {
                    result += ", ";
                }
            }
        }
        return result;
    }

    // Returns all the activities in the Activity Table associated with a HardwareId
    public static TreeMap getActivityMap(HttpSession session, Integer hdwId, Boolean reverseOrder) throws SQLException, ServletException {
        TreeMap<Integer, Activity> activityMap;
        if (reverseOrder) {
            activityMap = new TreeMap<>(Collections.reverseOrder());
        } else {
            activityMap = new TreeMap<>();
        }

        try (Connection c = ConnectionManager.getConnection(session)) {

            PreparedStatement idStatement = c.prepareStatement("SELECT A.id, "
                    + "A.hardwareId, A.processId, A.parentActivityId, ASH.activityStatusId, "
                    + "AFS.name, A.end, A.begin, A.inNCR FROM "
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
                // Use to keep track of order by activity Id
                activityMap.put(r.getInt("id"), new Activity(r.getInt("id"), r.getInt("processId"), parentId, r.getInt("hardwareId"),
                        r.getInt("activityStatusId"), r.getString("name"), r.getTimestamp("begin"), r.getTimestamp("end"),
                        r.getBoolean("inNCR"), index));
                index++;
            }
        }
        return activityMap;
    }

    // Retrieve all the LsstIds of a certain HardwareType
    // Return a Map of id, LsstId
    public static List getComponentList(HttpSession session, Integer hdwType) throws SQLException, ServletException {
        List<ComponentData> result = new ArrayList<>();

        try (Connection c = ConnectionManager.getConnection(session)) {
            String hdwTypeSet = getCCDHardwareTypes(session);
            PreparedStatement idStatement = c.prepareStatement("SELECT Hardware.id,Hardware.lsstId, Hardware.manufacturer, "
                    + "Hardware.creationTS "
                    + "FROM Hardware,HardwareType WHERE Hardware.hardwareTypeId=HardwareType.id and "
                    + "HardwareType.id IN " + hdwTypeSet);
            //idStatement.setInt(1, hdwType);
            ResultSet r = idStatement.executeQuery();
            while (r.next()) {
                ComponentData comp = new ComponentData(r.getString("lsstId"), r.getString("manufacturer"), r.getInt("id"), r.getTimestamp("creationTS"));
                result.add(comp);
            }

        }
        return result;

    }

    // Retrieve all the LsstIds of a certain HardwareType
    // Return a Map of id, LsstId
    public static Map getComponentIds(HttpSession session, Integer hdwType) throws SQLException, ServletException {
        HashMap<Integer, String> result = new HashMap<>();

        try (Connection c = ConnectionManager.getConnection(session)) {
            String hdwTypeSet = getCCDHardwareTypes(session);
            PreparedStatement idStatement = c.prepareStatement("select Hardware.id,Hardware.lsstId "
                    + "from Hardware,HardwareType where Hardware.hardwareTypeId=HardwareType.id and "
                    + "HardwareType.id IN " + hdwTypeSet);
            //idStatement.setInt(1, hdwType);
            ResultSet r = idStatement.executeQuery();
            while (r.next()) {
                result.put(r.getInt("id"), r.getString("lsstId"));
            }

        }
        return result;

    }

    // Retrieve all the LsstIds of a certain HardwareType
    // Return a Map of id, LsstId
    public static Map getFilteredComponentIds(HttpSession session, Integer hdwType, String lsst_num, String manu) throws SQLException, ServletException {
        HashMap<Integer, String> result = new HashMap<>();

        String lower_lsst_num = lsst_num.toLowerCase();
        String lower_manu = manu.toLowerCase();
        try (Connection c = ConnectionManager.getConnection(session)) {
            String hdwTypeSet = getCCDHardwareTypes(session);
            PreparedStatement idStatement;
            if (lower_manu.equals("any")) {
                if (lower_lsst_num.equals("")) {
                    idStatement = c.prepareStatement("SELECT Hardware.id,Hardware.lsstId "
                            + "FROM Hardware,HardwareType WHERE Hardware.hardwareTypeId=HardwareType.id AND "
                            + " HardwareType.id IN " + hdwTypeSet);
                    //idStatement.setInt(1,hdwType);
                } else {
                    idStatement = c.prepareStatement("SELECT Hardware.id,Hardware.lsstId "
                            + "FROM Hardware,HardwareType WHERE Hardware.hardwareTypeId=HardwareType.id AND "
                            + "LOWER(Hardware.lsstId) LIKE concat('%', ?, '%') AND "
                            + "HardwareType.id IN " + hdwTypeSet);
                    idStatement.setString(1, lower_lsst_num);
                    //idStatement.setInt(2, hdwType);
                }
            } else if (lsst_num.equals("")) {
                idStatement = c.prepareStatement("select Hardware.id,Hardware.lsstId "
                        + "FROM Hardware,HardwareType WHERE Hardware.hardwareTypeId=HardwareType.id AND LOWER(Hardware.manufacturer) = ? AND "
                        + "HardwareType.id IN " + hdwTypeSet);
                idStatement.setString(1, lower_manu);
                //idStatement.setInt(2, hdwType);
            } else {
                idStatement = c.prepareStatement("SELECT Hardware.id,Hardware.lsstId "
                        + "FROM Hardware,HardwareType WHERE Hardware.hardwareTypeId=HardwareType.id AND LOWER(Hardware.manufacturer) = ? AND "
                        + "LOWER(Hardware.lsstId) LIKE concat('%', ?, '%') AND "
                        + "HardwareType.id IN " + hdwTypeSet);

                idStatement.setString(1, lower_manu);
                idStatement.setString(2, lower_lsst_num);
                //idStatement.setInt(3, hdwType);
            }

            ResultSet r = idStatement.executeQuery();
            while (r.next()) {
                result.put(r.getInt("id"), r.getString("lsstId"));
            }

        }
        return result;
    }

    public static String getTravelerStatus(TravelerStatus status, String travelerUniqueId) {
        String s = status.getTravelerStatus(travelerUniqueId);
        return s == null || "".equals(s) ? "NA" : s;
    }

    public static List getTravelerStatusTable(HttpSession session, String hardwareTypeId) throws SQLException, ServletException {
        List<TravelerStatus> result = new ArrayList<>();
        Map<String, TravelerStatus> travelerStatusMap = new HashMap<>();
        try (Connection c = ConnectionManager.getConnection(session)) {
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

        }
        return result;
    }

    public static String getHardwareStatus(HardwareStatus status, String travelerUniqueId) {
        String s = status.getHardwareStatus(travelerUniqueId);
        return s == null || "".equals(s) ? "NA" : s;
    }

    public static List getHardwareStatusTable(HttpSession session, String hardwareTypeId, String ccdId) throws SQLException, ServletException {
        List<HardwareStatus> result = new ArrayList<>();
        HardwareStatus status = null;
        try (Connection c = ConnectionManager.getConnection(session)) {

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

        }
        result.add(status);
        return result;
    }

    public static List getHdwStatLocTable(HttpSession session, Integer hardwareTypeId, String lsst_num, String manu) throws SQLException, ServletException {
        List<HdwStatusLoc> result = new ArrayList<>();
        try (Connection c = ConnectionManager.getConnection(session)) {

            Map<Integer, String> compIds = getFilteredComponentIds(session, hardwareTypeId, lsst_num, manu);
            String hdwTypeSet = getCCDHardwareTypes(session);
            for (String lsstId : compIds.values()) { // Loop over all the ccd LSST ids
                // Retrieve list of statuses for this CCD, ordered by creation time, in descending order
                PreparedStatement hdwStatusStatement = c.prepareStatement("SELECT Hardware.lsstId,HardwareStatus.name, "
                        + "HardwareStatusHistory.hardwareStatusId FROM Hardware, HardwareStatusHistory, HardwareStatus "
                        + "WHERE Hardware.id=HardwareStatusHistory.hardwareId and HardwareStatus.id = HardwareStatusHistory.hardwareStatusId "
                        + "AND Hardware.lsstId=? AND "
                        + "Hardware.hardwareTypeId IN " + hdwTypeSet + " ORDER BY HardwareStatusHistory.creationTS DESC");
                hdwStatusStatement.setString(1, lsstId);
                //hdwStatusStatement.setInt(2, Integer.valueOf(hardwareTypeId));

                ResultSet statusResult = hdwStatusStatement.executeQuery();
                statusResult.first();

                // Retrieve the list of locations associated with this CCD, ordered by creation time in descending order
                PreparedStatement hdwLocStatement = c.prepareStatement("SELECT Hardware.lsstId, Hardware.id, Hardware.creationTS,"
                        + " Hardware.hardwareTypeId, Location.name, Site.name AS sname, "
                        + "HardwareLocationHistory.locationId from Hardware, HardwareLocationHistory, Location, Site "
                        + "WHERE Hardware.id=HardwareLocationHistory.hardwareId and Location.id = HardwareLocationHistory.locationId and Location.siteId = Site.id "
                        + "AND Hardware.lsstId=? AND "
                        + "Hardware.hardwareTypeId IN " + hdwTypeSet + " ORDER BY HardwareLocationHistory.creationTS DESC");
                hdwLocStatement.setString(1, lsstId);
                //hdwLocStatement.setInt(2, Integer.valueOf(hardwareTypeId));
                ResultSet locResult = hdwLocStatement.executeQuery();
                locResult.first();

                // Retrieve most recent Traveler
                TreeMap<Integer, Activity> activityMap = getActivityMap(session, locResult.getInt("id"), false);

                String travelerName = "NA";
                String curActProcName = "NA";
                String curActStatusName = "NA";
                Boolean inNCR = false;
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
                    PreparedStatement curProcessStatement = c.prepareStatement("SELECT Process.name, Process.version FROM "
                            + "Process WHERE Process.id=?");
                    curProcessStatement.setInt(1, a.getProcessId());
                    ResultSet curProcessResult = curProcessStatement.executeQuery();
                    curProcessResult.first();
                    curActProcName = curProcessResult.getString("name") + "_v" + curProcessResult.getInt("version");

                    inNCR = a.getInNCR();

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
                    PreparedStatement travelerStatement = c.prepareStatement("SELECT Process.name, Process.version FROM "
                            + "Process WHERE Process.id=?");
                    travelerStatement.setInt(1, processId);
                    ResultSet travelerResult = travelerStatement.executeQuery();
                    travelerResult.first();
                    travelerName = travelerResult.getString("name") + "_v" + travelerResult.getInt("version");
                }

                HdwStatusLoc hsl = new HdwStatusLoc();
                hsl.setValues(locResult.getString("lsstId"), statusResult.getString("name"), locResult.getString("name"),
                        locResult.getString("sname"), locResult.getTimestamp("creationTS"),
                        travelerName, curActProcName, curActStatusName, curActLastTime, travStartTime, inNCR);
                result.add(hsl);

            }

        }
        return result;
    }

    // Return the summary Hardware Status Location for a particule LSST Id
    public static HdwStatusLoc getHdwStatLoc(HttpSession session, String lsstId) throws SQLException, ServletException {
        HdwStatusLoc result = new HdwStatusLoc();

        try (Connection c = ConnectionManager.getConnection(session)) {
            String hdwTypeSet = getCCDHardwareTypes(session);
            //Map<Integer, String> compIds = getComponentIds(session, hardwareTypeId);
            //for (String lsstId : compIds.values()) { // Loop over all the ccd LSST ids
            // Retrieve list of statuses for this CCD, ordered by creation time, in descending order
            PreparedStatement hdwStatusStatement = c.prepareStatement("SELECT Hardware.lsstId,HardwareStatus.name, "
                    + "HardwareStatusHistory.hardwareStatusId from Hardware, HardwareStatusHistory, HardwareStatus "
                    + "WHERE Hardware.id=HardwareStatusHistory.hardwareId and HardwareStatus.id = HardwareStatusHistory.hardwareStatusId "
                    + "AND Hardware.lsstId=? AND "
                    + "Hardware.hardwareTypeId IN " + hdwTypeSet + " ORDER BY HardwareStatusHistory.creationTS DESC");
            hdwStatusStatement.setString(1, lsstId);
            //  hdwStatusStatement.setInt(2, Integer.valueOf(hardwareTypeId));

            ResultSet statusResult = hdwStatusStatement.executeQuery();
            statusResult.first();

            // Retrieve the list of locations associated with this CCD, ordered by creation time in descending order
            PreparedStatement hdwLocStatement = c.prepareStatement("SELECT Hardware.lsstId, Hardware.id, Hardware.creationTS,"
                    + " Hardware.hardwareTypeId, Location.name, Site.name AS sname, "
                    + "HardwareLocationHistory.locationId from Hardware, HardwareLocationHistory, Location, Site "
                    + "WHERE Hardware.id=HardwareLocationHistory.hardwareId and Location.id = HardwareLocationHistory.locationId and Location.siteId = Site.id "
                    + "AND Hardware.lsstId=? AND "
                    + "Hardware.hardwareTypeId IN " + hdwTypeSet + " ORDER BY HardwareLocationHistory.creationTS DESC");
            hdwLocStatement.setString(1, lsstId);
            //hdwLocStatement.setInt(2, Integer.valueOf(hardwareTypeId));
            ResultSet locResult = hdwLocStatement.executeQuery();
            locResult.first();

            // Retrieve most recent Traveler
            TreeMap<Integer, Activity> activityMap = getActivityMap(session, locResult.getInt("id"), false);

            String travelerName = "NA";
            String curActProcName = "NA";
            String curActStatusName = "NA";
            Boolean inNCR = false;
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

            if (a != null) {
                // Starting with this child activity, find the parent activity and the processId
                curActStatusName = a.getStatusName();
                //  curActLastTime = a.getEndTime() == null ? a.getBeginTime() : a.getEndTime();
                PreparedStatement curProcessStatement = c.prepareStatement("SELECT Process.name, Process.version FROM "
                        + "Process WHERE Process.id=?");
                curProcessStatement.setInt(1, a.getProcessId());
                ResultSet curProcessResult = curProcessStatement.executeQuery();
                curProcessResult.first();
                curActProcName = curProcessResult.getString("name") + "_v" + curProcessResult.getInt("version");

                inNCR = a.getInNCR();

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
                PreparedStatement travelerStatement = c.prepareStatement("SELECT Process.name, Process.version FROM "
                        + "Process WHERE Process.id=?");
                travelerStatement.setInt(1, Integer.valueOf(processId));
                ResultSet travelerResult = travelerStatement.executeQuery();
                travelerResult.first();
                travelerName = travelerResult.getString("name") + "_v" + travelerResult.getInt("version");
            }

            result.setValues(locResult.getString("lsstId"), statusResult.getString("name"), locResult.getString("name"),
                    locResult.getString("sname"), locResult.getTimestamp("creationTS"),
                    travelerName, curActProcName, curActStatusName, curActLastTime, travStartTime, inNCR);

        }
        return result;
    }

    public static Integer getTestReportActivityId(HttpSession session, Integer hardwareId) throws SQLException, ServletException {
        List<TravelerInfo> travCol = getTravelerCol(session, hardwareId, true);
        Iterator<TravelerInfo> iterator = travCol.iterator();
        String testReport = "SR-EOT-02";
        while (iterator.hasNext()) {
            TravelerInfo t = iterator.next();
            String name = t.getName();
            if (name.contains(testReport)) {
                return t.getActId();
            }
        }
        return -1;
    }

    public static List getTravelerCol(HttpSession session, Integer hardwareId, Boolean removeDups) throws SQLException, ServletException {
        List<TravelerInfo> result = new ArrayList<>();
        List<Integer> processList = new ArrayList<>();
        try (Connection c = ConnectionManager.getConnection(session)) {

            // Retrieve most recent Traveler
            TreeMap<Integer, Activity> activityMap = getActivityMap(session, hardwareId, true);

            String travelerName = "NA";
            String curActProcName = "NA";
            String curActStatusName = "NA";
            Boolean inNCR = false;
            Date curActLastTime = null;
            java.util.Date travStartTime = null;
            int processId = -1;
            boolean found = false;

            for (Map.Entry<Integer, Activity> entry : activityMap.entrySet()) {
                Activity act = entry.getValue();

                if (act != null) {

                    if (act.isParent()) { // Found a Traveler
                        if (removeDups && processList.contains(act.getProcessId())) {
                            continue;
                        }

                        String travName = null;
                        PreparedStatement travStatement = c.prepareStatement("SELECT Process.name, Process.version, Process.originalId "
                                + "FROM "
                                + "Process WHERE Process.id=?");
                        travStatement.setInt(1, act.getProcessId());
                        ResultSet travResult = travStatement.executeQuery();
                        travResult.first();
                        travName = travResult.getString("name") + "_v" + travResult.getInt("version");
                        TravelerInfo info = new TravelerInfo(travName, act.getActivityId(), act.getHdwId(), act.getStatusId(), act.getStatusName(), act.getBeginTime(), act.getEndTime(), act.getInNCR());
                        processList.add(act.getProcessId());
                        result.add(info);
                    }
                }
            }
        }
        return result;
    }

    public static Boolean doesActivityHaveOutput(HttpSession session, Integer activityId) throws SQLException, ServletException {
        Boolean result = false;

        try (Connection c = ConnectionManager.getConnection(session)) {
            PreparedStatement floatHarnessedStatement = c.prepareStatement("SELECT activityId FROM FloatResultHarnessed "
                    + "WHERE activityId=?");
            floatHarnessedStatement.setInt(1, activityId);
            ResultSet floatHResult = floatHarnessedStatement.executeQuery();
            if (floatHResult.next()) {
                return true;
            }
            PreparedStatement intHarnessedStatement = c.prepareStatement("SELECT activityId FROM IntResultHarnessed "
                    + "WHERE activityId=?");
            intHarnessedStatement.setInt(1, activityId);
            ResultSet intHResult = intHarnessedStatement.executeQuery();
            if (intHResult.next()) {
                return true;
            }
            PreparedStatement fileHarnessedStatement = c.prepareStatement("SELECT activityId FROM FilepathResultHarnessed "
                    + "WHERE activityId=?");
            fileHarnessedStatement.setInt(1, activityId);
            ResultSet fileHResult = fileHarnessedStatement.executeQuery();
            if (fileHResult.next()) {
                return true;
            }
            PreparedStatement fileManualStatement = c.prepareStatement("SELECT activityId FROM FilepathResultManual "
                    + "WHERE activityId=?");
            fileManualStatement.setInt(1, activityId);
            ResultSet fileMResult = fileManualStatement.executeQuery();
            if (fileMResult.next()) {
                return true;
            }
            PreparedStatement floatManualStatement = c.prepareStatement("SELECT activityId FROM FloatResultManual "
                    + "WHERE activityId=?");
            floatManualStatement.setInt(1, activityId);
            ResultSet floatMResult = floatManualStatement.executeQuery();
            if (floatMResult.next()) {
                return true;
            }
            PreparedStatement intManualStatement = c.prepareStatement("SELECT activityId FROM InttResultManual "
                    + "WHERE activityId=?");
            intManualStatement.setInt(1, activityId);
            ResultSet intMResult = intManualStatement.executeQuery();
            if (intMResult.next()) {
                return true;
            }
        }
        return result;
    }

    public static List getOutputActivityFromTraveler(HttpSession session, List travelerList, String travName, String actName, Integer hdwId) throws SQLException, ServletException {
        List<Integer> result = new ArrayList<>();
        // Find all travelers with this name "actName"
        Iterator<TravelerInfo> iterator = travelerList.iterator();
        while (iterator.hasNext()) {
            TravelerInfo t = iterator.next();
            String name = t.getName();
            if (name.contains(travName)) {
                List<Integer> curActList = getActivitiesForTraveler(session, t.getActId(), hdwId);
                result.addAll(getOutputActivityId(session, curActList, actName));
            }
        }
        return result;
    }

    public static List getOutputActivityId(HttpSession session, List actList, String actName) throws SQLException, ServletException {
        List<Integer> result = new ArrayList<>();
        try (Connection c = ConnectionManager.getConnection(session)) {
            // Create String to use in Queries
            Iterator<Integer> iterator = actList.iterator();
            int counter = 0;
            String str = "";
            while (iterator.hasNext()) {
                if (counter == 0) {
                    str += "(";
                }
                ++counter;
                str += (iterator.next());
                if (counter == actList.size()) {
                    str += ")";
                } else {
                    str += ", ";
                }
            }
            // Search for all processes with the name "vendorIngest" that ended with a final status of Success (1)
            PreparedStatement vendorIngestStatement = c.prepareStatement("SELECT Activity.id FROM Activity "
                    + "INNER JOIN Process ON Activity.processId = Process.id "
                    + "INNER JOIN ActivityStatusHistory ASH ON Activity.id = ASH.activityId "
                    + "AND ASH.id=(select max(id) FROM ActivityStatusHistory WHERE activityId=Activity.id) "
                    + "INNER JOIN ActivityFinalStatus AFS ON AFS.id=ASH.activityStatusId "
                    + "WHERE Activity.Id IN " + str + " AND Process.name LIKE ? "
                    + "AND ASH.activityStatusId = 1 ORDER BY Activity.id DESC");
            vendorIngestStatement.setString(1, actName);

            ResultSet vendorIngestResult = vendorIngestStatement.executeQuery();
            while (vendorIngestResult.next()) {
                result.add(vendorIngestResult.getInt("Activity.id"));
            }
        }
        return result;
    }

    public static Set getActivityListWithOutput(HttpSession session, List actList) throws SQLException, ServletException {
        Set<Integer> result = new LinkedHashSet();
        try (Connection c = ConnectionManager.getConnection(session)) {
            // Create String to use in Queries
            Iterator<Integer> iterator = actList.iterator();
            int counter = 0;
            String str = "";
            while (iterator.hasNext()) {
                if (counter == 0) {
                    str += "(";
                }
                ++counter;
                str += (iterator.next());
                if (counter == actList.size()) {
                    str += ")";
                } else {
                    str += ", ";
                }
            }

            PreparedStatement floatHarnessedStatement = c.prepareStatement("SELECT activityId FROM FloatResultHarnessed "
                    + "WHERE activityId IN " + str);
            ResultSet floatHResult = floatHarnessedStatement.executeQuery();
            while (floatHResult.next()) {
                result.add(floatHResult.getInt("activityId"));
            }

            PreparedStatement intHarnessedStatement = c.prepareStatement("SELECT activityId FROM IntResultHarnessed "
                    + "WHERE activityId IN " + str);
            ResultSet intHResult = intHarnessedStatement.executeQuery();
            while (intHResult.next()) {
                result.add(intHResult.getInt("activityId"));
            }

            PreparedStatement fileHarnessedStatement = c.prepareStatement("SELECT activityId FROM FilepathResultHarnessed "
                    + "WHERE activityId IN " + str);
            ResultSet fileHResult = fileHarnessedStatement.executeQuery();
            while (fileHResult.next()) {
                result.add(fileHResult.getInt("activityId"));
            }

            PreparedStatement fileManualStatement = c.prepareStatement("SELECT activityId FROM FilepathResultManual "
                    + "WHERE activityId IN " + str);
            ResultSet fileMResult = fileManualStatement.executeQuery();
            while (fileMResult.next()) {
                result.add(fileMResult.getInt("activityId"));
            }

            PreparedStatement floatManualStatement = c.prepareStatement("SELECT activityId FROM FloatResultManual "
                    + "WHERE activityId IN " + str);
            ResultSet floatMResult = floatManualStatement.executeQuery();
            while (floatMResult.next()) {
                result.add(floatMResult.getInt("activityId"));
            }

            PreparedStatement intManualStatement = c.prepareStatement("SELECT activityId FROM IntResultManual "
                    + "WHERE activityId IN " + str);
            ResultSet intMResult = intManualStatement.executeQuery();
            while (intMResult.next()) {
                result.add(intMResult.getInt("activityId"));
            }

            PreparedStatement stringManualStatement = c.prepareStatement("SELECT activityId FROM stringResultManual "
                    + "WHERE activityId IN " + str);
            ResultSet stringMResult = stringManualStatement.executeQuery();
            while (stringMResult.next()) {
                result.add(stringMResult.getInt("activityId"));
            }

            PreparedStatement stringHarnessedStatement = c.prepareStatement("SELECT activityId FROM stringResultHarnessed "
                    + "WHERE activityId IN " + str);
            ResultSet stringHResult = stringHarnessedStatement.executeQuery();
            while (stringHResult.next()) {
                result.add(stringHResult.getInt("activityId"));
            }
        }

        return result;
    }

    public static List getActivitiesForTraveler(HttpSession session, Integer travelerActId, Integer hardwareId) throws SQLException, ServletException {
        List<Integer> result = new ArrayList<>();

        try (Connection c = ConnectionManager.getConnection(session)) {

            TreeMap<Integer, Activity> activityMap = getActivityMap(session, hardwareId, false);
            // Loop to match all activities to the appropriate Traveler
            for (Map.Entry<Integer, Activity> activity : activityMap.entrySet()) {
                Activity act = activity.getValue();
                Integer childActivityId = act.getActivityId();
                //java.util.Date childBeginTime = act.getBeginTime();

                if (act != null) {
                    // Find the parent traveler of this activity
                    boolean found = false;
                    while (!found) {
                        if (act.isParent()) {
                            found = true;
                            int curActivityId = act.getActivityId();
                            if (curActivityId == travelerActId) {
                                //               result.put(childActivityId, childBeginTime)
                                result.add(childActivityId);
                            }
                            break;
                        } else { // otherwise keep searching
                            int actId = act.getParentActivityId();
                            act = activityMap.get(actId);
                            if (act == null) {
                                found = true; // bail out at this point, if we have a null activity
                            }

                        }
                    }

                }
            }

        }
        return result;
    }

    public static String intListToString(List<Integer> intList) {
        String result = "";
        Iterator<Integer> iterator = intList.iterator();
        int counter = 0;
        while (iterator.hasNext()) {
            if (counter == 0) {
                result += "(";
            }
            result += (iterator.next());
            ++counter;

            if (counter == intList.size()) {
                result += ")";
            } else {
                result += ", ";
            }
        }
        return result;
    }

    public static List getReportsTable(HttpSession session, Integer hardwareTypeId, String dataSourceFolder, Boolean removeDups) throws SQLException, ServletException {
        List<ReportData> result = new ArrayList<>();

        try (Connection c = ConnectionManager.getConnection(session)) {

            // Need to ignore vendor data before August 4, 2015 due to change in DC organization
            java.util.Calendar cal = new java.util.GregorianCalendar();
            cal.set(Calendar.YEAR, 2015);
            cal.set(Calendar.MONTH, 7); // 7 == August
            cal.set(Calendar.DAY_OF_MONTH, 4);
            long millisecond = cal.getTimeInMillis();
            java.util.Date goodVendorDataPathDate = new java.util.Date(millisecond);

            // List of Sensors
            List<ComponentData> compIds = getComponentList(session, hardwareTypeId);
            Iterator<ComponentData> compIt = compIds.iterator();
            while (compIt.hasNext()) { // iterate over sensors
                Boolean hasVendorData = false;
                Boolean hasOfflineData = false;
                Boolean hasOnlineData = false;

                ComponentData comp = compIt.next();
                String lsst_num = comp.getLsst_num();
                Integer hdwId = comp.getHdwId();
                java.util.Date registrationDate = comp.getRegistrationDate();
                if (registrationDate.compareTo(goodVendorDataPathDate) < 0) {
                    continue;
                }

                List<TravelerInfo> travelerList = getTravelerCol(session, hdwId, removeDups);

                // Find Vendor Data
                List<Integer> vendActList = getOutputActivityFromTraveler(session,
                        travelerList, "SR-RCV-1", "vendorIngest", hdwId);

                Iterator<Integer> vendAct = vendActList.iterator();

                // Find Offline Test Reports
                List<Integer> offlineTestRepList = getOutputActivityFromTraveler(session,
                        travelerList, "SR-EOT-02", "test_report_offline", hdwId);

                List<TestReportPathData> reportPaths = getTestReportPaths(session, offlineTestRepList, true);

                // Find Online Test Reports
                List<Integer> onlineTestRepList = getOutputActivityFromTraveler(session,
                        travelerList, "SR-EOT-1", "test_report", hdwId);
                List<TestReportPathData> onlineReportPaths = getTestReportPaths(session, onlineTestRepList, true);

                if (vendAct.hasNext()) {
                    hasVendorData = true;
                }
                Iterator<TestReportPathData> offlineReportIter = reportPaths.iterator();
                Iterator<TestReportPathData> onlineReportIter = onlineReportPaths.iterator();
                if (reportPaths.size() > 0) {
                    hasOfflineData = true;
                }
                if (onlineReportPaths.size() > 0) {
                    hasOnlineData = true;
                }

                ReportData repData = null;
                if (hasVendorData || hasOfflineData || hasOnlineData) {
                    repData = new ReportData(lsst_num, registrationDate);
                }

                if (hasVendorData) { // first in the list should be most recent
                    Integer act = (vendAct.next());
                    String vendPath = "/LSST/vendorData/";
                    vendPath += comp.getManufacturer() + "/" + lsst_num + "/" + dataSourceFolder + "/" + act;
                    repData.setVendDataPath(vendPath);
                }
                if (hasOfflineData) {
                    TestReportPathData offlineData = offlineReportIter.next();
                    repData.setOfflineReportCatKey((offlineData.getCatalogKey()));
                    repData.setTestReportOfflinePath(offlineData.getTestReportPath());
                    repData.setTestReportOfflineDirPath(offlineData.getTestReportDirPath());
                    if (offlineReportIter.hasNext()) {
                        repData.setOfflineReportCol(reportPaths);
                    }
                }
                if (hasOnlineData) {
                    TestReportPathData onlineData = onlineReportIter.next();
                    repData.setOnlineReportCatKey(onlineData.getCatalogKey());
                    repData.setTestReportOnlinePath(onlineData.getTestReportPath());
                    repData.setTestReportOnlineDirPath(onlineData.getTestReportDirPath());
                    if (onlineReportIter.hasNext()) {
                        repData.setOnlineReportCol(onlineReportPaths);
                    }
                }

                if (repData != null) {
                    result.add(repData);
                }

            }

        } 
        return result;
    }

    public static List getTestReportPaths(HttpSession session, List<Integer> actIdList, Boolean getAll) throws SQLException, ServletException {
        List<TestReportPathData> result = new ArrayList<>();
        //TestReportPathData result = new TestReportPathData();
        try (Connection c = ConnectionManager.getConnection(session)) {
            Integer mostRecentTestReport = Collections.max(actIdList, null);
            ResultSet r;
            if (getAll == false) { // retrieve only the most recent
                // Pull out the most recent PDF associated with this activity ID
                PreparedStatement fileStatement = c.prepareStatement("SELECT virtualPath, "
                        + "catalogKey, creationTS FROM "
                        + "FilepathResultHarnessed "
                        + "WHERE activityId=? AND virtualPath LIKE concat('%', 'pdf', '%') "
                        + "ORDER BY creationTS DESC");
                fileStatement.setInt(1, mostRecentTestReport);
                r = fileStatement.executeQuery();
            } else { // getAll == true
                String actString = intListToString(actIdList);
                PreparedStatement fileStatement = c.prepareStatement("SELECT virtualPath, "
                        + "catalogKey, creationTS FROM "
                        + "FilepathResultHarnessed "
                        + "WHERE activityId IN " + actString + " AND virtualPath LIKE concat('%', 'pdf', '%') "
                        + "ORDER BY creationTS DESC");
                r = fileStatement.executeQuery();
            }
            Boolean DONE = false;
            while (r.next() && !DONE) {
                TestReportPathData reportData = new TestReportPathData();
                String vPath = r.getString("virtualPath");
                java.util.Date creation = r.getTimestamp("creationTS");
                Integer lastSlash = vPath.lastIndexOf('/');
                String dirPath = vPath.substring(0, lastSlash);
                Integer catKey = r.getInt("catalogKey");
                reportData.setValues("", creation, mostRecentTestReport, catKey, vPath, dirPath);
                result.add(reportData);
                if (getAll == false) {
                    DONE = true;
                }
            }

        } 
        return result;
    }

    public static List getDataCatalogFiles(HttpSession session, String fileSearchStr, String doRegex) throws SQLException, ServletException {
        List<CatalogFileData> result = new ArrayList<>();
        String lower_fileSearchStr = fileSearchStr.toLowerCase();
        try (Connection c = ConnectionManager.getConnection(session)) {

            PreparedStatement idStatement;
            if ((doRegex.equals("false")) || (doRegex == null)) {
                idStatement = c.prepareStatement("(SELECT activityId, virtualPath, createdBy, "
                        + "catalogKey, creationTS "
                        + "FROM FilepathResultHarnessed WHERE LOWER(virtualPath) LIKE concat('%', ?, '%')) "
                        + "UNION "
                        + "(SELECT activityId, virtualPath, createdBy, "
                        + "catalogKey, creationTS "
                        + "FROM FilepathResultManual WHERE LOWER(virtualPath) LIKE concat('%', ?, '%')) "
                        + "ORDER BY activityId DESC");
            } else {
                idStatement = c.prepareStatement("(SELECT activityId, virtualPath, createdBy, "
                        + "catalogKey, creationTS "
                        + "FROM FilepathResultHarnessed WHERE LOWER(virtualPath) REGEXP ?) "
                        + "UNION "
                        + "(SELECT activityId, virtualPath, createdBy, "
                        + "catalogKey, creationTS "
                        + "FROM FilepathResultManual WHERE LOWER(virtualPath) REGEXP ?) "
                        + "ORDER BY activityId DESC");
            }
            idStatement.setString(1, lower_fileSearchStr);
            idStatement.setString(2, lower_fileSearchStr);
            ResultSet r = idStatement.executeQuery();
            while (r.next()) {
                CatalogFileData comp = new CatalogFileData(r.getInt("activityId"), r.getTimestamp("creationTS"), r.getString("virtualPath"), r.getInt("catalogKey"), r.getString("createdBy"));
                result.add(comp);
            }

        } 
        return result;
    }
}
