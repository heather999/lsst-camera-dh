<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib prefix="dp" tagdir="/WEB-INF/tags/dataportal"%>
<%@taglib prefix="ru" tagdir="/WEB-INF/tags/reports"%>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Sensor_Acceptance_Report_${param.lsstId} </title>
        <style>
            img {page-break-before: avoid;}
            h2.break {page-break-before: always;}
        </style>
    </head>
    <body>
        <fmt:setTimeZone value="UTC"/>
        <c:set var="debug" value="false"/>
        <c:set var="HaveTS3Data" value="false"/>
        <c:set var="HaveVendData" value="false"/>
        <c:set var="HaveMetSpreadsheet" value="false"/>

        <sql:query var="sensor">
            SELECT hw.lsstId, act.end, act.id, act.parentActivityId, statusHist.activityStatusId, pr.name FROM Activity act JOIN Hardware hw ON act.hardwareId=hw.id 
            JOIN Process pr ON act.processId=pr.id JOIN ActivityStatusHistory statusHist ON act.id=statusHist.activityId 
            WHERE hw.lsstId = ? AND statusHist.activityStatusId=1 AND pr.name='eotest_analysis' ORDER BY act.parentActivityId DESC   
            <sql:param value="${param.lsstId}"/>
        </sql:query> 
        <c:set var="lsstId" value="${sensor.rows[0].lsstId}"/>  
        <c:set var="actId" value="${sensor.rows[0].id}"/>  
        <c:set var="end" value="${sensor.rows[0].end}"/>  
        <c:set var="reportName" value="${sensor.rows[0].name}"/>

        <sql:query var="vendorData">
            SELECT hw.lsstId, act.end, act.id, act.parentActivityId, statusHist.activityStatusId, pr.name FROM Activity act JOIN Hardware hw ON act.hardwareId=hw.id 
            JOIN Process pr ON act.processId=pr.id JOIN ActivityStatusHistory statusHist ON act.id=statusHist.activityId 
            WHERE hw.lsstId = ? AND statusHist.activityStatusId=1 AND pr.name='vendorIngest' ORDER BY act.parentActivityId DESC   
            <sql:param value="${lsstId}"/>
        </sql:query> 

        <c:if test="${vendorData.rowCount>0}">
            <c:set var="vendActId" value="${vendorData.rows[0].parentActivityId}"/>
            <%-- vendActId = ${vendActId} since vendorData is ${vendorData.rowCount} --%>

            <c:set var="HaveVendData" value="true"/>
            <c:set var="SRRCV1end" value="${vendorData.rows[0].end}"/>  

            <%--
            vendActId = ${vendActId}
            ${HaveVendData}
            rowCount ${sensorVend.rowCount}
            --%>

        </c:if>

        <sql:query var="findTS3">
            SELECT hw.lsstId, act.id, act.parentActivityId, statusHist.activityStatusId, pr.name FROM Activity act JOIN Hardware hw on act.hardwareId=hw.id 
            JOIN Process pr ON act.processId=pr.id JOIN ActivityStatusHistory statusHist ON act.id=statusHist.activityId 
            WHERE hw.lsstId = ? AND statusHist.activityStatusId=1 AND pr.name='test_report' ORDER BY act.parentActivityId DESC  
            <sql:param value="${lsstId}"/>
        </sql:query>

        <%--  hw.lsstId = ${lsstId} --%>

        <c:if test="${findTS3.rowCount>0}">
            <c:set var="pActId2" value="${findTS3.rows[0].parentActivityId}"/>
            <%-- pActId2 = ${pActId2} since findTS3 is ${findTS3.rowCount} --%>
            <sql:query var="sensorTS3">
                select hw.lsstId, act.end, act.id, pr.name from Activity act 
                join Hardware hw on act.hardwareId=hw.id 
                join Process pr on act.processId=pr.id 
                join ActivityStatusHistory statusHist on act.id=statusHist.activityId 
                where statusHist.activityStatusId=1 and act.id = ?
                <sql:param value="${pActId2}"/>
            </sql:query> 
            <%-- query has rowCount ${sensorTS3.rowCount} --%>
            <c:if test="${sensorTS3.rowCount>0}">
                <c:set var="HaveTS3Data" value="true"/>
                <c:set var="SREOT01end" value="${sensorTS3.rows[0].end}"/>  
                <%--
                pActId2 = ${pActId2}
                ${HaveTS3Data}
                rowCount ${sensorTS3.rowCount}
                --%>
            </c:if>
        </c:if>

        <%-- Find Metrology Data --%>

        <%-- Peter's Spreadsheet --%>
        <sql:query var="metTS2Q">
            SELECT hw.lsstId, act.id, act.parentActivityId, statusHist.activityStatusId, pr.name FROM Activity act JOIN Hardware hw ON act.hardwareId=hw.id 
            JOIN Process pr ON act.processId=pr.id JOIN ActivityStatusHistory statusHist ON act.id=statusHist.activityId 
            WHERE hw.lsstId = ? AND statusHist.activityStatusId=1 AND pr.name='Record_BNL_Sensor_Report' ORDER BY act.parentActivityId DESC
            <sql:param value="${lsstId}"/>
        </sql:query> 
        <%-- Very few sensors have this traveler executed thus far --%>
        <c:if test="${metTS2Q.rowCount>0}">
            <c:set var="metSpreadActId" value="${metTS2Q.rows[0].id}"/>
            <sql:query var="metSpreadsheetQ" scope="page">
                SELECT creationTS, name, value, catalogKey, virtualPath FROM FilepathResultManual
                WHERE FilepathResultManual.activityId=? 
                <sql:param value="${metSpreadActId}"/>
            </sql:query>
            <c:if test="${metSpreadsheetQ.rowCount>0}">
                <c:set var="HaveMetSpreadsheet" value="true"/>
                <c:url var="metSpreadsheetLink" value="http://srs.slac.stanford.edu/DataCatalog/">
                    <c:param name="dataset" value="${metSpreadsheetQ.rows[0].catalogKey}"/>
                    <c:param name="experiment" value="LSST-CAMERA"/>
                </c:url>

            </c:if>

        </c:if>

        <%-- SR-MET-05 --%>

        <sql:query var="reports" dataSource="jdbc/config-prod">
            select id from report where name=?
            <sql:param value="${reportName}"/>
        </sql:query>
        <c:if test="${reports.rowCount==0}">
            Unknown report name ${reportName}
        </c:if>

        <c:if test="${reports.rowCount>0}">
            <c:set var="reportId" value="${reports.rows[0].id}"/>
            <c:set var="theMap" value="${portal:getReportValues(pageContext.session,actId,reportId)}"/>


            <c:if test="${debug}"> <%-- this doesn't seem to work any longer since the introduction of LinkedMap --%>
                <display:table name="${theMap.entrySet()}" id="theMap"/>  <%-- shows what's in the map --%> 
            </c:if>

            <div id="SensorAcceptanceReport" class="print">
                <%-- <h1>Summary Report for ${lsstId}</h1> --%>
                <h1>Sensor Acceptance Status ${lsstId}</h1>

                <c:if test="${HaveVendData}">
                    Generated SR-RCV-1 <fmt:formatDate value="${SRRCV1end}" pattern="yyy-MM-dd HH:mm z"/>
                    <br/>
                </c:if>

                Generated SR-EOT-02 <fmt:formatDate value="${end}" pattern="yyy-MM-dd HH:mm z"/>

                <c:if test="${HaveTS3Data}">
                    <br/>
                    Generated SR-EOT-01 <fmt:formatDate value="${SREOT01end}" pattern="yyy-MM-dd HH:mm z"/>
                </c:if>

                <br/><br/> <ru:printButton/>

                <sql:query var="sections" dataSource="jdbc/config-prod">
                    select section,title,displaytitle,extra_table,page_break from report_display_info where report=? 
                    <sql:param value="${reportId}"/>
                    <c:if test="${sectionNum == '1'}">
                        and displaytitle = 'Y' 
                    </c:if>
                    order by display_order asc 
                </sql:query>
                <%--<c:forEach var="sect" items="${sections.rows}">  --%>
                <h2>Summary</h2>
                <c:choose>
                    <c:when test="${HaveTS3Data}"> <%-- It is very likely this sensor has no TS3 data --%>
                        <c:set var="theMap2" value="${portal:getReportValues(pageContext.session,vendActId,reportId)}"/>
                        <c:choose>
                            <c:when test="${HaveVendData}"> 
                                <c:set var="theMapVend" value="${portal:getReportValues(pageContext.session,pActId2,reportId)}"/>
                                <dp:acceptance sectionNum="1" data="${theMap}" dataTS3="${theMap2}" dataVend="${theMapVend}" reportId="${reportId}"/>
                            </c:when>
                            <c:otherwise>
                                <dp:acceptance sectionNum="1" data="${theMap}" dataTS3="${theMap2}" reportId="${reportId}"/>
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:otherwise>
                        <c:choose>
                            <c:when test="${HaveVendData}"> 
                                <c:set var="theMapVend" value="${portal:getReportValues(pageContext.session,vendActId,reportId)}"/>
                                <dp:acceptance sectionNum="1" data="${theMap}" dataVend="${theMapVend}" reportId="${reportId}"/>
                            </c:when>
                            <c:otherwise>
                                <dp:acceptance sectionNum="1" data="${theMap}" reportId="${reportId}"/>
                            </c:otherwise>
                        </c:choose>
                    </c:otherwise>
                </c:choose>

                <%--
                <c:if test="${HaveMetSpreadsheet}">
                    <h2>Metrology</h2>

                    <a href="${metSpreadsheetLink}" target="_blank"><c:out value="TS2 Spreadsheet"/></a> 

                </c:if>
--%>
            </div>
        </c:if>
    </body>
</html>
