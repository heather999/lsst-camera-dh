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
        <title>Sensor Acceptance Reports Available</title>
    </head>
    <body>
        <h1>Sensor Acceptance Reports Available</h1>

        <%-- get a list of all the parentActivityIds --%> 
        <%-- For eotesting on Vendor Data --%>
        <sql:query var="vendorData">
            select hw.lsstId, act.id, act.parentActivityId, statusHist.activityStatusId, pr.name from Activity act join Hardware hw on act.hardwareId=hw.id 
            join Process pr on act.processId=pr.id join ActivityStatusHistory statusHist on act.id=statusHist.activityId 
            where statusHist.activityStatusId=1 and pr.name='vendorIngest' order by act.parentActivityId desc   
        </sql:query> 
            
        <sql:query var="sensor02">
            select hw.lsstId, act.id, act.parentActivityId, statusHist.activityStatusId, pr.name from Activity act join Hardware hw on act.hardwareId=hw.id 
            join Process pr on act.processId=pr.id join ActivityStatusHistory statusHist on act.id=statusHist.activityId 
            where statusHist.activityStatusId=1 and pr.name='test_report_offline' order by act.parentActivityId desc   
        </sql:query> 
            
        

        <display:table name = "${sensor02.rows}" id="row" class="datatable" defaultsort="2">
            <display:column title="Activity" sortable="true" class="sortable" >
                <c:url var="acceptanceLink" value="SensorAcceptanceReport.jsp">
                    <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
                    <c:param name="parentActivityId" value="${row.parentActivityId}"/>
                    <c:param name="lsstId" value="${row.lsstId}"/>
                </c:url>
                <a href="${acceptanceLink}" target="_blank"><c:out value="${row.parentActivityId}"/></a>
            </display:column>
            <%-- <display:column property="parentActivityId" title="Activity" href="SensorAcceptanceReport.jsp" paramId="parentActivityId" sortable="true" class="sortable"/> --%>
            <display:column property="lsstId" title="Sensor" sortable="true" class="sortable"/>
        </display:table>

    </body>
</html>
