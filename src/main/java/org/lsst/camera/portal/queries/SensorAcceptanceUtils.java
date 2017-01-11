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
import java.lang.Math;
import javax.servlet.jsp.*;
import javax.servlet.ServletException;
import javax.servlet.http.HttpSession;
import org.srs.web.base.db.ConnectionManager;
import org.lsst.camera.portal.data.MetData;


/**
 *
 * @author heather 
 */
public class SensorAcceptanceUtils {

  
   
    public static Map<String, Map<String, List<Object>>> getSensorReportValues(HttpSession session, Integer actParentId, String reportIdList) throws SQLException, ServletException, JspException {

        Map<String, Map<String, List<Object>>> result = new LinkedHashMap<>(); // orders the elements in the same order they're processed instead of random order.

        //try (Connection c = ConnectionManager.getConnection("jdbc/config-prod")) {
        try (Connection c = ConnectionManager.getConnection("jdbc/configdev")) {
            // FIXME: We should not hard-wire the DEV connection here.
            try (Connection oraconn = ConnectionManager.getConnection(session)) {

                PreparedStatement stmt = c.prepareStatement("select rkey, id, query from report_queries where report IN " + reportIdList);
                //stmt.setInt(1, reportId);
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
    
    public static List getMetReportValues(HttpSession session, Integer actParentId) throws SQLException {
        List<MetData> result = new ArrayList<>();
        
        Connection c = null;
        try {
         c = ConnectionManager.getConnection(session);
         String ccd030 = "CCD-030";
         String ccd030a = "CCD-030a";
         String ccd030b = "CCD-030b";
         String ccd030c = "CCD-030c";
         String ccd031 = "CCD-031";
         
         String ccd030Desc = "Nominal height and Sensor height";
         String ccd030aDesc = "Nominal height (znom)";
         String ccd030bDesc = "Nominal height (zmedian)";
         String ccd030cDesc = "Sensor height";
         String ccd031Desc = "Sensor Surface Flatness";
         
         String ccd030Spec = "|zmedian-13|<25 &micro;m && |znom-13|<25 &micro;m && Z95halfband < 9 &micro;m";
         String ccd030aSpec = "...";
         String ccd030bSpec = "...";
         String ccd030cSpec = "...";
         String ccd031Spec = "< 5 &micro;m";
         
         MetData ccd030Data = new MetData(ccd030, ccd030Desc, ccd030Spec);
         MetData ccd030aData = new MetData(ccd030a, ccd030aDesc, ccd030aSpec);
         MetData ccd030bData = new MetData(ccd030b, ccd030bDesc, ccd030bSpec);
         MetData ccd030cData = new MetData(ccd030c, ccd030cDesc, ccd030cSpec);
         MetData ccd031Data = new MetData(ccd031, ccd031Desc, ccd031Spec);

         PreparedStatement ccd030aStatement = c.prepareStatement("SELECT res.activityId, res.value AS znom FROM"
                 + " FloatResultHarnessed res JOIN Activity act ON res.activityId=act.id "
                 + " WHERE lower(res.schemaName) = 'metrology_vendoringest' AND res.name='znom' "
                 + " AND act.parentActivityId=?");
         ccd030aStatement.setInt(1, actParentId);
         ResultSet ccd030aResult = ccd030aStatement.executeQuery();

         
         PreparedStatement ccd030bStatement = c.prepareStatement("SELECT res.activityId, res.value AS zmedian"
                 + " FROM FloatResultHarnessed res join Activity act ON res.activityId=act.id "
                 + " WHERE lower(res.schemaName) = 'metrology_vendoringest' AND res.name='zmedian' "
                 + " AND act.parentActivityId=?");
         ccd030bStatement.setInt(1, actParentId);
         ResultSet ccd030bResult = ccd030bStatement.executeQuery();

                 
         PreparedStatement ccd030cStatement = c.prepareStatement("SELECT res.activityId, res.value AS z95halfband "
                 + " FROM FloatResultHarnessed res JOIN Activity act ON res.activityId=act.id "
                 + " WHERE lower(res.schemaName) = 'metrology_vendoringest' AND res.name='z95halfband' "
                 + " AND act.parentActivityId=?");
         ccd030cStatement.setInt(1, actParentId);
         ResultSet ccd030cResult = ccd030cStatement.executeQuery();
         
         if (ccd030aResult.first() && ccd030bResult.first() && ccd030cResult.first()) {
             Double znom = ccd030aResult.getDouble("znom");
             Double zmedian = ccd030bResult.getDouble("zmedian");
             Double z95halfband = ccd030cResult.getDouble("z95halfband");
             ccd030aData.setVendorVendor(String.format("%.3f", znom) , Math.abs(znom-13.)<25 );
             ccd030bData.setVendorVendor(String.format("%.3f", zmedian), (Math.abs(zmedian-13.)<25));
             ccd030cData.setVendorVendor(String.format("%.3f", z95halfband), (z95halfband<0.009));
             Boolean ccd030Status = (Math.abs(znom - 13.) < 25) && (Math.abs(zmedian-13.)<25) && (z95halfband<0.009);
             ccd030Data.setVendorVendor("...", ccd030Status);
         }
         
         PreparedStatement ccd031Statement = c.prepareStatement("SELECT res.activityId, res.value AS flatness "
                 + " FROM FloatResultHarnessed res JOIN Activity act ON res.activityId=act.id "
                 + " WHERE lower(res.schemaName) = 'metrology_vendoringest' AND res.name='flatnesshalfband_95' "
                 + " AND act.parentActivityId=?");
         ccd031Statement.setInt(1, actParentId);
         ResultSet ccd031Result = ccd031Statement.executeQuery();

         if (ccd031Result.first()) {
             double flatness = ccd031Result.getDouble("flatness");
             ccd031Data.setVendorVendor(String.format("%.4f", flatness), (flatness < 5.));
         }
         
         result.add(ccd030Data);
         result.add(ccd030aData);
         result.add(ccd030bData);
         result.add(ccd030cData);
         result.add(ccd031Data);
         
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (c != null) {
                //Close the connection
                c.close();
            }
        }

        return result;
        }
    }
    

