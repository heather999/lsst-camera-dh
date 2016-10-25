<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="display" uri="http://displaytag.sf.net" %>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>
<%@taglib prefix="filter" uri="http://srs.slac.stanford.edu/filter"%>

<html>
    <head>
        <title>Home</title>
    </head>
    <body> 
        <h1>Sensor Quick Links</h1>


        <c:url var="ccdStatusLink" value="/ccdStatus.jsp">
            <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
        </c:url>
        <c:url var="ccdExplorerLink" value="/oneComponent.jsp">
            <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
        </c:url>
        <c:url var="reportsLink" value="/reports.jsp">
            <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
        </c:url>
        <c:url var="actStatusLink" value="/activityStatus.jsp">
            <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
        </c:url>
        <c:url var="availReportLink" value="/AvailableReports.jsp">
            <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
        </c:url>
        <ul>   

            <li><a href="${ccdStatusLink}" title="CCD Status" style=""><strong>Overview All CCDs</strong></a></li>

            <li><a href="${ccdExplorerLink}" title="CCD Explorer" style=""><strong>CCD Explorer</strong></a></li>

            <%-- <li><a href="/DataPortal/eTravelerPortal.jsp" title "eTraveler Portal" style=""><strong>eTraveler Portal</strong></a></li> --%>
            <li> <a href="${reportsLink}" title "Data and Reports" style=""><strong>Data and Reports</strong></a></li>
            <li> <a href="${availReportLink}" title "Web Reports" style=""><strong>Web Reports</strong></a></li>
            <li><a href="${actStatusLink}" title="Activity Status" style=""><strong>All eTraveler Activity Status</strong></a></li>

        </ul>   

        <section>

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


        </section>



    </body>
</html>
