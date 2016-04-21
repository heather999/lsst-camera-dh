<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Summary of Tests </title>
    </head>
    <body>
        <h1>Summary Of Tests  (page under construction)</h1>

        <%-- get a list of all the parentActivityIds --%> 
        <sql:query var="sensor" dataSource="jdbc/rd-lsst-cam-dev-ro">
            select hw.lsstId, act.id, act.parentActivityId, statusHist.activityStatusId, pr.name from Activity act join Hardware hw on act.hardwareId=hw.id 
            join Process pr on act.processId=pr.id join ActivityStatusHistory statusHist on act.id=statusHist.activityId 
            where statusHist.activityStatusId=1 and pr.name='test_report_offline' order by act.parentActivityId desc   
        </sql:query> 

        <p><c:out value="sensor count ${sensor.rowCount}"/></p>

        <c:choose>
            <c:when test="${empty param}">
                <display:table name = "${sensor.rows}" id="row" class="dataTable">
                    <display:column property="parentActivityId" title="ParentActivityId" href="SummaryReport.jsp" paramId="parentActivityId"/>
                    <display:column property="lsstId" title="lsstId"/>
                </display:table>
            </c:when>  
            <c:otherwise>
               <c:out value="No rows returned from queries"/>
            </c:otherwise>
        </c:choose>
</body>
</html>
