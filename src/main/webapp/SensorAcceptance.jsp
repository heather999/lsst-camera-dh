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
        <%--
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
            --%>
        

            <c:set var="sensorsWithAcceptance" value="${portal:getSensorAcceptanceTable(pageContext.session)}"/>

            <display:table name="${sensorsWithAcceptance}" export="true" class="datatable" id="sen" defaultsort="1" >
                <display:column title="Sensor" sortProperty="lsstId" sortable="true" class="sortable" >
                    <c:url var="acceptanceLink" value="SensorAcceptanceReport.jsp">
                        <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
                        <c:param name="parentActivityId" value="${sen.parentActId}"/>
                        <c:param name="lsstId" value="${sen.lsstId}"/>
                        <c:param name="eotestVer" value="${sen.vendorEoTestVer}"/>
                        <c:param name="ts3eotestVer" value="${sen.ts3EoTestVer}"/>
                    </c:url>
                    <a href="${acceptanceLink}" target="_blank"><c:out value="${sen.lsstId}"/></a>
                </display:column>
                <display:column title="Ingest" sortable="true" >${sen.vendorIngestDate}</display:column>
                <display:column title="Vendor-LSST<br/>eotest Ver" sortable="true" >${sen.sreot2Date}<br>${sen.vendorEoTestVer}</display:column>
                <display:column title="LSST-LSST<br/>eotest Ver" sortable="true" >${sen.ts3EoTestVer}</display:column>
            </display:table>

    </body>
</html>
