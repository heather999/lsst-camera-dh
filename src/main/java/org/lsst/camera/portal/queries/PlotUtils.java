/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.lsst.camera.portal.queries;

import com.fasterxml.jackson.annotation.JsonInclude.Include;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.concurrent.TimeUnit;
import java.util.Iterator;
import java.util.HashMap;
import java.util.TreeSet;
import java.util.SortedSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.HashSet;
import java.util.Arrays;

import org.lsst.camera.portal.data.PlotObject;
import org.lsst.camera.portal.data.PlotData;
import org.lsst.camera.portal.data.PlotXYObject;
import org.lsst.camera.portal.data.PlotXYData;


import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.SortedMap;
import java.util.TreeMap;

/*
import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonSerializer;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializerProvider;
import com.fasterxml.jackson.databind.module.SimpleModule;
*/
/**
 *
 * @author heather
 */
public class PlotUtils {

    // private final ObjectMapper mapper = new ObjectMapper();
    DateFormat df2 = new SimpleDateFormat("yyyy-MM-dd'T'kk:mm:ss.S");
    
    static ObjectMapper mapper = new ObjectMapper();


    public static long timeDiff(Date begin, Date end) {
        TimeUnit myTime = TimeUnit.MILLISECONDS;
        long milli = end.getTime() - begin.getTime();
        long days = myTime.toDays(milli);
        if (days < 0) {
            System.out.println("days " + days + " begin: " + begin + " end: " + end);
        }
        return days;
    }

    public static String stringFromList(List<Integer> theList) {
        String result = "";
        if (theList.isEmpty()) {
            return (""); // If no items, return empty string
        }
        Iterator<Integer> iterator = theList.iterator();
        int counter = 0;
        while (iterator.hasNext()) {
            if (counter == 0) {
                result += "[";
            }
            ++counter;
            result += (iterator.next());
            if (counter == theList.size()) {
                result += "]";
            } else {
                result += ", ";
            }
        }
        return result;
    }

    public static String getSensorArrival(String hdwType, String db) {
        String result;
        PlotObject d = new PlotObject();
        d.getLayout().setTitle("Time between Vendor Data and Receipt at BNL");
        d.getLayout().getXaxis().setTitle("Time Difference (days)");

        d.getData().setType("histogram");
        d.getData().setNbinsx(100);
        //ObjectMapper mapper = new ObjectMapper();
        mapper.setSerializationInclusion(Include.NON_NULL); // NON_EMPTY
        Boolean prodServer = true;
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'kk:mm:ss.S");
        List<Integer> t_diffs = new ArrayList<>();
        try {
            Set<String> labels = new HashSet<>(Arrays.asList("SR_Grade", "SR_Contract"));
            ArrayList<HashMap<String, Object>> hdwInstances = eTApi.getHardwareInstances(hdwType, prodServer, db, labels);
            Iterator hdwIt = hdwInstances.iterator();
            int count_ccd = 0;
            while (hdwIt.hasNext()) {
                String bnlTime = "";
                Boolean found = false;
                HashMap<String, Object> curMap = (HashMap<String, Object>) hdwIt.next();
                String curCcd = (String) curMap.get("experimentSN");
                ArrayList<String> curLabels = (ArrayList<String>) curMap.get("hardwareLabels");
                ++count_ccd;
                // Some sensors were received with SR-RCV-2 and then later it changed to SR-GEN-RCV-02
                Map<Integer, Object> runListOld = eTApi.getComponentRuns(db, hdwType, curCcd, "SR-RCV-2");
                if (runListOld == null) { // Check for other traveler name SR-GEN-RCV-02
                    Map<Integer, Object> runList = eTApi.getComponentRuns(db, hdwType, curCcd, "SR-GEN-RCV-02");
                    if (runList == null) {
                        continue; // skip this ccd entirely
                    }
                    SortedSet<Integer> keys = new TreeSet<>(runList.keySet());
                    for (Integer key : keys) {

                        HashMap<String, Object> travRun = (HashMap<String, Object>) runList.get(key);

                        bnlTime = (String) travRun.get("begin");
                        if (bnlTime.isEmpty()) {
                            continue; // look at the next run
                        } else {
                            found = true;
                            break;
                        }

                    }

                } else { // Found SR-RCV-2 data
                    SortedSet<Integer> keys = new TreeSet<Integer>(runListOld.keySet());
                    for (Integer key : keys) {

                        HashMap<String, Object> travRun = (HashMap<String, Object>) runListOld.get(key);

                        bnlTime = (String) travRun.get("begin");
                        if (bnlTime.isEmpty()) {
                            continue; // look at the next run
                        } else {
                            found = true;
                            break;
                        }

                    }

                }

                if (found) { // we have a BNL arrival, now find Vendor Ingest
                    Date bnlDate = df.parse(bnlTime);
                    Map<Integer, Object> runListCCD = eTApi.getComponentRuns(db, hdwType, curCcd, "SR-RCV-01");
                    if (runListCCD == null) {
                        continue;
                    }
                    // Keys are rootActivityIds, so we want the smallest one, for the first vendor Ingest
                    SortedSet<Integer> keys = new TreeSet<Integer>(runListCCD.keySet());
                    for (Integer key : keys) {

                        HashMap<String, Object> travRun = (HashMap<String, Object>) runListCCD.get(key);

                        String vendorTime = (String) travRun.get("begin");
                        if (vendorTime.isEmpty()) {
                            continue;
                        } else {
                            Date vendorDate = df.parse(vendorTime);
                            Long diffDays = timeDiff(vendorDate, bnlDate);
                            t_diffs.add(diffDays.intValue());
                            d.getData().addX(diffDays.intValue());
                            d.getData().addText(curCcd);
                            break;
                        }
                    }
                }
            }

            // Now we have a list full of t_diffs
            result = mapper.writeValueAsString(d);
            //result += stringFromList(t_diffs);
            //result += "}],'layout':{'title':'heather graph'}}";
            return result;
        } catch (Exception e) {
            StringWriter errors = new StringWriter();
            e.printStackTrace(new PrintWriter(errors));
            return errors.toString();
        } finally {

        }

    }

    public static SortedMap computeTimeRamp(SortedMap<String, ArrayList<Double>> item_ramp) {
        SortedMap<String, Double> time_ramp = new TreeMap<>();
        Iterator it = item_ramp.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry pair = (Map.Entry) it.next();
            String beginTime = pair.getKey().toString();
            ArrayList<Double> curList = (ArrayList<Double>)pair.getValue();
            Iterator listIt = curList.iterator();
            Double listTotal = 0.d;
            while (listIt.hasNext()) {
                listTotal += (Double) listIt.next();
            }
            time_ramp.put(beginTime, listTotal);
        }
        return time_ramp;
    }
    
    public static SortedMap getBad(Map<String, Object> data, String step, String item, float multiplier) {

        //Map<String, Float> time_ramp = new HashMap<String, Float>(); construct this from item_ramp later
        SortedMap<String, ArrayList<Double>> item_ramp = new TreeMap<>();
        
        Iterator it = data.entrySet().iterator();
        while (it.hasNext()) {
            //float badchannels = 0.f;  // will be computed outside later using item list
            Map.Entry pair = (Map.Entry) it.next();
            if (pair.getKey().toString().contains("RTM-004")) {
                continue;
            }
            Map<String, Object> raftDict = (Map<String, Object>) pair.getValue();
            Map<String, Object> stepDict = (Map<String, Object>) raftDict.get("steps");
            String beginTime = (String) raftDict.get("begin");
          //  Date beginDate = df2.parse(beginTime);
            ArrayList<Double> item_list = new ArrayList<>();

            //time_ramp.put(beginTime, 0.f);
            
            Map<String,Object> a = (Map<String, Object>) stepDict.get(step);
            
            ArrayList<Map<String, Object>> defects = (ArrayList< Map<String, Object>>) a.get(step);
            Iterator defectIt = defects.iterator();
            String type = "";
            while (defectIt.hasNext()) {
                Map<String,Object> cur = (Map<String,Object>) defectIt.next();
                if ((Integer)cur.get("schemaInstance")==0) {
                    type = (String)cur.get(item);
                    continue;
                }
                double val = 0.d;
                if (type.equals("int")) {
                    val = (int) cur.get(item) * multiplier; 
                } else if (type.equals("float")) {
                    val = (double)cur.get(item) * multiplier;
                }
                //badchannels += val;
                item_list.add(val);
              //  time_ramp[beginTime] += val;

            }
            
            item_ramp.put(beginTime, item_list);

        }
        return item_ramp;
    }
        
 
    
    public static String getBadChannels(String hdwType, String db) {
        String result;
        PlotXYObject d = new PlotXYObject();
        d.getLayout().setTitle("LCA-11021_RTM Bad Channels");
        d.getLayout().getYaxis().setType("log");
        
        Boolean prodServer = true;
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'kk:mm:ss.S"); 
        
        try {

            Map<String, Object> brightDefects = eTApi.getResultsJH(db, true, hdwType, "SR-RTM-EOT-03", "bright_defects_raft");
            SortedMap<String, ArrayList<Double>> bl = getBad(brightDefects, "bright_defects_raft", "bright_pixels", 1.f);
            SortedMap<String, Float> brights = computeTimeRamp(bl);
            SortedMap<String, ArrayList<Double>> blc = getBad(brightDefects, "bright_defects_raft", "bright_columns", 2002.f);
            SortedMap<String, Float> bright_cols = computeTimeRamp(blc);

            Map<String, Object> darkDefects = eTApi.getResultsJH(db, true, hdwType, "SR-RTM-EOT-03", "dark_defects_raft");
            SortedMap<String, ArrayList<Double>> dl = getBad(darkDefects, "dark_defects_raft", "dark_pixels", 1.f);
            SortedMap<String, Float> darks = computeTimeRamp(dl);
            SortedMap<String, ArrayList<Double>> dlc = getBad(darkDefects, "dark_defects_raft", "dark_columns", 2002.f);
            SortedMap<String, Float> dark_cols = computeTimeRamp(dlc);

            Map<String, Object> readNoiseResults = eTApi.getResultsJH(db, true, hdwType, "SR-RTM-EOT-03", "read_noise_raft");
            SortedMap<String, ArrayList<Double>> read_noise_c = getBad(readNoiseResults, "read_noise_raft", "read_noise", 1.f);
            SortedMap<String, Float> readNoise = computeTimeRamp(read_noise_c);
            
            //calcBadChannels();

            Iterator brightIt = brights.entrySet().iterator();
            PlotXYData brightData = new PlotXYData();
            while (brightIt.hasNext()) {
                Map.Entry pair = (Map.Entry) brightIt.next();

                brightData.addX((String)pair.getKey());
                brightData.addY((Double)pair.getValue());
            }
            brightData.addName("Bright Pixels");
            d.getData().add(brightData);

            Iterator bright_colIt = bright_cols.entrySet().iterator();
            PlotXYData bright_colData = new PlotXYData();
            while(bright_colIt.hasNext()) {
                Map.Entry pair = (Map.Entry) bright_colIt.next();
                bright_colData.addX((String)pair.getKey());
                bright_colData.addY((Double)pair.getValue());
            }
            bright_colData.addName("Bright ColumnPixels");
            d.getData().add(bright_colData);
            
            Iterator darkIt = darks.entrySet().iterator();
            PlotXYData darkData = new PlotXYData();
            while(darkIt.hasNext()) {
                Map.Entry pair = (Map.Entry) darkIt.next();
                darkData.addX((String)pair.getKey());
                darkData.addY((Double)pair.getValue());
            }
            darkData.addName("Dark Pixels");
            d.getData().add(darkData);
            
            Iterator dark_colIt = dark_cols.entrySet().iterator();
            PlotXYData dark_colData = new PlotXYData();
            while(dark_colIt.hasNext()) {
                Map.Entry pair = (Map.Entry) dark_colIt.next();
                dark_colData.addX((String)pair.getKey());
                dark_colData.addY((Double)pair.getValue());
            }
            dark_colData.addName("Dark ColumnPixels");
            d.getData().add(dark_colData);
            
            
            result = mapper.writeValueAsString(d);
            return result;
            
        } catch (Exception e) {
            StringWriter errors = new StringWriter();
            e.printStackTrace(new PrintWriter(errors));
            return errors.toString();
        } 
        
        
    }

}
