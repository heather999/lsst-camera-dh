package org.lsst.camera.portal.queries;

import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.commons.jexl3.JexlBuilder;
import org.apache.commons.jexl3.JexlEngine;
import org.apache.commons.jexl3.MapContext;
import org.apache.commons.jexl3.JexlScript;

/**
 *
 * @author chee
 */
public class JexlUtils {

    private static final JexlEngine jexl = new JexlBuilder().create();
    private static final Logger logger = Logger.getLogger(JexlUtils.class.getName());
    
    public static Object jexlEvaluateData(Map<String, Map<String, List<Object>>> data, String measurement) {
        try {
            MapContext mc = new MapContext();
            JexlFunctions jexlUtils = new JexlFunctions(jexl, mc, data);
            mc.set("u", jexlUtils);
            JexlScript func = jexl.createScript(measurement);
            return func.execute(mc);
        } catch (Exception x) {
            logger.log(Level.WARNING, "**Error while evaluating measurement: "+measurement, x);
            throw x;
        }
    }

    public static Object jexlEvaluateSubcomponentData(String run, Map<String, Map<String, List<Object>>> data, Map<String, Map<String, Map<String, List<Object>>>> subComponentData, Specifications specs, String measurement) {
        try {
            MapContext mc = new MapContext();
            JexlFunctions functions = new JexlFunctions(jexl, mc, data);
            mc.set("u", functions);
            mc.set("run", run);
            if (specs != null && subComponentData != null) {
                JexlSubcomponentFunctions subFunctions = new JexlSubcomponentFunctions(specs, subComponentData);
                mc.set("s", subFunctions);
            }
            JexlScript func = jexl.createScript(measurement);
            return func.execute(mc);
        } catch (Exception x) {
            logger.log(Level.WARNING, "**Error while evaluating measurement: "+measurement, x);
            throw x;
        }
    }
}