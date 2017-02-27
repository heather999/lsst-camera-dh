package org.lsst.camera.portal.queries;

import java.util.HashMap;
import java.util.Map;

/**
 * Encapsulate the expression read from the REPORT_SPECS table
 *
 * @author tonyj
 */
public class Specifications {

    private final Map<String, Specs> specMap = new HashMap<>();

    String getStatusExpression(String specId) {
        return specMap.get(specId).statusExpression;
    }

    String getValueExpression(String specId) {
        return specMap.get(specId).valueExpression;

    }

    String getFormattedValueExpression(String specId) {
        return specMap.get(specId).formattedExpression;
    }

    void addSpec(String specId, String jexl_value, String jexl_status, String jexl_measurement) {
        specMap.put(specId, new Specs(jexl_status, jexl_value, jexl_measurement));
    }

    private class Specs {

        private String statusExpression;
        private String valueExpression;
        private String formattedExpression;

        public Specs(String statusExpression, String valueExpression, String formattedExpression) {
            this.statusExpression = statusExpression;
            this.valueExpression = valueExpression;
            this.formattedExpression = formattedExpression;
        }
        
    }
}
