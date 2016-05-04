<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="portal" uri="WEB-INF/tags/portal.tld" %>


    <head>
        <title>Results</title>
        <style type="text/css">
            table.datatable th, table.datatable td {
                text-align: left;
            }
        </style>
    </head>
     
        <h1>Data and Results for ${param.lsstNum}

        </h1>

        <c:set var="lsstNum" value="${param.lsstNum}" scope="page"/> 
        <c:set var="hdwGroup" value="${param.hdwGroup}" scope="page"/>
        <c:set var="hdwTypeStr" value="${portal:getAnyHardwareTypes(pageContext.session,hdwGroup)}"/> 
        <sql:query  var="hdwData" scope="page" >
            SELECT Hardware.id from Hardware where Hardware.lsstId=?
            <sql:param value="${lsstNum}"/>
        </sql:query>

        <c:set var="hdwId" value="${hdwData.rows[0].id}" scope="page"/>

        <c:set var="actSet" value="${portal:getActivitySet(pageContext.session,hdwId,false)}"/> 

        <c:forEach var="curAct" items="${actSet}" varStatus="status">


            <sql:query var="resultsQu" scope="page" >
                SELECT name, value, catalogKey, schemaName, schemaVersion, schemaInstance, id, 2 as section
                FROM FilepathResultHarnessed
                WHERE activityId=?<sql:param value="${curAct}"/>
                UNION
                SELECT name, value, null as catalogKey, schemaName, schemaVersion, schemaInstance, id, 1 as section
                FROM FloatResultHarnessed
                WHERE activityId=?<sql:param value="${curAct}"/>
                UNION
                SELECT name, value, null as catalogKey, schemaName, schemaVersion, schemaInstance, id, 1 as section
                FROM IntResultHarnessed
                WHERE NOT (name="stat") AND activityId=?<sql:param value="${curAct}"/>
                UNION
                SELECT name, value, null as catalogKey, schemaName, schemaVersion, schemaInstance, id, 1 as section
                FROM StringResultHarnessed
                WHERE activityId=?<sql:param value="${curAct}"/>
                ORDER BY section, schemaName, schemaVersion, schemaInstance, name
                ;
            </sql:query>



            <c:if test="${fn:length(resultsQu.rows) > 0}">

                <sql:query var="majorTitleQu" scope="page">
                    SELECT value AS majorTitle FROM StringResultHarnessed
                    WHERE activityId=?<sql:param value="${curAct}"/> AND schemaName=?<sql:param value="${param.schema}"/> 
                    AND name=?<sql:param value="${param.major}"/>
                    ;
                </sql:query>

                <sql:query var="minorTitleQu" scope="page">
                    SELECT value AS minorTitle FROM StringResultHarnessed
                    WHERE activityId=?<sql:param value="${curAct}"/> AND schemaName=?<sql:param value="${param.schema}"/>  
                    AND name=?<sql:param value="${param.minor}"/>
                    ;
                </sql:query>
                <%-- sorting index starts from 1 --%>
                
                <h2>
                    <c:if test="${fn:length(majorTitleQu.rows) > 0}">
                        ${majorTitleQu.rows[0].majorTitle}  
                    </c:if>
                    <c:if test="${fn:length(minorTitleQu.rows) > 0}">
                        ${minorTitleQu.rows[0].minorTitle} 
                    </c:if>
                </h2>

                <display:table name="${resultsQu.rows}" id="row" export="true" class="datatable">
                    <display:column property="schemaName" title="Schema" sortable="true" headerClass="sortable"/>
                    <display:column property="schemaVersion" title="Version" sortable="true" headerClass="sortable"/>
                    <display:column property="name" title="Name" sortable="true" headerClass="sortable"/>
                    <display:column property="schemaInstance" title="Instance" sortable="true" headerClass="sortable"/>
                    <display:column title="Value" sortable="true" headerClass="sortable">
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

                    <display:setProperty name="export.excel.filename" value="${exportOutputXls}"/> 
                    <display:setProperty name="export.csv.filename" value="${exportOutputCsv}"/> 
                    <display:setProperty name="export.xml.filename" value="${exportOutputXml}"/> 
                </display:table>
            </c:if>
        </c:forEach> <%-- End Activity Loop --%>





    

