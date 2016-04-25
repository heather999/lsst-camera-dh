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
 
     public static Map<String, List<?>> getReportValues (HttpSession session, Integer actParentId) throws SQLException, ServletException, JspException {
          
          Connection c = null; 
          Connection oraconn = null; 
  
          boolean debug = false;
          Map<String, List<?> > queryMap = new LinkedHashMap<>(); // orders the elements in the same order they're processed instead of random order.
          
          try {
              c = ConnectionManager.getConnection("jdbc/config-prod");
              oraconn = ConnectionManager.getConnection("jdbc/rd-lsst-cam-dev-ro");
              
              PreparedStatement stmt = c.prepareStatement("select rkey, id, query from report_queries");
              ResultSet r = stmt.executeQuery();
              while (r.next()) {
                 String key = r.getString("rkey");
                 String tmpstr=r.getString("query");
                 List<Object> resultList = new ArrayList<>(); // create list each time so values don't accumulate
                 PreparedStatement stmt2 = oraconn.prepareStatement(tmpstr);
                 stmt2.setInt(1, actParentId);
                 ResultSet q = stmt2.executeQuery();
                 while (q.next()){
                   resultList.add(q.getObject("value"));
                 }
                 queryMap.put(key, resultList);
              }
              
              if (debug){
                  for (Map.Entry<String, List<?>> entry : queryMap.entrySet()){
                       System.out.println("KEY= "+entry.getKey()+" Value="+ entry.getValue());
                  }
              }
          }
          catch(SQLException e){
              e.printStackTrace();
              throw e;
          }
          finally{
              if( c!= null && !c.isClosed()){
                  c.close();
              }
              if( oraconn != null && !oraconn.isClosed()){
                  oraconn.close();
              }
          }

          return queryMap;
     }
}

