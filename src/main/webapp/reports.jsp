<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="display" uri="http://displaytag.sf.net" %>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>
<%@taglib prefix="etraveler" tagdir="/WEB-INF/tags/eTrav"%>
<%@taglib prefix="filter" uri="http://srs.slac.stanford.edu/filter"%>

<html>
    <head>
        <title>Data & Reports/></title>
    </head>
    <body> 


        <h1>Science Raft CCD Sensor Data and Reports</h1>


        <c:set var="repGroupName" value="Generic-CCD" scope="page"/>

        <c:set var="hdwTypeString" value="${portal:getHardwareTypesFromGroup(pageContext.session,repGroupName)}" scope="page"/>

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
        
        <sql:query var="manufacturerQ" scope="page">
        SELECT DISTINCT manufacturer FROM Hardware, HardwareType where Hardware.hardwareTypeId=HardwareType.id AND HardwareType.id IN ${hdwTypeString} ORDER BY manufacturer;
    </sql:query>
        
           <sql:query var="labelQ" scope="page">
        SELECT DISTINCT name, HardwareStatus.id FROM HardwareStatus INNER JOIN HardwareStatusHistory ON HardwareStatus.id = HardwareStatusHistory.hardwareStatusId 
        INNER JOIN Hardware ON Hardware.id = HardwareStatusHistory.hardwareId AND Hardware.hardwareTypeId IN ${hdwTypeString}
        WHERE isStatusValue=0 ORDER BY name;
    </sql:query>

    
    <filter:filterTable>
        <filter:filterInput var="lsst_num" title="LSST_NUM (substring search)"/>
        <filter:filterSelection title="Manufacturer" var="manu" defaultValue="any">
            <filter:filterOption value="any">Any</filter:filterOption>
                <c:forEach var="hdw" items="${manufacturerQ.rows}">
                <filter:filterOption value="${hdw.manufacturer}"><c:out value="${hdw.manufacturer}"/></filter:filterOption>
                </c:forEach>
        </filter:filterSelection>
        <filter:filterSelection title="Labels" var="labelsChosen" defaultValue="0">
            <filter:filterOption value="0">Any</filter:filterOption>
            <c:forEach var="label" items="${labelQ.rows}">
                <filter:filterOption value="${label.id}"><c:out value="${label.name}"/></filter:filterOption>
                </c:forEach>                        
        </filter:filterSelection>
    </filter:filterTable>

        

        <%-- ccdHdwTypeId --%>
        <c:set var="h_reportsTable" value="${portal:getReportsTable(pageContext.session,repGroupName,dataSourceFolder,false,lsst_num,manu,labelsChosen)}" scope="session"/>

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
                        <a href="${vendDataLink}" target="_blank"><c:out value="Most Recent Vendor Data"/></a> 
                    </c:otherwise>
                </c:choose>
            </display:column>
            <display:column title="SR-EOT-02 Test Report Using Vendor Data" sortable="true" >
                <c:choose>
                    <c:when test="${rep.testReportOfflineDirPath == 'NA'}">
                        <c:out value="NA"/>
                    </c:when>
                    <c:otherwise>
                        <c:url var="offlineReportLink" value="http://srs.slac.stanford.edu/DataCatalog/">
                            <c:param name="dataset" value="${rep.offlineReportCatKey}"/>
                            <c:param name="experiment" value="LSST-CAMERA"/>
                        </c:url>
                        <a href="${offlineReportLink}" target="_blank"><c:out value="Most Recent Report"/></a> 
                        <br>
                        <c:url var="offlineDirLink" value="http://srs.slac.stanford.edu/DataCatalog/">
                            <c:param name="folderPath" value="${rep.testReportOfflineDirPath}"/>
                            <c:param name="experiment" value="LSST-CAMERA"/>
                            <c:param name="showFileList" value="true"/>
                        </c:url>
                        <a href="${offlineDirLink}" target="_blank"><c:out value="All Report Data"/></a>
                        <c:if test="${rep.pastOffline == true}">
                            <br>

                            <a href="pastReports.jsp?row=${rep_rowNum}&lsstnum=${rep.lsst_num}&on=0">View Previous Reports</a>

                        </c:if>
                    </c:otherwise>
                </c:choose>
            </display:column>
            <display:column title="SR-EOT-1 TS3 Test Report" sortable="true" >
                <c:choose>
                    <c:when test="${rep.testReportOnlineDirPath == 'NA'}">
                        <c:out value="NA"/>
                    </c:when>
                    <c:otherwise>
                        <c:url var="onlineReportLink" value="http://srs.slac.stanford.edu/DataCatalog/">
                            <c:param name="dataset" value="${rep.onlineReportCatKey}"/>
                            <c:param name="experiment" value="LSST-CAMERA"/>
                        </c:url>
                        <a href="${onlineReportLink}" target="_blank"><c:out value="Most Recent Report"/></a> 
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
            <display:setProperty name="export.excel.filename" value="sensorData.xls"/> 
            <display:setProperty name="export.csv.filename" value="sensorData.csv"/> 
            <display:setProperty name="export.xml.filename" value="sensorData.xml"/> 
        </display:table>


    </body>
</html>
