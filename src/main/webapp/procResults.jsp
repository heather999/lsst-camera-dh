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

<html>
    <head>
        <title>Detailed Results <c:out value="${param.activityId}"/></title>
    </head>
    <body> 

    <etraveler:jhResultWidget activityId="${param.activityId}" processName="${param.process}" version="${param.version}"/>

    
    <h1>Output ${param.travName} ${param.process} Version ${param.version}</h1>
<%-- Find Data Catalog Files --%>
    <sql:query var="outQuery" scope="page">
        SELECT creationTS, name, value, catalogKey, schemaName, schemaVersion, schemaInstance, virtualPath FROM FilepathResultHarnessed 
        WHERE FilepathResultHarnessed.activityId=?<sql:param value="${param.activityId}"/>
    </sql:query>
    <c:if test="${outQuery.rowCount>0}" >
        <c:set var="exportFileNameXls" scope="page" value="${param.process}_v${param.version}_jhFiles.xml"/>
        <c:set var="exportFileNameCsv" scope="page" value="${param.process}_v${param.version}_jhFiles.csv"/>
        <c:set var="exportFileNameXls" scope="page" value="${param.process}_v${param.version}_jhFiles.xml"/>
        <display:table name="${outQuery.rows}" id="row" export="true" class="datatable">
            <display:column property="schemaName" title="Schema" sortable="true" headerClass="sortable"/>
            <display:column property="schemaVersion" title="Version" sortable="true" headerClass="sortable"/>
            <display:column property="name" title="Name" sortable="true" headerClass="sortable"/>
            <display:column property="schemaInstance" title="Instance" sortable="true" headerClass="sortable"/>
            <display:column title="Path" sortable="true" headerClass="sortable">
                <c:choose>
                    <c:when test="${empty row.catalogKey}">
                        <c:out value="${row.value}"/>
                    </c:when>
                    <c:otherwise>
                        <c:set var="curPath" value="${portal:truncateString(row.virtualPath,'/')}" scope="page"/>
                        <c:url var="dcLink" value="http://srs.slac.stanford.edu/DataCatalog/">
                            <%-- <c:param name="dataset" value="${row.catalogKey}"/> --%>
                            <c:param name="folderPath" value="${curPath}"/>
                            <c:param name="experiment" value="LSST-CAMERA"/>
                            <c:param name="showFileList" value="true"/>
                        </c:url>
                        <a href="${dcLink}" target="_blank"><c:out value="${row.virtualPath}"/></a>
                    </c:otherwise>
                </c:choose>
            </display:column>
            <display:column property="creationTS" title="Timestamp" sortable="true" headerClass="sortable"/>
            <display:setProperty name="export.excel.filename" value="${exportFileNameXls}"/> 
            <display:setProperty name="export.csv.filename" value="${exportFileNameCsv}"/> 
            <display:setProperty name="export.xml.filename" value="${exportFileNameXml}"/> 
        </display:table>

    </c:if>

<%-- Locate any other output files --%>
    <sql:query var="outManualQuery" scope="page">
        SELECT creationTS, name, value, catalogKey, virtualPath FROM FilepathResultManual
        WHERE FilepathResultManual.activityId=?<sql:param value="${param.activityId}"/>
    </sql:query>
    <c:if test="${outManualQuery.rowCount>0}" >
        <c:set var="exportFileNameManualXls" scope="page" value="${param.process}_v${param.version}_manualFiles.xml"/>
        <c:set var="exportFileNameManualCsv" scope="page" value="${param.process}_v${param.version}_manualFiles.csv"/>
        <c:set var="exportFileNameManualXls" scope="page" value="${param.process}_v${param.version}_manualFiles.xml"/>
        
        <display:table name="${outManualQuery.rows}" id="row" export="true" class="datatable">
            <display:column property="name" title="Name" sortable="true" headerClass="sortable"/>
            <display:column title="virtualPath" sortable="true" headerClass="sortable">
                <c:choose>
                    <c:when test="${empty row.catalogKey}">
                        <c:out value="${row.value}"/>
                    </c:when>
                    <c:otherwise>
                        <c:url var="dcLink" value="http://srs.slac.stanford.edu/DataCatalog/">
                            <c:param name="dataset" value="${row.catalogKey}"/>
                            <c:param name="experiment" value="LSST-CAMERA"/>
                        </c:url>
                        <a href="${dcLink}" target="_blank"><c:out value="${row.value}"/></a>
                    </c:otherwise>
                </c:choose>
            </display:column>
            <display:column property="creationTS" title="Timestamp" sortable="true" headerClass="sortable"/>
            <display:setProperty name="export.excel.filename" value="${exportFileNameManualXls}"/> 
            <display:setProperty name="export.csv.filename" value="${exportFileNameManualCsv}"/> 
            <display:setProperty name="export.xml.filename" value="${exportFileNameManualXml}"/> 
        </display:table>

    </c:if>

    <sql:query var="manualQuery" scope="page">
        SELECT InputPattern.label, value FROM IntResultManual INNER JOIN InputPattern
        WHERE IntResultManual.inputPatternId = InputPattern.id AND IntResultManual.activityId=?<sql:param value="${param.activityId}"/>
        UNION ALL
        SELECT InputPattern.label, value FROM FloatResultManual INNER JOIN InputPattern
        WHERE FloatResultManual.inputPatternId = InputPattern.id AND FloatResultManual.activityId=?<sql:param value="${param.activityId}"/>
        UNION ALL
        SELECT InputPattern.label, value FROM StringResultManual INNER JOIN InputPattern
        WHERE StringResultManual.inputPatternId = InputPattern.id AND StringResultManual.activityId=?<sql:param value="${param.activityId}"/>
    </sql:query>
    <c:if test="${manualQuery.rowCount>0}" >
        <c:set var="exportFileNameLiteralsXls" scope="page" value="${param.process}_v${param.version}_literals.xml"/>
        <c:set var="exportFileNameLiteralsCsv" scope="page" value="${param.process}_v${param.version}_literals.csv"/>
        <c:set var="exportFileNameLiteralsXls" scope="page" value="${param.process}_v${param.version}_literals.xml"/>
        
        <display:table name="${manualQuery.rows}" id="row" export="true" class="datatable">
            <display:column property="label" title="Description" sortable="true" headerClass="sortable" nulls="true"/>
            <display:column property="value" title="Value" sortable="true" headerClass="sortable"/>
            <display:setProperty name="export.excel.filename" value="${exportFileNameLiteralsXls}"/> 
            <display:setProperty name="export.csv.filename" value="${exportFileNameLiteralsCsv}"/> 
            <display:setProperty name="export.xml.filename" value="${exportFileNameLiteralsXml}"/> 
        </display:table>
    </c:if>


</body>
</html>
