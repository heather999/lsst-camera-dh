package org.lsst.camera.portal.queries;

import java.util.List;
import java.util.Map;
import org.apache.commons.jexl3.JexlEngine;
import org.apache.commons.jexl3.JexlExpression;
import org.apache.commons.jexl3.MapContext;
import org.apache.commons.jexl3.JexlBuilder;

/**
 *
 * @author chee
 */
public class JexlUtils {

    private final Map<String, List> data;

    public JexlUtils(Map<String, List> data) { // constructor
        this.data = data;
    }

    public static Object jexlEvaluateData(Map<String, List> data, String measurement) {
        System.out.println("Args " +  data +", "+ measurement);
        JexlUtils jexlUtils = new JexlUtils(data);
        JexlEngine jexl = new JexlBuilder().create();
        MapContext mc = new MapContext();
        mc.set("u", jexlUtils);
        JexlExpression func = jexl.createExpression(measurement);
    
        return func.evaluate(mc);
    }

    public List fetch(String SpecId) {
        List result =  data.get(SpecId);
        if (result == null) throw new RuntimeException("Unable to fetch "+SpecId);
        return result;
    }

    public double min(List<Number> args) {
        double min = Double.NaN;
        for (Number a : args) {
            if (!(a.doubleValue() > min)) {
                min = a.doubleValue(); // if NaN (not-a-number or not a mathematical result) is false then it's a number and greater than min, so reset min to a 
            }
        }
        return min;
    }

    public double max(List<Number> args) {
        double max = Double.NaN;
        for (Number a : args) {
            if (!(a.doubleValue() < max)) {
                max = a.doubleValue();
            }
        }
        return max;
    }
    
    public double sum(List<Number> args) {
        double sum = 0;
        for (Number a : args) {
             sum = sum + a.doubleValue();
        }
        return sum;
    }

    public String format(String format, double arg) {
        return String.format(format, arg);
    }

}
