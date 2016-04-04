package org.lsst.camera.portal.queries;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Map;
import javax.servlet.http.HttpSession;
import org.apache.commons.jexl3.JexlEngine;
import org.apache.commons.jexl3.JexlExpression;
import org.apache.commons.jexl3.MapContext;
import org.apache.commons.jexl3.JexlBuilder;
import org.srs.web.base.db.ConnectionManager;

/**
 *
 * @author chee
 */
public class JexlUtils {

    private final Map<String, double[]> data;

    public JexlUtils(Map<String, double[]> data) { // constructor
        this.data = data;
    }

    public static Object jexlEvaluateData(Map<String, double[]> data, String measurement) {
        System.out.println("Args " +  data +", "+ measurement);
        JexlUtils jexlUtils = new JexlUtils(data);
        JexlEngine jexl = new JexlBuilder().create();
        MapContext mc = new MapContext();
        mc.set("u", jexlUtils);
        JexlExpression func = jexl.createExpression(measurement);
    
        return func.evaluate(mc);
    }

    public double[] fetch(String SpecId) {
        return data.get(SpecId);
    }

    public double min(double[] args) {
        double min = Double.NaN;
        for (double a : args) {
            if (!(a > min)) {
                min = a; // if NaN (not-a-number or not a mathematical result) is false then it's a number and greater than min, so reset min to a 
            }
        }
        return min;
    }

    public double max(double[] args) {
        double max = Double.NaN;
        for (double a : args) {
            if (!(a < max)) {
                max = a;
            }
        }
        return max;
    }
    
    public double sum(double[] args) {
        double sum = 0;
        for (double a : args) {
             sum = sum + a;
        }
        return sum;
    }

    public String format(String format, double arg) {
        return String.format(format, arg);
    }

}
