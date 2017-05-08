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
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Iterator;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.Objects;
import javax.servlet.ServletException;
import javax.servlet.http.HttpSession;
import org.lsst.camera.portal.data.SensorSummary;
import org.lsst.camera.portal.queries.eTApi;
import org.lsst.camera.portal.queries.QueryUtils;
import org.lsst.camera.portal.data.ComponentData;
import org.lsst.camera.portal.data.SensorAcceptanceData;
import org.lsst.camera.portal.data.TravelerInfo;

/*import org.lsst.camera.portal.data.TravelerStatus;
 import org.lsst.camera.portal.data.HardwareStatus;
 import org.lsst.camera.portal.data.HdwStatusLoc;
 import org.lsst.camera.portal.data.HdwStatusRelationship;
 import org.lsst.camera.portal.data.Activity;
 import org.lsst.camera.portal.data.NcrData;
 import org.lsst.camera.portal.data.TravelerInfo;
 import org.lsst.camera.portal.data.ReportData;
 import org.lsst.camera.portal.data.TestReportPathData;
 import org.lsst.camera.portal.data.ComponentData;
 import org.lsst.camera.portal.data.CatalogFileData;
 import org.lsst.camera.portal.data.SensorAcceptanceData;
 */
import org.srs.web.base.db.ConnectionManager;

/**
 *
 * @author heather
 */
public class SensorUtils {

    public static Map getAllUsingStepAndSchema(String hdwType, String traveler, String db, String step, String schema, Boolean prodServer) {
        Map<String, Object> result = null;
        try {
            result = eTApi.getResultsJH_schema(db, prodServer, traveler, hdwType, step, schema, null);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
        return result;
    }

    public static ArrayList< Map<String, Object>> extractSchema(Map<String, Object> data, String lsstNum, String step, String schema) {
        try {
            //HashMap<String, Object> sensorResults = (HashMap<String, Object>) data.get(lsstNum);
            HashMap<String, Object> allStepMap = (HashMap<String, Object>) data.get("steps");
            HashMap<String, Object> singleStepMap = (HashMap<String, Object>) allStepMap.get(step);
            ArrayList< Map<String, Object>> schemaMap = (ArrayList< Map<String, Object>>) singleStepMap.get(schema);
            return schemaMap;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static HashMap getMaxReadNoiseChannel(String lsstNum, String hdwType, String traveler, String db) {
        HashMap<Integer, Double> result = new HashMap<>();
        try {
            Boolean prodServer = false;
            Map<String, Object> eTresult = eTApi.getResultsJH_schema(db, prodServer, traveler, hdwType, "read_noise", "read_noise", lsstNum);
            HashMap<String, Object> sensorResults = (HashMap<String, Object>) eTresult.get(lsstNum);

            HashMap<String, Object> stepMap = (HashMap<String, Object>) sensorResults.get("steps");
            HashMap<String, Object> readNoiseStep = (HashMap<String, Object>) stepMap.get("read_noise");
            //HashMap<String, Object> readNoiseSchema = (HashMap<String, Object>) readNoiseStep.get("read_noise");
            ArrayList< Map<String, Object>> readNoiseSchema = (ArrayList< Map<String, Object>>) readNoiseStep.get("read_noise");
            double max_read_noise = 0.0f;
            int max_amp = 0;
            for (Object obj : readNoiseSchema) {
                Map<String, Object> m = (Map<String, Object>) obj;
                if ((Integer) m.get("schemaInstance") == 0) {
                    continue;
                }
                Double read_noise = (Double) m.get("read_noise");
                Integer amp = (Integer) m.get("amp");
                if (read_noise > max_read_noise) {
                    max_read_noise = read_noise;
                    max_amp = amp;
                }

            }
            result.put(max_amp, max_read_noise);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
        return result;
    }

    public static List getSensorSummaryTable(HttpSession session, String db) throws SQLException {
        List<SensorSummary> result = new ArrayList<>();
        //HashMap<Integer, Boolean> sensorsFound = new HashMap<>();

        Boolean prodServer = true;
        Connection c = null;
        try {
            //List<ComponentData> sensorList = QueryUtils.getComponentList(session, "Generic-CCD");
            List<String> hardwareTypesList = QueryUtils.getHardwareTypesListFromGroup(session, "Generic-CCD");

            //c = ConnectionManager.getConnection(session);
            DecimalFormat df = new DecimalFormat("##.#");

            Map<String, Object> allJhData = new HashMap<String,Object>();
            Iterator<String> iterator = hardwareTypesList.iterator();
            while (iterator.hasNext()) { // loop over all the hardware types and retrieve their JH data for all sensors
                String hdwType = iterator.next();
                Map<String, Object> curJhData = getAllUsingStepAndSchema(hdwType, "SR-EOT-1", db, "read_noise", "read_noise", prodServer);
                if (curJhData != null) {
                    allJhData.putAll(curJhData);
                }
            }
            // Loop over all the sensors with read_noise data
            for (Map.Entry<String, Object> entry : allJhData.entrySet()) {
 
                ArrayList< Map<String, Object>> curSchema = extractSchema((Map<String,Object>)entry.getValue(),entry.getKey(),"read_noise","read_noise");
                double max_read_noise = 0.0d;
                int max_amp = 0;
                for (Object obj : curSchema) {
                    Map<String, Object> m = (Map<String, Object>) obj;
                    if ((Integer) m.get("schemaInstance") == 0) {
                        continue;
                    }
                    Double read_noise = (Double) m.get("read_noise");
                    Integer amp = (Integer) m.get("amp");
                    if (read_noise > max_read_noise) {
                        max_read_noise = read_noise;
                        max_amp = amp;
                    }

                }
                SensorSummary sensorData = new SensorSummary();
                sensorData.setLsstId(entry.getKey());
                sensorData.setMaxReadNoiseChannel(max_amp);
                sensorData.setMaxReadNoise(Double.parseDouble(df.format(max_read_noise)));
                result.add(sensorData);
            }

            return result;

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

}
