package org.lsst.camera.portal.queries;

import java.util.List;
import java.util.Map;

/**
 * Functions with operate on data corresponding to subcomponents. Also requires
 * a list of subcomponent specifications and functions, and a separate function
 * with can operate on them.
 *
 * @author tonyj
 */
public class JexlSubcomponentFunctions {

    private final Map<String, Map<String, Map<String, List<Object>>>> subComponentData;
    private final Specifications specs;

    JexlSubcomponentFunctions(Specifications specs, Map<String, Map<String, Map<String, List<Object>>>> subComponentData) {
        this.specs = specs;
        this.subComponentData = subComponentData;
    }

    /**
     * Returns true only if the given spec is true for all subcomponents
     *
     * @param specId The spec. Id, e.g C-SRTF-001
     * @return
     */
    public boolean allGood(String specId) {

        String statusExpression = specs.getStatusExpression(specId);
        for (Map.Entry<String, Map<String, Map<String, List<Object>>>> data : subComponentData.entrySet()) {
            boolean ok = (boolean) JexlUtils.jexlEvaluateData(data.getValue(), statusExpression);
            if (!ok) {
                return false;
            }
        }
        return true;
    }

    public Number minValue(String specId) {
        Number result = null;
        String valueExpression = specs.getValueExpression(specId);
        for (Map.Entry<String, Map<String, Map<String, List<Object>>>> data : subComponentData.entrySet()) {
            Number value = (Number) JexlUtils.jexlEvaluateData(data.getValue(), valueExpression);
            result = result == null ? value : Math.min(result.doubleValue(), value.doubleValue());
        }
        return result;
    }

    public Number maxValue(String specId) {
        Number result = null;
        String valueExpression = specs.getValueExpression(specId);
        for (Map.Entry<String, Map<String, Map<String, List<Object>>>> data : subComponentData.entrySet()) {
            Number value = (Number) JexlUtils.jexlEvaluateData(data.getValue(), valueExpression);
            result = result == null ? value : Math.max(result.doubleValue(), value.doubleValue());
        }
        return result;
    }
}
