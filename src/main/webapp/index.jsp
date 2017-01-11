<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="display" uri="http://displaytag.sf.net" %>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>
<%@taglib prefix="filter" uri="http://srs.slac.stanford.edu/filter"%>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib prefix="dp" tagdir="/WEB-INF/tags/dataportal"%>

<html>
    <head>
        <title>Home</title>
    </head>
    <body> 
        <h1>Quick Links</h1>

        <h2>General Links</h2>
        <ul>
            <dp:url var="runsLink" value="/runList.jsp"/>
            <li> <a href="${runsLink}" title="Run by Run list" style=""><strong>Run by Run list with links to reports</strong></a></li>
            <dp:url var="devicesLink" value="/deviceList.jsp"/>
            <li> <a href="${devicesLink}" title="Device list" style=""><strong>Device list with links to reports</strong></a></li>
        </ul>

        <ul>
            <dp:url var="actStatusLink" value="/activityStatus.jsp"/>
            <li><a href="${actStatusLink}" title="Activity Status" style=""><strong>Recent activity</strong></a></li>
            <dp:url var="ncrStatusLink" value="/ncrStatus.jsp"/>
            <li><a href="${ncrStatusLink}" title="NCR Status" style=""><strong>NCR Status</strong></a></li>
        </ul>  

        <h2>CCD Links</h2>
        <dp:url var="ccdStatusLink" value="/ccdStatus.jsp"/>
        <dp:url var="ccdExplorerLink" value="/oneComponent.jsp"/>
        <dp:url var="crExplorerLink" value="/oneCrComponent.jsp"/>
        <dp:url var="crStatusLink" value="/crStatus.jsp"/>
        <dp:url var="reportsLink" value="/reports.jsp"/>
        <dp:url var="acceptanceReportLink" value="/SensorAcceptance.jsp"/>
        <dp:url var="sensorDevices" value="/deviceList.jsp?Type=3&submit=Filter"/>
        <ul>   

            <li><a href="${ccdStatusLink}" title="Science Raft CCD Overview" style=""><strong>Science Raft CCD Overview</strong></a></li>

            <li><a href="${ccdExplorerLink}" title="Science Raft CCD Explorer" style=""><strong>Science Raft CCD Explorer</strong></a></li>

            <li> <a href="${reportsLink}" title="Science Raft CCD Data and Reports" style=""><strong>Science Raft CCD Data and Reports</strong></a></li>
            <li> <a href="${acceptanceReportLink}" title="Sensor Acceptance" style=""><strong>Sensor Acceptance</strong></a> (or see <a href="${sensorDevices}"><strong>Device list filtered by CCD</strong>)</a></li>

        </ul>

        <ul>
            <li><a href="${crStatusLink}" title="Corner Raft CCD Overview" style=""><strong>Corner Raft CCD Overview</strong></a></li>

            <li><a href="${crExplorerLink}" title="Corner Raft CCD Explorer" style=""><strong>Corner Raft CCD Explorer</strong></a></li>
        </ul>


        <h2>ASPIC Links</h2>


        <dp:url var="aspicLink" value="/aspicStatus.jsp"/>
        <ul>
            <li><a href="${aspicLink}" title="ASPICs" style=""><strong>Overview All ASPICs</strong></a></li>
        </ul>

        <h2> Data Catalog File Search </h2>


        <filter:filterTable>
            <filter:filterInput var="fileSearchStr" title="Filename (substring search)"/>
            <filter:filterSelection title="Use REGEX" var="regex" defaultValue="">
                <filter:filterOption value="">false</filter:filterOption>
                <filter:filterOption value="true">true</filter:filterOption>
            </filter:filterSelection>
        </filter:filterTable>


        <c:choose>
            <c:when test="${empty fileSearchStr}">
                Enter a substring if you wish to search the Data Catalog.
                The % character can be used as a wildcard, unless you choose to use a regular expression.
            </c:when>
            <c:otherwise>
                Enter a substring if you wish to search the Data Catalog.
                The % character can be used as a wildcard, unless you choose to use a regular expression.
                <c:set var="dcQuery" value="${portal:getDataCatalogFiles(pageContext.session, fileSearchStr, regex)}"/>
                <c:if test="${! empty dcQuery}">
                    <display:table name="${dcQuery}" id="row" export="true" class="datatable">
                        <display:column title="Data Catalog Link" sortable="true" headerClass="sortable">
                            <c:choose>
                                <c:when test="${empty row.catalogKey}">
                                    <%-- <c:out value="${row.value}"/> --%>
                                </c:when>
                                <c:otherwise>
                                    <c:url var="dcLink" value="http://srs.slac.stanford.edu/DataCatalog/">
                                        <c:param name="dataset" value="${row.catalogKey}"/>
                                        <c:param name="experiment" value="LSST-CAMERA"/>
                                    </c:url>
                                    <a href="${dcLink}" target="_blank"><c:out value="${row.virtualPath}"/></a>
                                </c:otherwise>
                            </c:choose>
                        </display:column>
                        <display:column property="creationDate" title="Timestamp" sortable="true" headerClass="sortable"/>
                    </display:table>
                </c:if>
            </c:otherwise>
        </c:choose>
    </body>
</html>
