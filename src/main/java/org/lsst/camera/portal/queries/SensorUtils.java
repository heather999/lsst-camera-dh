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
import java.util.Arrays;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.http.HttpSession;
import org.apache.commons.jexl3.JexlBuilder;
import org.apache.commons.jexl3.JexlEngine;
import org.lsst.camera.portal.data.SensorSummary;
import org.lsst.camera.portal.queries.eTApi;
import org.lsst.camera.portal.queries.QueryUtils;
import org.lsst.camera.portal.queries.SummaryUtils;
import org.lsst.camera.portal.data.ComponentData;
import org.lsst.camera.portal.data.SensorAcceptanceData;
import org.lsst.camera.portal.data.TravelerInfo;

import org.srs.web.base.db.ConnectionManager;

/**
 *
 * @author heather
 */
public class SensorUtils {
    
    private static final Logger logger = Logger.getLogger(SensorUtils.class.getName());
    
    public static String getHardwareTypeFromId(HttpSession session, String lsstNum)  throws SQLException {
        Connection c = null;

        try {
            c = ConnectionManager.getConnection(session);

            PreparedStatement idStatement = c.prepareStatement("SELECT HT.name FROM "
                    + "Hardware H INNER JOIN HardwareType HT ON H.hardwareTypeId = HT.id "
                    + "WHERE H.lsstId=?");
            idStatement.setString(1, lsstNum);
            ResultSet r = idStatement.executeQuery();
            if (r.first()) 
                return r.getString("name").toUpperCase();
            else
                return null;
        } catch(Exception e) {            
            return null;
        } finally {
            if (c != null) {
                c.close();
            }
           
        }
    }
    
    public static String getEoTestVersion(HttpSession session, String traveler, String step, String lsstNum, String db, Boolean prodServer) {
        String str = null;
        Map<String, Object> result = null;
        String schema = "package_versions";
        try {
            String hdwType = getHardwareTypeFromId(session, lsstNum);
            if (hdwType == null) {
                return null;
            }
            result = eTApi.getResultsJH_schema(db, prodServer, traveler, hdwType, step, schema, lsstNum);
            ArrayList< Map<String, Object>> schemaMap = extractSchema(result, lsstNum, step, schema);
            for (Object obj : schemaMap) {
                Map<String, Object> m = (Map<String, Object>) obj;
                if ((Integer) m.get("schemaInstance") == 0) {
                    continue;
                }
                            // The format changed, so check for both
                if ((str = (String)m.get("eotest_version")) != null)
                    return str;
                else if (m.get("eotest") != null) {
                    return ((String) m.get("version"));
                }
            }
        } catch (Exception e) {
            return null;
        }
        return str;
    }

    public static Map getAllUsingStepAndSchema(String hdwType, String traveler, String db, String step, String schema, Boolean prodServer) {
        Map<String, Object> result = null;
        try {
            result = eTApi.getResultsJH_schema(db, prodServer, traveler, hdwType, step, schema, null);
            
        } catch (Exception e) {
            return null;
        }
        return result;
    }

    public static ArrayList< Map<String, Object>> extractSchema(Map<String, Object> data, String lsstNum, String step, String schema) {
        try {
            if (data == null) return null;
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
            return null;
        }
        return result;
    }
    
    public static Integer getTotalTestsPassed(HttpSession session, Map<String, Map<String, List<Object>>> theMap, Specifications specs) {
        Integer numTestsPassed = 0;

        Integer reportId = 1;
        // Make a list of all specs we want to extract
        List<String> ourSpecs = Arrays.asList("CCD-007", "CCD-008", "CCD-009", "CCD-010", "CCD-011", "CCD-012",
                "CCD-014", "CCD-021", "CCD-022", "CCD-023", "CCD-024", "CCD-025", "CCD-026", "CCD-027", "CCD-028");

        Iterator<String> specIterator = ourSpecs.iterator();
        while (specIterator.hasNext()) {
            String curSpec = specIterator.next();
            try {
                boolean ok = (boolean) JexlUtils.jexlEvaluateData(theMap, specs.getStatusExpression(curSpec));
                if (ok) {
                    ++numTestsPassed;
                }
            } catch (Exception e) { // if we cannot evaluate this data, skip and carry on
                logger.log(Level.WARNING, "**Error while evaluating spec " + curSpec, e);
            }

        }

        return numTestsPassed;

    }

    public static String getPercentDefects(HttpSession session, Map<String, Map<String, List<Object>>> theMap, Specifications specs) throws SQLException {
        String percentDefects = "";
        String ccd012 = "CCD-012";
        try {
            percentDefects = (String) JexlUtils.jexlEvaluateData(theMap, specs.getFormattedValueExpression(ccd012));
        } catch (Exception e) {
            return "NA";
        }
        String truncStr = percentDefects.replace("defective pixels: ","");
        return truncStr;

    }
    
    public static Integer getWorstCTI(ArrayList< Map<String, Object>> data, String schemaLow, String schemaHigh) {  // charge inefficiency
        Integer worstChannel = -999;
        if (data == null) {
            return worstChannel;
        }
        Double max_cti = Double.NEGATIVE_INFINITY;
        for (Object obj : data) {
            Map<String, Object> m = (Map<String, Object>) obj;
            if ((Integer) m.get("schemaInstance") == 0) {
                continue;
            }
            Double ctiLow = (Double) m.get(schemaLow);
            Double ctiHigh = (Double) m.get(schemaHigh);
            Integer amp = (Integer) m.get("amp");
            if (ctiLow > max_cti) {
                max_cti = ctiLow;
                worstChannel = amp;
            } else if (ctiHigh > max_cti) {
                max_cti = ctiHigh;
                worstChannel = amp;
            }

        }

        return worstChannel;

        
    }

    public static List getSensorSummaryTable(HttpSession session, String db) throws SQLException {
        List<SensorSummary> result = new ArrayList<>();
        //HashMap<Integer, Boolean> sensorsFound = new HashMap<>();

        Boolean prodServer = true;
        Connection c = null;
        try {
            c = ConnectionManager.getConnection(session);
            //List<ComponentData> sensorList = QueryUtils.getComponentList(session, "Generic-CCD");
            List<String> hardwareTypesList = QueryUtils.getHardwareTypesListFromGroup(session, "Generic-CCD");

            int reportId = 1;
            Specifications specs = SummaryUtils.getSpecifications(session, reportId);

            //c = ConnectionManager.getConnection(session);
            DecimalFormat df = new DecimalFormat("##.#");

            Map<String, Object> allReadNoiseJhData = new HashMap<String, Object>();
            Map<String, Object> allCteJhData = new HashMap<String, Object>();

            Iterator<String> iterator = hardwareTypesList.iterator();
            while (iterator.hasNext()) { // loop over all the hardware types and retrieve their JH data for all sensors
                String hdwType = iterator.next();
                Map<String, Object> curReadNoiseJhData = getAllUsingStepAndSchema(hdwType, "SR-EOT-1", db, "read_noise", "read_noise", prodServer);
                if (curReadNoiseJhData != null) {
                    allReadNoiseJhData.putAll(curReadNoiseJhData);
                }
                Map<String, Object> curCteJhData = getAllUsingStepAndSchema(hdwType, "SR-EOT-1", db, "cte", "cte", prodServer);
                if (curCteJhData != null) {
                    allCteJhData.putAll(curCteJhData);
                }
            }
            // Loop over all the sensors with read_noise data
            for (Map.Entry<String, Object> entry : allReadNoiseJhData.entrySet()) {
 
                // Pull out CTE data if available
                Map<String,Object> curCte = (Map<String,Object>)allCteJhData.get(entry.getKey());;
                Integer hid = (Integer) curCte.get("hid");
                ArrayList< Map<String, Object>> curCteSchema = extractSchema((Map<String,Object>)allCteJhData.get(entry.getKey()),entry.getKey(),"cte","cte");
                Integer worstHCTIChannel = getWorstCTI(curCteSchema, "cti_low_serial", "cti_high_serial");
                Integer worstVCTIChannel = getWorstCTI(curCteSchema, "cti_low_parallel", "cti_high_parallel");

                
                Integer parentActId = 0;
                ArrayList< Map<String, Object>> curSchema = extractSchema((Map<String,Object>)entry.getValue(),entry.getKey(),"read_noise","read_noise");
                double max_read_noise = 0.0d;
                int max_amp = 0;
                for (Object obj : curSchema) {
                    Map<String, Object> m = (Map<String, Object>) obj;
                    if ((Integer) m.get("schemaInstance") == 0) {
                        continue;
                    }
                    parentActId = (Integer) m.get("activityId");
                    Double read_noise = (Double) m.get("read_noise");
                    Integer amp = (Integer) m.get("amp");
                    if (read_noise > max_read_noise) {
                        max_read_noise = read_noise;
                        max_amp = amp;
                    }

                }
                // Use the parentActId to extract the results of all the eotest specs and get a count
                int numTestsPassed = -999;
                String percentDefects = "NA";
                int actIdForSpecs = 0;
                if (parentActId > 0) {
                    PreparedStatement parentActIdS = c.prepareStatement("select parentActivityId FROM Activity WHERE id=?");
                    parentActIdS.setInt(1, parentActId);
                    ResultSet r = parentActIdS.executeQuery();
                    if (r.first()) {
                        actIdForSpecs = r.getInt("parentActivityId");
                    } 
                    Map<String, Map<String, List<Object>>> theMap = SummaryUtils.getReportValues(session, actIdForSpecs, reportId);
 
                    numTestsPassed = getTotalTestsPassed(session, theMap, specs);
                    percentDefects = getPercentDefects(session, theMap, specs);
                }
                
                SensorSummary sensorData = new SensorSummary();
                sensorData.setLsstId(entry.getKey());
                sensorData.setHardwareId(hid);
                sensorData.setMaxReadNoiseChannel(max_amp);
                sensorData.setMaxReadNoise(Double.parseDouble(df.format(max_read_noise)));
                sensorData.setNumTestsPassed(numTestsPassed);
                sensorData.setPercentDefects(percentDefects);
                sensorData.setWorstHCTIChannel(worstHCTIChannel);
                sensorData.setWorstVCTIChannel(worstVCTIChannel);
                result.add(sensorData);
            }

            return result;

        } catch (Exception e) {
              logger.log(Level.WARNING, "**Error while creating Sensor Summary Table: ", e);
        } finally {
            if (c != null) {
                //Close the connection
                c.close();
            }
        }

        return result;
    }

}
