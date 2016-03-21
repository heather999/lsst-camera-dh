<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="display" uri="http://displaytag.sf.net" %>
<%@taglib prefix="portal" uri="WEB-INF/tags/portal.tld" %>
<%@taglib prefix="etraveler" tagdir="/WEB-INF/tags/eTrav"%>
<%@taglib prefix="filter" uri="http://srs.slac.stanford.edu/filter"%>

<html>
    <head>
        <title>Data & Reports/></title>
    </head>
    <body> 


        <h1>CCD Sensor Data and Reports</h1>

        <%-- This code ends up searching on HdwTypes 1, 9, 10 --%>
        <c:set var="ccdHdwTypeId" value="1" scope="page"/>  

        <%-- Determine the data source: Prod, Dev, or Test --%>
        <c:choose>
            <c:when test="${'Prod' == appVariables.dataSourceMode}">
                <c:set var="dataSourceFolder" value="Prod"/>
            </c:when>
            <c:when test="${'Dev' == appVariables.dataSourceMode}">
                <c:set var="dataSourceFolder" value="Dev"/>
            </c:when>
            <c:otherwise>
                <c:set var="dataSourceFolder" value="Test"/>
            </c:otherwise>
        </c:choose>

        <c:set var="moreOnlineFiles" value=""/>
        
        <c:set var="h_reportsTable" value="${portal:getReportsTable(pageContext.session,ccdHdwTypeId,dataSourceFolder,false)}" scope="session"/>

        <display:table name="${h_reportsTable}" export="true" defaultsort="2" defaultorder="descending" class="datatable" id="rep" >
            <display:column title="LSST_NUM" sortable="true">${rep.lsst_num}</display:column>
            <%-- <c:url var="explorerLink" value="oneComponent.jsp">
                 <c:param name="lsstIdValue" value="${rep.lsst_num}"/>
             </c:url>                
             <a href="${explorerLink}"><c:out value="${rep.lsst_num}"/></a>
         </display:column>
            --%>
            <display:column title="Date Registered" sortable="true" >${rep.creationDate}</display:column>
            <display:column title="Vendor Data" sortable="true" >
                <c:choose>
                    <c:when test="${rep.vendDataPath == 'NA'}">
                        <c:out value="NA"/>
                    </c:when>
                    <c:otherwise>
                        <c:url var="vendDataLink" value="http://srs.slac.stanford.edu/DataCatalog/">
                            <c:param name="folderPath" value="${rep.vendDataPath}"/>
                            <c:param name="experiment" value="LSST-CAMERA"/>
                        </c:url>
                        <a href="${vendDataLink}" target="_blank"><c:out value="${rep.vendDataPath}"/></a> 
                    </c:otherwise>
                </c:choose>
            </display:column>
            <display:column title="Most Recent SR-EOT-1 Test Report" sortable="true" >
                <c:choose>
                    <c:when test="${rep.testReportOnlineDirPath == 'NA'}">
                        <c:out value="NA"/>
                    </c:when>
                    <c:otherwise>
                        <c:url var="onlineReportLink" value="http://srs.slac.stanford.edu/DataCatalog/">
                            <c:param name="dataset" value="${rep.onlineReportCatKey}"/>
                            <c:param name="experiment" value="LSST-CAMERA"/>
                        </c:url>
                        <a href="${onlineReportLink}" target="_blank"><c:out value="${rep.testReportOnlinePath}"/></a> 
                        <br>
                        <c:url var="onlineDirLink" value="http://srs.slac.stanford.edu/DataCatalog/">
                            <c:param name="folderPath" value="${rep.testReportOnlineDirPath}"/>
                            <c:param name="experiment" value="LSST-CAMERA"/>
                        </c:url>
                        <a href="${onlineDirLink}" target="_blank"><c:out value="All Report Data"/></a>
                       
                        <c:if test="${rep.pastOnline == true}">
                            <br>
                            <a href="pastReports.jsp?row=${rep_rowNum}&lsstnum=${rep.lsst_num}&on=1">View Previous Reports</a>
                            
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </display:column>
            <display:column title="Most Recent SR-EOT-02 Test Report" sortable="true" >
                <c:choose>
                    <c:when test="${rep.testReportOfflineDirPath == 'NA'}">
                        <c:out value="NA"/>
                    </c:when>
                    <c:otherwise>
                        <c:url var="offlineReportLink" value="http://srs.slac.stanford.edu/DataCatalog/">
                            <c:param name="dataset" value="${rep.offlineReportCatKey}"/>
                            <c:param name="experiment" value="LSST-CAMERA"/>
                        </c:url>
                        <a href="${offlineReportLink}" target="_blank"><c:out value="${rep.testReportOfflinePath}"/></a> 
                        <br>
                        <c:url var="offlineDirLink" value="http://srs.slac.stanford.edu/DataCatalog/">
                            <c:param name="folderPath" value="${rep.testReportOfflineDirPath}"/>
                            <c:param name="experiment" value="LSST-CAMERA"/>
                        </c:url>
                        <a href="${offlineDirLink}" target="_blank"><c:out value="All Report Data"/></a>
                        <c:if test="${rep.pastOffline == true}">
                            <br>
                           
                            <a href="pastReports.jsp?row=${rep_rowNum}&lsstnum=${rep.lsst_num}&on=0">View Previous Reports</a>
                            
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </display:column>
            <display:setProperty name="export.excel.filename" value="sensorData.xls"/> 
            <display:setProperty name="export.csv.filename" value="sensorData.csv"/> 
            <display:setProperty name="export.xml.filename" value="sensorData.xml"/> 
        </display:table>


    </body>
</html>
