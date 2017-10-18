/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.lsst.camera.portal.queries;

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


import com.fasterxml.jackson.databind.ObjectMapper;

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
    
    public static long timeDiff(Date begin, Date end) {
        TimeUnit myTime =TimeUnit.MILLISECONDS;
        long milli = end.getTime() - begin.getTime();
        long days = myTime.toDays(milli);
        return days;
    }
    
    
    public static String stringFromList(List<Integer> theList) {
        String result="";
        if (theList.isEmpty()) return (""); // If no items, return empty string
            Iterator<Integer> iterator = theList.iterator();
            int counter=0;
            while (iterator.hasNext()) {
                if (counter==0)
                    result+="[";
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
        String result = "{'data':[{'x':";
        //List<Long> result = new ArrayList<>();
        //PlotObject d = new PlotObject();
        //d.getLayout().setTitle("MyTitle");
        PlotData d = new PlotData();
        ObjectMapper mapper = new ObjectMapper();
        Boolean prodServer = true;
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'kk:mm:ss.S"); 
        List<Integer> t_diffs = new ArrayList<>();
        try {
            Set<String> labels = new HashSet<>(Arrays.asList("SR_Grade", "SR_Contract"));
            ArrayList<HashMap<String, Object>> hdwInstances = eTApi.getHardwareInstances(hdwType, prodServer, db, labels);
            Iterator hdwIt = hdwInstances.iterator();
            int count_ccd = 0;
            while (hdwIt.hasNext()) {
                String beginTime="";
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

                        beginTime = (String) travRun.get("begin");
                        if (beginTime.isEmpty()) {
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

                        beginTime = (String) travRun.get("begin");
                        if (beginTime.isEmpty()) {
                            continue; // look at the next run
                        } else {
                            found = true;
                            break;
                        }

                    }

                }

                if (found) { // we have a begin time, now find BNL arrival
                    Date beginDate = df.parse(beginTime);
                    Map<Integer, Object> runListCCD = eTApi.getComponentRuns(db, hdwType, curCcd, "SR-RCV-01");
                    if (runListCCD == null) 
                        continue;

                    SortedSet<Integer> keys = new TreeSet<Integer>(runListCCD.keySet());
                    for (Integer key : keys) {

                        HashMap<String, Object> travRun = (HashMap<String, Object>) runListCCD.get(key);

                        String bnlTime = (String) travRun.get("begin");
                        if (bnlTime.isEmpty()) 
                            continue;
                        Date arrivalDate = df.parse(bnlTime);
                        Long diffDays = timeDiff(beginDate, arrivalDate);
                        t_diffs.add(diffDays.intValue());
                        d.addX(diffDays.intValue());

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

}
