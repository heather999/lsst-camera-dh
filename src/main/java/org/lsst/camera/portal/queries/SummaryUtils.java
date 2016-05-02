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

/**
 *
 * @author chee
 */
public class SummaryUtils {

    public static Map<String, Map<String, List<Object>>> getReportValues(HttpSession session, Integer actParentId) throws SQLException, ServletException, JspException {

        Map<String, Map<String, List<Object>>> result = new LinkedHashMap<>(); // orders the elements in the same order they're processed instead of random order.

        try (Connection c = ConnectionManager.getConnection("jdbc/config-prod")) {
            // FIXME: We should not hard-wire the DEV connection here.
            try (Connection oraconn = ConnectionManager.getConnection(session)) {

                PreparedStatement stmt = c.prepareStatement("select rkey, id, query from report_queries");
                ResultSet r = stmt.executeQuery();
                while (r.next()) {
                    String key = r.getString("rkey");
                    String tmpstr = r.getString("query");
                    Map<String, List<Object>> map = new HashMap<>();
                    PreparedStatement stmt2 = oraconn.prepareStatement(tmpstr);
                    stmt2.setInt(1, actParentId);
                    ResultSet q = stmt2.executeQuery();
                    int nCol = q.getMetaData().getColumnCount();
                    for (int col=1; col<=nCol; col++) {
                        map.put(q.getMetaData().getColumnName(col),new ArrayList<>());
                    }
                    while (q.next()) {
                        for (int col=1; col<=nCol; col++ ) {
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
}
