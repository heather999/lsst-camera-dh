<%-- 
    Document   : jhResultWidget
    Created on : Jun 10, 2015, 5:37:42 PM
    Author     : focke
--%>

<%@tag description="Display Job Harness results" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>
<%@taglib prefix="display" uri="http://displaytag.sf.net"%>

<%@attribute name="activityId" required="true"%>
<%@attribute name="processName" required="false"%>
<%@attribute name="version" required="false"%>


<sql:query var="resultsQ">
    select name, value, schemaName, schemaVersion, schemaInstance, id, 2 as section
    from FloatResultHarnessed
    where activityId=?<sql:param value="${activityId}"/>
    union
    select name, value, schemaName, schemaVersion, schemaInstance, id, 2 as section
    from IntResultHarnessed
    where NOT (name="stat") AND activityId=?<sql:param value="${activityId}"/>
    union
    select name, value, schemaName, schemaVersion, schemaInstance, id, 2 as section
    from StringResultHarnessed
    where activityId=?<sql:param value="${activityId}"/>
    order by section, schemaName, schemaVersion, schemaInstance, name
    ;
</sql:query>

<sql:query var="statusQ">
    select name, value
    from IntResultHarnessed
    where name="stat" AND activityId=?<sql:param value="${activityId}"/>
    ;
</sql:query>
    
<c:choose>
    <c:when test="${! empty resultsQ.rows}">
        <h4>Job Harness Results ${processName}_v${version}
        <c:set var="exportOutputXls" scope="page" value="${processName}_v${version}_jh.xls"/>
        <c:set var="exportOutputCsv" scope="page" value="${processName}_v${version}_jh.csv"/>
        <c:set var="exportOutputXml" scope="page" value="${processName}_v${version}_jh.xml"/>
        <c:if test="${! empty statusQ.rows}"> 
            <c:set var="status" value="${statusQ.rows[0]}"/>
            ${status.name} ${status.value}</h4>  
        </c:if>
        <display:table name="${resultsQ.rows}" id="row" defaultsort="3" export="true" class="datatable">
            <display:column property="schemaName" title="Schema" sortable="true" headerClass="sortable"/>
            <display:column property="schemaVersion" title="Version" sortable="true" headerClass="sortable"/>
            <display:column property="name" title="Name" sortable="true" headerClass="sortable"/>
            <display:column property="schemaInstance" title="Instance" sortable="true" headerClass="sortable"/>
            <display:column property="value" title="Value" sortable="true" headerClass="sortable"/>
                <%-- <c:choose>
                    <c:when test="${empty row.catalogKey}">
                        <c:out value="${row.value}"/> --%>
                        <%--
                    </c:when>
                    <c:otherwise>
                        <c:url var="dcLink" value="http://srs.slac.stanford.edu/DataCatalog/">
                            <c:param name="dataset" value="${row.catalogKey}"/>
                            <c:param name="experiment" value="LSST-CAMERA"/>
                        </c:url>
                        <a href="${dcLink}" target="_blank"><c:out value="${row.value}"/></a>
                    </c:otherwise>
                </c:choose> 
            </display:column> --%>
           <display:setProperty name="export.excel.filename" value="${exportOutputXls}"/> 
           <display:setProperty name="export.csv.filename" value="${exportOutputCsv}"/> 
           <display:setProperty name="export.xml.filename" value="${exportOutputXml}"/> 
        </display:table>
    </c:when>
    <c:otherwise>
        <c:if test="${! empty statusQ.rows}"> 
            <c:set var="status" value="${statusQ.rows[0]}"/>
            <h4>Job Harness Results ${processName}_v${version} ${status.name} ${status.value}</h4>
        </c:if>
    </c:otherwise>
</c:choose>