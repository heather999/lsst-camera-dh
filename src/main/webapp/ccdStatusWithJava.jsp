<%@page import="java.sql.Statement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="org.srs.web.base.db.ConnectionManager"%>
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="display" uri="http://displaytag.sf.net" %>
<%@taglib prefix="portal" uri="WEB-INF/tags/portal.tld" %>


    <head>
        <title>CCD Current Status</title>
    </head>
     
        <h1>CCD Current Status</h1>
  <%-- Select CCD as the HardwareType for this page, scope session means all the pages? set scope to page --%>
        <c:set var="ccdHdwTypeId" value="1" scope="session"/>  
        <sql:query  var="ccdList"  >
                select  Hardware.id,Hardware.lsstId from Hardware,HardwareType where Hardware.hardwareTypeId=HardwareType.id and HardwareType.id=? 
                <sql:param value="${ccdHdwTypeId}"/>
        </sql:query>
                
        <display:table name="${ccdList.rows}" export="true" class="datatable"/>
        
           
      
        <c:forEach items="${ccdList.rows}" var="ccd">
            <%@ page import = "java.sql.*" %>
            <%
                Connection conn =  DriverManager.getConnection("${pageContext.session}"); // <== Check!

                Statement stmt = conn.createStatement();

                String sqlStr = "SELECT Hardware.lsstId AS lsstId, Process.name AS name,"
                        + "Process.version AS version,Activity.begin,Activity.end,activityFinalStatusId,ActivityFinalStatus.name from Activity,"
                        + "TravelerType,Process,Hardware,ActivityFinalStatus where Activity.processId=TravelerType.id and "
                        + "Process.id=TravelerType.rootProcessId and Hardware.id=Activity.hardwareId and ";
                 sqlStr += "ActivityFinalStatus.id=Activity.activityFinalStatusId ORDER BY Activity.begin DESC";
              //  sqlStr += "Hardware.lsstId=\"${ccd.lsstId}\" and ActivityFinalStatus.id=Activity.activityFinalStatusId and Hardware.hardwareTypeId=\"${ccdHdwTypeId}\" ORDER BY Activity.begin DESC"
              
 
          // for debugging
          System.out.println("Query statement is " + sqlStr);
          ResultSet rset = stmt.executeQuery(sqlStr);
            %>

            
            
         <%--   <c:set var="hardwareStatusTable" value="${portal:getHardwareStatusTable(pageContext.session,ccdHdwTypeId,\"000-00\")}"/> --%>
   
           <%-- <c:set var="hardwareStatusTable" value="${portal:getHardwareStatusTable(pageContext.session,\"${ccd.lsstId}\")}" --%>
         <%--   <display:table name="${hardwareStatusTable.rows}" export="true" class="datatable"/>
            <display:table name="${hardwareStatusTable}" export="true" class="datatable" id="tst" >
                <display:column title="Serial #" >${tst.lsstNumber}</display:column>
                              
            </display:table>
         --%>
        </c:forEach>
        
       <%-- <sql:query  var="ccdList"  >
                select  Hardware.id,Hardware.lsstId from Hardware,HardwareType where Hardware.hardwareTypeId=HardwareType.id and HardwareType.id=? 
                <sql:param value="${selectedHdwTypeId}"/>
        </sql:query>

                

         <h3>CCD Ids</h3>
            <display:table name="${ccdList.rows}" export="true" class="datatable"/>

         <h3>CCD Activity</h3>
            <c:forEach items="${ccdList.rows}" var="ccd">
                <sql:query var="activityQuery">
                   select  Hardware.lsstId, Process.name,Process.version,Activity.begin,Activity.end,activityFinalStatusId,ActivityFinalStatus.name from Activity,TravelerType,Process,Hardware,ActivityFinalStatus where Activity.processId=TravelerType.id and Process.id=TravelerType.rootProcessId and Hardware.id=Activity.hardwareId and Hardware.lsstId="${ccd.lsstId}" and ActivityFinalStatus.id=Activity.activityFinalStatusId and Hardware.hardwareTypeId=? ORDER BY Activity.begin DESC;
                   <sql:param value="${selectedHdwTypeId}"/>
                </sql:query>
                   
                <display:table name="${activityQuery.rows}" export="true" class="datatable"/>
            </c:forEach>
           --%> 

            

            

    

