/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
 
package org.lsst.camera.portal.queries;

import java.io.*;
import java.lang.Math;
import java.math.BigDecimal;
import java.nio.charset.Charset;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Iterator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.logging.Logger;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.logging.Level;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;
import javax.servlet.ServletException;
import javax.servlet.http.HttpSession;
import org.apache.commons.jexl3.JexlArithmetic;
import org.lsst.camera.portal.data.TravelerStatus;
import org.lsst.camera.portal.data.HardwareStatus;
import org.lsst.camera.portal.data.HdwStatusLoc;
import org.lsst.camera.portal.data.Activity;
import org.lsst.camera.portal.data.TravelerInfo;
import org.lsst.camera.portal.data.ReportData;
import org.lsst.camera.portal.data.TestReportPathData;
import org.lsst.camera.portal.data.ComponentData;
import org.lsst.camera.portal.data.CatalogFileData;
import org.srs.web.base.db.ConnectionManager;
//import org.apache.commons.jexl3.Expression;
import org.apache.commons.jexl3.JexlContext;
import org.apache.commons.jexl3.JexlEngine;
import org.apache.commons.jexl3.JexlExpression;
import org.apache.commons.jexl3.JexlInfo;
import org.apache.commons.jexl3.JexlScript;
import org.apache.commons.jexl3.JxltEngine;
import org.apache.commons.jexl3.JxltEngine.Expression;
import org.apache.commons.jexl3.MapContext;
import org.apache.commons.jexl3.introspection.JexlUberspect;
import org.apache.commons.jexl3.JexlBuilder;
import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;


/**
 *
 * @author chee
 */
public class SummaryUtils {
     private static final Logger logger = Logger.getLogger(SummaryUtils.class.getName());
  
// An example of how to make your own datatype     
//     public static class MyDataType{
//         public String schemaname;
//         public String procname;
//         public Double value;
//         
//         public MyDataType(String schemaname, String procname, Double value) {
//            this.schemaname = schemaname;
//            this.procname = procname;
//            this.value = value;
//        }
//         public String getSchemaname() {
//            return schemaname;
//        }
//        public String getProcname() {
//            return procname;
//        }
//        public Double getValue() {
//            return value;
//        }
//        
//        //      For debugging output the values instead of the default memory address. 
//        @Override
//        public String toString() {
//              return "SummaryResult{ " + schemaname + " value " + value + " procname " + procname + "}";
////            return "SummaryResult{" + "schemaInstance=" + schemaInstance + ", min=" + min + ", max=" + max + '}';
//        }
//     }
     
     // This class can eventually be split out into its own file
    public static class SummaryResult {
        public Integer schemaInstance;
        public String min;
        public String max;

        public SummaryResult(Integer schemaInstance, String min, String max) {
            this.schemaInstance = schemaInstance;
            this.min = min;
            this.max = max;
        }
        
        public Integer getSchemaInstance() {
            return schemaInstance;
        }

        public String getMin() {
            return min;
        }
                
        public String getMax() {
            return max;
        }
//      For debugging output the values instead of the default memory address. 
        @Override
        public String toString() {
              return "SummaryResult {" + schemaInstance + ", min=" + min + ", max=" + max + "}";
//            return "SummaryResult{" + "schemaInstance=" + schemaInstance + ", min=" + min + ", max=" + max + '}';
        }

    }
    
     public static List<SummaryResult> getSummaryResults(HttpSession session, String schemaName, String parentActivityId, String ntype, String... names) throws SQLException, ServletException{

        List<SummaryResult> results = new ArrayList<>();
        System.out.println("...Entering getSummaryResults with params schemaName=" + schemaName + " parentId=" + parentActivityId + " ntype " + ntype + " names " + names);  
        String sql="";
////        In MySQL group by and order by don't do what is expected so try query without these.        
////        String sql = 
////        "select res.schemaInstance, min(res.value) min, max(res.value) max from FloatResultHarnessed res join Activity act on res.activityId=act.id "
////        + "    where res.schemaName=? and res.name = ? and act.parentActivityId = ? "
////        + "    group by res.schemaInstance order by res.value asc";
        
//        if (ntype.equals("f")){
//            sql = 
//            "select res.schemaInstance, min(res.value) min, max(res.value) max from FloatResultHarnessed res join Activity act on res.activityId=act.id "
//          + "where res.schemaName=? and res.name = ? and act.parentActivityId = ? ";
//        }
//        if (ntype.equals("i")){
//            sql = 
//            "select res.schemaInstance, min(res.value) min, max(res.value) max from IntResultHarnessed res join Activity act on res.activityId=act.id "
//          + "where res.schemaName=? and res.name = ? and act.parentActivityId = ? ";
//        }
       
//        String sql = 
//        "select res.schemaInstance, min(res.value) min, max(res.value) max from FloatResultHarnessed res join Activity act on res.activityId=act.id "
//        + "    where res.schemaName=? and res.name = ? and act.parentActivityId = ? "
//        + "    group by res.schemaInstance order by res.value asc";
//        System.out.println(sql);
         
//        for (int i=0; i <= names.length-1; i++){
//            System.out.println("Names[" + i + "] = " + names[i]);
//        }
        
        try (Connection conn = ConnectionManager.getConnection(session)){
            try ( PreparedStatement stmt = conn.prepareStatement(sql) ) {
                for(String name : names){
                    stmt.setString(1, schemaName);
                    stmt.setString(2, name);
                    stmt.setString(3, parentActivityId);
                    ResultSet rs = stmt.executeQuery();
                    System.out.println("ResultSet Rowcount: " + rs.toString().length() + " , " + name);
                    if(!rs.next()){
                        continue;
                    }
                    int schemaInstance = rs.getInt("schemaInstance");
                    String min = rs.getString("min");
                    String max = rs.getString("max");
                    results.add(new SummaryResult( schemaInstance, min, max));
                }
                System.out.println(results);
                System.out.println("...Leaving getSummaryResults \n");  
                
                return results;
            }
        } 
    }
     
     public static Map<String, List<?>> getSensorValues (HttpSession session, Integer actParentId) throws SQLException, ServletException, JspException {
     // this returns a list. The other getSensorValues returns a map
          String tmpname="";
          String dbtable=""; // blank is the default
          String label="";
          
          Connection c = null; 
          Connection oraconn = null;
          List<String> processList = new ArrayList<>(); 
          List<String> resultList = new ArrayList<>();
          Map<String, List<?> > sensorValueMap = new LinkedHashMap<>(); // orders the elements in the same order they're processed instead of random order.

          try {
              c = ConnectionManager.getConnection(session);
              PreparedStatement stmt = c.prepareStatement("select pr.name from Activity act join Process pr on act.processId = pr.id where act.parentActivityId = ?");
              stmt.setInt(1,actParentId);
              ResultSet r = stmt.executeQuery();
              while (r.next()) {
                tmpname = r.getString("name");
                tmpname = tmpname.replace("_offline", "");
                processList.add(tmpname);
              }
          }
          catch(ServletException | SQLException e){
              System.out.println(" 1 " + e);
              throw e;
          }
          finally{
              if( c!= null && !c.isClosed()){
                  c.close();
              }
          }
          
         try {
            String tmpstr=""; 
            c = ConnectionManager.getConnection(session);
            
            oraconn = ConnectionManager.getConnection("jdbc/config-prod");
            PreparedStatement summaryMDStatement = oraconn.prepareStatement("select schemaname, namelist, floatresult, intresult, strresult from summary_md where schemaname like ? and namelist is not null order by namelist\n");
            
            for (int i=0; i < processList.size(); i++){
                tmpname = processList.get(i);
                tmpstr = processList.get(i);
                summaryMDStatement.setString(1, tmpname + "%");
                ResultSet r = summaryMDStatement.executeQuery();
                while (r.next()) { // use ArrayList<Object> to avoid dealing with Float, Integer datatype hassle. Warning - dates may return the unexpected since it's not a number.
                   ArrayList<Object> resultValues = new ArrayList<>();
                   // figure out which table is needed
                   if ( r.getString("floatresult").matches("Y")){ dbtable = "FloatResultHarnessed"; }
                   else if(r.getString("intresult").matches("Y") ){ dbtable = "IntResultHarnessed"; }
                   else if (r.getString("strresult").matches("Y")){ dbtable = "StringResultHarnessed"; }
                   // build the string that will be the key in the map
                   tmpstr = tmpstr + " : " + r.getString("namelist") + " " + dbtable;
                   // do the query and build the list of values
                   PreparedStatement lsstStatement = c.prepareStatement("select res.schemaInstance, res.schemaname, res.name, res.value from " + dbtable + " res join Activity act on res.activityId=act.id where res.schemaName like ? and res.name=? and act.parentActivityId=? order by value asc\n");
                   lsstStatement.setString(1,r.getString("schemaname") + "%");
                   lsstStatement.setString(2,r.getString("namelist"));
                   lsstStatement.setInt(3,actParentId);
                   ResultSet l = lsstStatement.executeQuery();
                   while (l.next()){
                      resultValues.add(l.getObject("value"));
                   }
                   // add the key and the array of values. Reset tmpstr for the next key
                   sensorValueMap.put(tmpstr, resultValues);                   
                   tmpstr = processList.get(i);
                }

            }
         }
         catch(ServletException | JspException | SQLException e){
            System.out.println("2" + e);
            throw e;
         }
         finally{ 
             if (oraconn != null) {oraconn.close();} 
             if (c != null) {c.close();}
         }
         return sensorValueMap; 
          
     }
          
        
     
     public static Number getSummaryMaxFromList (List<Number> listOfnumbers) throws Exception {
          List<Double> tmp = new ArrayList<>();
          for(Number n: listOfnumbers){
              tmp.add(n.doubleValue());
          }
          return Collections.max(tmp);
    }
     
    public static Number getSummaryMinFromList (List<Number> listOfnumbers) throws Exception {
          List<Double> tmp = new ArrayList<>();
          for(Number n: listOfnumbers){
              tmp.add(n.doubleValue());
          }
          return Collections.min(tmp);
    }
    
    public static double getSummaryAverage (List<Number> listOfnumbers){
        double sum=0;
        double avg=0;
        // calculate the mean
        for (int i = 0; i < listOfnumbers.size(); i++){
           sum = sum + listOfnumbers.get(i).doubleValue();
        }
        avg = sum/listOfnumbers.size();
        return avg;
    }

     public static List<Double> getSummarySTDev(Double mean, List<Number> listOfNumbers){
        double new_number=0;
        double squaredMean = 0;
        
        ArrayList<Double> standardDev = new ArrayList<>();
        ArrayList<Double> tmpArray = new ArrayList<>();
        for (Number a_number : listOfNumbers){
            new_number = Math.sqrt(a_number.doubleValue() - mean);
            tmpArray.add(new_number);
        }
        // get the mean of the squared values from listOfNumbers
        int tot = tmpArray.size(); 
        double sum=0;
        for (double a_number : tmpArray){
             sum = sum + a_number;
        }
        squaredMean = Math.sqrt(sum/tot);
        standardDev.add(squaredMean);
        return standardDev ;
    }
}

