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
        <c:set var="HaveMet05Data" value="false"/>

        <sql:query var="sensor">
            SELECT act.hardwareId, hw.lsstId, act.end, act.id, act.parentActivityId, statusHist.activityStatusId, pr.name 
            FROM Activity act 
            JOIN Hardware hw ON act.hardwareId=hw.id 
            JOIN Process pr ON act.processId=pr.id 
            JOIN ActivityStatusHistory statusHist ON act.id=statusHist.activityId 
            WHERE hw.lsstId = ? AND statusHist.activityStatusId=1 AND pr.name='eotest_analysis' 
            ORDER BY act.parentActivityId DESC   
            <sql:param value="${param.lsstId}"/>
        </sql:query> 
        <c:set var="lsstId" value="${sensor.rows[0].lsstId}"/>  
        <c:set var="hdwId" value="${sensor.rows[0].hardwareId}"/>
        <c:set var="actId" value="${sensor.rows[0].id}"/>  
        <c:set var="end" value="${sensor.rows[0].end}"/>  
        <c:set var="reportName" value="${sensor.rows[0].name}"/>

        <sql:query var="vendorData">
            SELECT hw.lsstId, hw.manufacturer, act.end, act.id, act.parentActivityId, statusHist.activityStatusId, pr.name FROM Activity act JOIN Hardware hw ON act.hardwareId=hw.id 
            JOIN Process pr ON act.processId=pr.id JOIN ActivityStatusHistory statusHist ON act.id=statusHist.activityId 
            WHERE hw.lsstId = ? AND statusHist.activityStatusId=1 AND pr.name='vendorIngest' ORDER BY act.parentActivityId DESC   
            <sql:param value="${lsstId}"/>
        </sql:query> 

        <c:if test="${vendorData.rowCount>0}">
            <c:set var="vendActId" value="${vendorData.rows[0].parentActivityId}"/>
            <%-- vendActId = ${vendActId} since vendorData is ${vendorData.rowCount} --%>
            <c:set var="vendIngestActId" value="${vendorData.rows[0].id}"/>
            <c:set var="HaveVendData" value="true"/>
            <c:set var="SRRCV1end" value="${vendorData.rows[0].end}"/>  
            <c:set var="manu" value="${vendorData.rows[0].manufacturer}"/>
            <c:set var="vendReportName" value="${vendorData.rows[0].name}"/>

            <%-- Retrieve the vendor Report info for the config DB --%>

            <sql:query var="vendReports" dataSource="${appVariables.reportDisplayDb}">
                select id from report where name=?
                <sql:param value="${vendReportName}"/>
            </sql:query>
                <%--
            <c:if test="${vendReports.rowCount==0}">
                Unknown report name ${vendReportName}
            </c:if>
                --%>
            <c:if test="${vendReports.rowCount>0}">
                <c:set var="vendReportId" value="${vendReports.rows[0].id}"/>
            </c:if>

            <%--
            vendActId = ${vendActId}
            ${HaveVendData}
            rowCount ${sensorVend.rowCount}
            --%>

        </c:if>

        <sql:query var="findTS3">
            SELECT hw.lsstId, act.id, act.parentActivityId, statusHist.activityStatusId, pr.name 
            FROM Activity act 
            JOIN Hardware hw on act.hardwareId=hw.id 
            JOIN Process pr ON act.processId=pr.id 
            JOIN ActivityStatusHistory statusHist ON act.id=statusHist.activityId 
            WHERE hw.lsstId = ? AND statusHist.activityStatusId=1 AND pr.name='test_report' 
            ORDER BY act.parentActivityId DESC  
            <sql:param value="${lsstId}"/>
        </sql:query>

        <%--  hw.lsstId = ${lsstId} --%>

        <c:if test="${findTS3.rowCount>0}">
            <c:set var="pActId2" value="${findTS3.rows[0].parentActivityId}"/>
            <c:set var="TS3actId" value="${findTS3.rows[0].id}"/>
           <%-- TS3actId = ${TS3actId} --%>
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
                
                 <sql:query var="eotestTS3VerQ">
                SELECT name, value FROM StringResultHarnessed 
                WHERE activityId=? AND name="eotest_version"
                <sql:param value="${TS3ActId}"/>
            </sql:query>
                <c:if test="${eotestTS3VerQ.rowCount>0}">
                    <c:set var="eotestTS3Version" value="${eotestTS3VerQ.rows[0].value}"/>
                    eotestTS3Version = ${eotestTS3Version}
                </c:if>
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
        
        
        <sql:query var="findMet05">  <%-- Vendor-LSST --%>
            SELECT hw.lsstId, act.id, act.parentActivityId, statusHist.activityStatusId, pr.name 
            FROM Activity act 
            JOIN Hardware hw on act.hardwareId=hw.id 
            JOIN Process pr ON act.processId=pr.id 
            JOIN ActivityStatusHistory statusHist ON act.id=statusHist.activityId 
            WHERE hw.lsstId = ? AND statusHist.activityStatusId=1 AND pr.name='absolute_height_offline' 
            ORDER BY act.parentActivityId DESC  
            <sql:param value="${lsstId}"/>
        </sql:query>
            
        <c:if test="${findMet05.rowCount>0}">
            <c:set var="met05ParentActId" value="${findMet05.rows[0].parentActivityId}"/>
            <c:set var="met05ActId" value="${findMet05.rows[0].id}"/>
            <c:set var="HaveMet05Data" value="true"/>
        </c:if>
            

        <sql:query var="reports" dataSource="${appVariables.reportDisplayDb}">
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

            <%-- Construct eT hdw page link --%>
            <c:url var="hdwLink" value="http://lsst-camera.slac.stanford.edu/eTraveler/exp/LSST-CAMERA/displayHardware.jsp">
                <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
                <c:param name="hardwareId" value="${hdwId}"/>
            </c:url>

            <div id="SensorAcceptanceReport" class="print">
                <h1>Sensor Acceptance Status <a href="${hdwLink}" target="_blank"><c:out value="${lsstId}"/></a></h1>

                <c:if test="${HaveVendData}">
                    Generated Vendor-Vendor <fmt:formatDate value="${SRRCV1end}" pattern="yyy-MM-dd HH:mm z"/>
                    <br/>
                    <br/>
                </c:if>

                Generated Vendor-LSST <fmt:formatDate value="${end}" pattern="yyy-MM-dd HH:mm z"/>
                        <font color="purple">
                        &nbsp;&nbsp;&nbsp;&nbsp
                        <b>eotest Version: <c:out value="${param.eotestVer}"/></b>
                    </font>

                <c:if test="${HaveTS3Data}">
                    <br/>
                    Generated LSST-LSST <fmt:formatDate value="${SREOT01end}" pattern="yyy-MM-dd HH:mm z"/>
                    
                        <font color="purple">
                        &nbsp;&nbsp;&nbsp;&nbsp
                        <b>eotest Version: <c:out value="${param.ts3eotestVer}"/></b>
                    </font>
                    <br/>
                </c:if>

                <br/><br/> <ru:printButton/>

                <sql:query var="sections" dataSource="${appVariables.reportDisplayDb}">
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
                        <c:set var="theMap2" value="${portal:getReportValues(pageContext.session,pActId2,reportId)}"/>
                        <c:choose>
                            <c:when test="${HaveVendData}"> 
                                <c:set var="theMapVend" value="${portal:getSensorReportValues(pageContext.session,vendActId,vendReportName)}"/>
                                <dp:acceptance sectionNum="1" data="${theMap}" dataTS3="${theMap2}" dataVend="${theMapVend}" reportId="${reportId}" vendReportId="${vendReportId}"/>
                            </c:when>
                            <c:otherwise>
                                <dp:acceptance sectionNum="1" data="${theMap}" dataTS3="${theMap2}" reportId="${reportId}"/>
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:otherwise>
                        <c:choose>
                            <c:when test="${HaveVendData}"> 
                                <c:set var="theMapVend" value="${portal:getSensorReportValues(pageContext.session,vendActId,vendReportName)}"/>
                                <dp:acceptance sectionNum="1" data="${theMap}" dataVend="${theMapVend}" reportId="${reportId}" vendReportId="${vendReportId}"/>
                            </c:when>
                            <c:otherwise>
                                <dp:acceptance sectionNum="1" data="${theMap}" reportId="${reportId}"/>
                            </c:otherwise>
                        </c:choose>
                    </c:otherwise>
                </c:choose>

                <%-- Add MET Table here for now  ITL only currently --%>
                <c:if test="${HaveVendData}">
                              <%-- && manu == 'ITL'}"> --%>
                    <c:set var="tempMetData" value="${portal:getMetReportValues(pageContext.session,manu,vendActId,HaveMet05Data,met05ParentActId)}"/>

                    <display:table name="${tempMetData}" export="true" class="datatable" id="met" >

                        <display:column title="Spec Id." sortable="true" >${met.specId}</display:column>
                        <display:column title="Description" sortable="true" >${met.vendvendDescription}</display:column>
                        <display:column title="Specification" sortable="true" >${met.vendvendSpecification}</display:column>
                        <display:column title="Vendor-Vendor" sortable="true" >${met.vendorVendor}</display:column>
                        <display:column title="Status" sortable="true" >
                              ${empty met.vendvendStat ? "..." : met.vendvendStat ? '<font color="green">&#x2714;</span>' : '<font color="red">&#x2718;<span>'}
                        </display:column>
                        <display:column title="Spec" sortable="true" >${met.vendlsstSpecification}</display:column>
                        <display:column title="Vendor-LSST" sortable="true" >${met.vendorLsst}</display:column>
                        <display:column title="Status" sortable="true" >
                              ${empty met.vendlsstStat ? "..." : met.vendlsstStat ? '<font color="green">&#x2714;</span>' : '<font color="red">&#x2718;<span>'}
                        </display:column>
                        <display:column title="LSST-LSST" sortable="true" >${met.lsstLsst}</display:column>
                        <display:column title="Status" sortable="true" >...
                              <%--${empty met.lsstlsstStat ? "..." : met.lsstlsstStat ? '<font color="green">&#x2714;</span>' : '<font color="red">&#x2718;<span>'}--%>
                        </display:column>
                    </display:table>


                </c:if>
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
