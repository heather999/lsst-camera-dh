package org.lsst.camera.portal.queries;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.jsp.*;
import javax.servlet.ServletException;
import javax.servlet.http.HttpSession;
import org.srs.web.base.db.ConnectionManager;
import org.srs.web.base.filters.modeswitcher.ModeSwitcherFilter;

/**
 *
 * @author chee
 */
public class SummaryUtils {

    public static Map<String, Map<String, List<Object>>> getReportValues(HttpSession session, Integer actParentId, Integer reportId) throws SQLException, ServletException, JspException {
        Map<String, Map<String, List<Object>>> result = new LinkedHashMap<>(); // orders the elements in the same order they're processed instead of random order.

        try (Connection c = ConnectionManager.getConnection(ModeSwitcherFilter.getVariable(session, "reportDisplayDb"))) {
            try (Connection oraconn = ConnectionManager.getConnection(session)) {

                PreparedStatement stmt = c.prepareStatement("select rkey, id, query from report_queries where report=?");
                stmt.setInt(1, reportId);
                ResultSet r = stmt.executeQuery();
                while (r.next()) {
                    String key = r.getString("rkey");
                    String tmpstr = r.getString("query");
                    Map<String, List<Object>> map = new HashMap<>();
                    PreparedStatement stmt2 = oraconn.prepareStatement(tmpstr);
                    stmt2.setInt(1, actParentId);
                    ResultSet q = stmt2.executeQuery();
                    int nCol = q.getMetaData().getColumnCount();
                    for (int col = 1; col <= nCol; col++) {
                        map.put(q.getMetaData().getColumnName(col), new ArrayList<>());
                    }
                    while (q.next()) {
                        for (int col = 1; col <= nCol; col++) {
                            String colName = q.getMetaData().getColumnName(col);
                            map.get(colName).add(q.getObject(col));
                        }
                    }
                    result.put(key, map);
                }
            }
        }
        return result;
    }

    public static Map<String, Map<String, Map<String, List<Object>>>> getReportValuesForSubcomponents(HttpSession session, Integer actParentId, Integer reportId, List<String> components) throws SQLException, ServletException, JspException {
        Map<String, Map<String, Map<String, List<Object>>>> results = new LinkedHashMap<>();
        // FIXME: We should not create independent database connectiosn for each iteration
        for (String component : components) {
            results.put(component, getReportValuesForSubcomponent(session, actParentId, reportId, component));
        }
        return results;
    }

    public static Map<String, Map<String, List<Object>>> getReportValuesForSubcomponent(HttpSession session, Integer actParentId, Integer reportId, String component) throws SQLException, ServletException, JspException {
        Map<String, Map<String, List<Object>>> result = new LinkedHashMap<>(); // orders the elements in the same order they're processed instead of random order.

        try (Connection c = ConnectionManager.getConnection(ModeSwitcherFilter.getVariable(session, "reportDisplayDb"))) {
            try (Connection oraconn = ConnectionManager.getConnection(session)) {

                PreparedStatement stmt = c.prepareStatement("select rkey, id, query from report_queries where report=?");
                stmt.setInt(1, reportId);
                ResultSet r = stmt.executeQuery();
                while (r.next()) {
                    String key = r.getString("rkey");
                    String tmpstr = r.getString("query");
                    Map<String, List<Object>> map = new HashMap<>();
                    PreparedStatement stmt2 = oraconn.prepareStatement(tmpstr);
                    stmt2.setInt(1, actParentId);
                    stmt2.setString(2, component);
                    ResultSet q = stmt2.executeQuery();
                    int nCol = q.getMetaData().getColumnCount();
                    for (int col = 1; col <= nCol; col++) {
                        map.put(q.getMetaData().getColumnName(col), new ArrayList<>());
                    }
                    while (q.next()) {
                        for (int col = 1; col <= nCol; col++) {
                            String colName = q.getMetaData().getColumnName(col);
                            map.get(colName).add(q.getObject(col));
                        }
                    }
                    result.put(key, map);
                }
            }
        }
        return result;
    }

    public static Specifications getSpecifications(HttpSession session, Integer reportId) throws JspException, SQLException {
        Specifications specs = new Specifications();
        try (Connection c = ConnectionManager.getConnection(ModeSwitcherFilter.getVariable(session, "reportDisplayDb"))) {
            PreparedStatement stmt = c.prepareStatement("select specid, jexl_value, jexl_status, jexl_measurement from report_specs where report=?");
            stmt.setInt(1, reportId);
            ResultSet r = stmt.executeQuery();
            while (r.next()) {
                String specId = r.getString("specid");
                String jexl_value = r.getString("jexl_value");
                String jexl_status = r.getString("jexl_status");
                String jexl_measurement = r.getString("jexl_measurement");
                specs.addSpec(specId,jexl_value,jexl_status,jexl_measurement);
            }
        }
        return specs;
    }
}
