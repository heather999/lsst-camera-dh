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
    <title>CCD Status</title>
</head>
<%-- Select CCD as the HardwareType for this page, scope session means all the pages? set scope to page --%>
<c:set var="ccdHdwTypeId" value="1" scope="session"/>  
<sql:query  var="ccdList"  >
    select  Hardware.id,Hardware.lsstId from Hardware,HardwareType where Hardware.hardwareTypeId=HardwareType.id and HardwareType.id=? 
    <sql:param value="${ccdHdwTypeId}"/>
</sql:query>

<%-- <display:table name="${ccdList.rows}" export="true" class="datatable"/> --%>

<h1>CCD Most Recent Process Status</h1>


<jsp:useBean id="aL" class="org.lsst.camera.portal.data.DataList" scope="page" />


    <%-- Note use of concat in the query, the AS statement was not working otherwise 
    http://stackoverflow.com/questions/14431907/how-to-access-duplicate-column-names-with-jstl-sqlquery
    --%>

    <c:forEach items="${ccdList.rows}" var="ccd">
        <sql:query var="activityQuery">
            SELECT Hardware.lsstId, concat(Process.name,'') as Process, Activity.inNCR,
            Process.version AS version,Activity.begin,Activity.end,concat(ActivityFinalStatus.name,'') AS Status from Activity,
            TravelerType,Process,Hardware,ActivityFinalStatus where Activity.processId=TravelerType.id and 
            Process.id=TravelerType.rootProcessId and Hardware.id=Activity.hardwareId and 
            Hardware.lsstId="${ccd.lsstId}" and ActivityFinalStatus.id=Activity.activityFinalStatusId and Hardware.hardwareTypeId="${ccdHdwTypeId}" ORDER BY Activity.begin DESC
        </sql:query>

        <c:forEach items="${activityQuery.rows}" var="row" begin="0" end="0"> 
            <%-- <tr>
                <td><c:out value="${row.lsstId}" /></td> --%>
                <jsp:setProperty name="aL" property="child" value="${row}" />
            <%-- </tr> --%>
        </c:forEach> 

    </c:forEach>

<%-- </table> --%>
    

<display:table name="${aL}" export="true" class="datatable" id="mainTable"> 
     <display:column title="LsstId" sortable="true"> <c:out value="${mainTable.lsstId}"/> </display:column> 
     <display:column title="Most Recent Process" sortable="true"> <c:out value="${mainTable.Process}"/> </display:column> 
     <display:column title="Version" sortable="true"> <c:out value="${mainTable.version}"/> </display:column> 
     <display:column title="Status" sortable="true"> <c:out value="${mainTable.Status}"/> </display:column> 
     <display:column title="Start Time" sortable="true"> <c:out value="${mainTable.begin}"/> </display:column>
     <display:column title="End Time" sortable="true"> <c:out value="${mainTable.end}"/> </display:column>
     <display:column title="inNCR" sortable="true"> <c:out value="${mainTable.inNCR}"/> </display:column>
    <%-- <display:column title="Serial #" >${aL.lsstId}</display:column> --%>
</display:table>




<h1>CCD Current Status and Location</h1>

<table border="1">
    <tr>
        <td><b>LSST id</b></td><td><b>Status</b></td><td><b>Location</b></td>
    </tr>


    <c:forEach items="${ccdList.rows}" var="ccd">
        <sql:query var="hwStatusQuery">
            SELECT Hardware.lsstId,HardwareStatus.name, HardwareStatusHistory.hardwareStatusId from Hardware, HardwareStatusHistory, HardwareStatus
            where Hardware.id=HardwareStatusHistory.hardwareId and HardwareStatus.id = HardwareStatusHistory.hardwareStatusId and
            Hardware.lsstId="${ccd.lsstId}" and Hardware.hardwareTypeId="${ccdHdwTypeId}" order By HardwareStatusHistory.creationTS DESC
        </sql:query>
        <tr>
            <c:forEach items="${hwStatusQuery.rows}" var="row" begin="0" end="0"> 
                <td><c:out value="${row.lsstId}" /></td>
                <td><c:out value="${row.name}" /></td>          
            </c:forEach> 

            <sql:query var="locQuery">
                SELECT Hardware.lsstId, Location.name, HardwareLocationHistory.locationId from Hardware, HardwareLocationHistory, Location
                where Hardware.id=HardwareLocationHistory.hardwareId and Location.id = HardwareLocationHistory.locationId and
                Hardware.lsstId="${ccd.lsstId}" and Hardware.hardwareTypeId="${ccdHdwTypeId}" order By HardwareLocationHistory.creationTS DESC
            </sql:query>

            <c:forEach items="${locQuery.rows}" var="row" begin="0" end="0"> 
                 <td><c:out value="${row.name}" /></td> 
            </c:forEach> 
                
          
        </tr>
    </c:forEach>

</table>        

<%--
<display:table name="${hdwStatLocList}" export="true" class="datatable" id="hdwStatLocTable"> 
     <display:column title="LsstId" sortable="true"> <c:out value="${hdwStatLocTable.lsstId}"/> </display:column> 
     <display:column title="Status" sortable="true"> <c:out value="${hdwStatLocTable.status}"/> </display:column> 
     <display:column title="Current Location" sortable="true"> <c:out value="${hdwStatLocTable.location}"/> </display:column>
</display:table>
--%>






