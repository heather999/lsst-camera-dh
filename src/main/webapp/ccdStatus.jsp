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

        <%-- <display:table name="${ccdList.rows}" export="true" class="datatable"/> --%>

        <table border="1">
            <tr>
                <td><b>LSST id</b></td><td><b>Process</b></td><td><b>Version</b></td><td><b>Status</b></td><td><b>Start Time</b></td>
            </tr>

            <%-- Note use of concat in the query, the AS statement was not working otherwise 
            http://stackoverflow.com/questions/14431907/how-to-access-duplicate-column-names-with-jstl-sqlquery
            --%>
            
            <c:forEach items="${ccdList.rows}" var="ccd">
                <sql:query var="activityQuery">
                    SELECT Hardware.lsstId AS lsstId, concat(Process.name,'') as pName,
                    Process.version AS version,Activity.begin,Activity.end,activityFinalStatusId,concat(ActivityFinalStatus.name,'') AS fName from Activity,
                    TravelerType,Process,Hardware,ActivityFinalStatus where Activity.processId=TravelerType.id and 
                    Process.id=TravelerType.rootProcessId and Hardware.id=Activity.hardwareId and 
                    Hardware.lsstId="${ccd.lsstId}" and ActivityFinalStatus.id=Activity.activityFinalStatusId and Hardware.hardwareTypeId="${ccdHdwTypeId}" ORDER BY Activity.begin DESC
                </sql:query>
                    
                <c:forEach items="${activityQuery.rows}" var="row" begin="0" end="0"> 
                    <tr>
                        <td><c:out value="${row.lsstId}" /></td>
                        <td><c:out value="${row.pName}" /></td>
                        <td><c:out value="${row.version}" /></td>
                        <td><c:out value="${row.fName}" /></td>
                        <td><c:out value="${row.begin}" /></td>
                    </tr>
                </c:forEach> 

            </c:forEach>

        </table>



        <%-- 

                

         <h3>CCD Ids</h3>
            <display:table name="${ccdList.rows}" export="true" class="datatable"/>

         
--%> 







