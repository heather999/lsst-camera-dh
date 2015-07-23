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
    <title>CCD Overview</title>
</head>

<%-- Select CCD as the HardwareType for this page, scope session means all the pages? set scope to page --%>
<c:set var="ccdHdwTypeId" value="1" scope="page"/>  
<sql:query  var="ccdList"  >
    select  Hardware.id,Hardware.lsstId from Hardware,HardwareType where Hardware.hardwareTypeId=HardwareType.id and (HardwareType.id=? OR HardwareType.id=9 OR HardwareType.id=10) 
    <sql:param value="${ccdHdwTypeId}"/>
</sql:query>

<%-- <display:table name="${ccdList.rows}" export="true" class="datatable"/> --%>

<h1>CCD Current Status and Location</h1>
<c:set var="hdwStatLocTable" value="${portal:getHdwStatLocTable(pageContext.session,ccdHdwTypeId)}"/>

<display:table name="${hdwStatLocTable}" export="true" class="datatable" id="hdl" >
    <%-- <display:column title="LsstId" sortable="true" >${hdl.lsstId}</display:column> --%>
    <display:column title="LsstId" sortable="true">
        <c:url var="explorerLink" value="oneComponent.jsp">
            <c:param name="lsstIdValue" value="${hdl.lsstId}"/>
        </c:url>                
        <a href="${explorerLink}"><c:out value="${hdl.lsstId}"/></a>
    </display:column>
    <display:column title="Date Registered" sortable="true" >${hdl.creationDate}</display:column>
    <display:column title="Overall Component Status" sortable="true" >${hdl.status}</display:column>
    <display:column title="Site" sortable="true" >${hdl.site}</display:column>
    <display:column title="Location" sortable="true" >${hdl.location}</display:column>
    <display:column title="Current Traveler" sortable="true" >${hdl.curTravelerName}</display:column>
    <display:column title="Current Process Step" sortable="true" >${hdl.curActivityProcName}</display:column>
    <display:column title="Current Process Step Status" sortable="true" >${hdl.curActivityStatus}</display:column>
    <display:column title="Most Recent Timestamp" sortable="true" >${hdl.curActivityLastTime}</display:column>
    <display:column title="NCR" sortable="true" >${hdl.inNCR}</display:column>
</display:table>
<%--
  <display:column title="Traveler Elasped Time (s)" sortable="true" >${hdl.elapsedTravTime}</display:column> 
  --%>
  
  

  <%-- The table below is superceded by the content above
<h1>CCD Most Recent Process Step Status</h1>


<jsp:useBean id="aL" class="org.lsst.camera.portal.data.DataList" scope="page" />
-%>

<%-- Note use of concat in the query, the AS statement was not working otherwise 
http://stackoverflow.com/questions/14431907/how-to-access-duplicate-column-names-with-jstl-sqlquery
--%>

<%--
<c:forEach items="${ccdList.rows}" var="ccd">
    <sql:query var="activityQuery">
        SELECT H.lsstId, concat(P.name,'') as process, A.processId, A.inNCR,
        P.version AS version,A.begin,A.end,concat(AFS.name,'') as status
        FROM Hardware H, Process P, 
        Activity A INNER JOIN ActivityStatusHistory on ActivityStatusHistory.activityId=A.id and 
        ActivityStatusHistory.id=(select max(id) from ActivityStatusHistory where activityId=A.id)
        INNER JOIN ActivityFinalStatus AFS on AFS.id=ActivityStatusHistory.activityStatusId
        WHERE H.id=A.hardwareId AND H.lsstId="${ccd.lsstId}" AND 
        (H.hardwareTypeId="${ccdHdwTypeId}" OR H.hardwareTypeId=9 OR H.hardwareTypeId=10) AND P.id=A.processId
        ORDER BY A.id DESC LIMIT 1
    </sql:query>

    <c:forEach items="${activityQuery.rows}" var="row" begin="0" end="0"> 
        <jsp:setProperty name="aL" property="child" value="${row}" />
    </c:forEach> 

</c:forEach>


<display:table name="${aL}" export="true" class="datatable" id="mainTable"> 
    <display:column title="LsstId" sortable="true"> <c:out value="${mainTable.lsstId}"/> </display:column> 
    <display:column title="Most Recent Process" sortable="true"> <c:out value="${mainTable.process}"/> </display:column> 
    <display:column title="Version" sortable="true"> <c:out value="${mainTable.version}"/> </display:column> 
    <display:column title="Status" sortable="true"> <c:out value="${mainTable.status}"/> </display:column> 
    <display:column title="Start Time" sortable="true"> <c:out value="${mainTable.begin}"/> </display:column>
    <display:column title="End Time" sortable="true"> <c:out value="${mainTable.end}"/> </display:column>
    <display:column title="inNCR" sortable="true"> <c:out value="${mainTable.inNCR}"/> </display:column>
</display:table>


--%>
