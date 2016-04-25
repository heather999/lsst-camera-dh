package org.lsst.camera.portal.queries;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.apache.commons.jexl3.JexlEngine;
import org.apache.commons.jexl3.MapContext;
import org.apache.commons.jexl3.JexlBuilder;
import org.apache.commons.jexl3.JexlScript;

/**
 *
 * @author chee
 */
public class JexlUtils {

    private static JexlEngine jexl;

    private final Map<String, List> data;

    public JexlUtils(Map<String, List> data) { // constructor
        this.data = data;
    }

    public static Object jexlEvaluateData(Map<String, List> data, String measurement) {
        JexlUtils jexlUtils = new JexlUtils(data);
        jexl = new JexlBuilder().create();
        MapContext mc = new MapContext();
        mc.set("u", jexlUtils);
        JexlScript func = jexl.createScript(measurement);
        return func.execute(mc);
    }

    public List fetch(String SpecId) {
        List result = data.get(SpecId);
        if (result == null) {
            throw new RuntimeException("Unable to fetch " + SpecId);
        }
        return result;
    }

    public Number min(List<Number> args) {
        Number min = Double.NaN;
        for (Number a : args) {
            if (!(a.doubleValue() > min.doubleValue())) {
                min = a; // if NaN (not-a-number or not a mathematical result) is false then it's a number and greater than min, so reset min to a 
            }
        }
        return min;
    }

    public Number max(List<Number> args) {
        Number max = Double.NaN;
        for (Number a : args) {
            if (!(a.doubleValue() < max.doubleValue())) {
                max = a;
            }
        }
        return max;
    }

    public int minIndex(List<Number> args) {
        double min = Double.NaN;
        int minIndex = -1;
        for (int i = 0; i < args.size(); i++) {
            double a = args.get(i).doubleValue();
            if (!(a > min)) {
                min = a;
                minIndex = i;
            }
        }
        return minIndex;
    }

    public int maxIndex(List<Number> args) {
        double max = Double.NaN;
        int maxIndex = -1;
        for (int i = 0; i < args.size(); i++) {
            double a = args.get(i).doubleValue();
            if (!(a < max)) {
                max = a;
                maxIndex = i;
            }
        }
        return maxIndex;
    }

    public List<Number> divide(List<Number> a1, List<Number> a2) {
        List<Number> result = new ArrayList<>();
        for (int i = 0; i < Math.min(a1.size(), a2.size()); i++) {
            result.add(a1.get(i).doubleValue() / a2.get(i).doubleValue());
        }
        return result;
    }

    public double sum(List<Number> args) {
        double sum = 0;
        for (Number a : args) {
            sum = sum + a.doubleValue();
        }
        return sum;
    }

    public double median(List<Number> args) {
        // Collections does not have a comparator for Number so we have to make our own. 
        List<Number> tmpList = new ArrayList<>(args);
        Collections.sort(tmpList, (Number o1, Number o2) -> (int) Math.signum(o1.doubleValue() - o2.doubleValue()));

        int size = tmpList.size();
        boolean isOdd = size % 2 != 0;

        if (isOdd) {
            return tmpList.get(size / 2).doubleValue();
        } else {
            return (tmpList.get(size / 2).doubleValue() + tmpList.get(size / 2 + 1).doubleValue()) / 2;
        }
    }

    public String format(String format, Object... arg) {
        return String.format(format, arg);
    }

    public List<Map<String, Object>> toTable(String[] headers, int nRows, String... jexlCol) {
        List<Map<String, Object>> result = new ArrayList<>();
        for (int i = 0; i < nRows; i++) {
            Map<String, Object> item = new LinkedHashMap<>();
            for (int j = 0; j < headers.length; j++) {
                MapContext mc = new MapContext();
                mc.set("u", this);
                mc.set("row", i);
                JexlScript func = jexl.createScript(jexlCol[j]);
                item.put(headers[j], func.execute(mc));
            }
            result.add(item);
        }
        return result;
    }

}
