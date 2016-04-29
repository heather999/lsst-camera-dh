package org.lsst.camera.portal.queries;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.jsp.*;
import javax.servlet.ServletException;
import javax.servlet.http.HttpSession;
import org.srs.web.base.db.ConnectionManager;

/**
 *
 * @author chee
 */
public class SummaryUtils {

    public static Map<String, List<?>> getReportValues(HttpSession session, Integer actParentId) throws SQLException, ServletException, JspException {

        boolean debug = false;
        Map<String, List<?>> result = new LinkedHashMap<>(); // orders the elements in the same order they're processed instead of random order.

        try (Connection c = ConnectionManager.getConnection("jdbc/config-prod")) {
            // FIXME: We should not hard-wire the DEV connection here.
            try (Connection oraconn = ConnectionManager.getConnection(session)) {

                PreparedStatement stmt = c.prepareStatement("select rkey, id, query from report_queries");
                ResultSet r = stmt.executeQuery();
                while (r.next()) {
                    String key = r.getString("rkey");
                    String tmpstr = r.getString("query");
                    List<Object> resultList = new ArrayList<>(); // create list each time so values don't accumulate
                    PreparedStatement stmt2 = oraconn.prepareStatement(tmpstr);
                    stmt2.setInt(1, actParentId);
                    ResultSet q = stmt2.executeQuery();
                    while (q.next()) {
                        resultList.add(q.getObject("value"));
                    }
                    result.put(key, resultList);
                }
            }
        }
        if (debug) {
            for (Map.Entry<String, List<?>> entry : result.entrySet()) {
                System.out.println("Key= " + entry.getKey() + " Value=" + entry.getValue());
            }
        }
        return result;
    }
}
