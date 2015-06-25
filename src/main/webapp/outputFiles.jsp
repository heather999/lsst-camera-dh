<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="display" uri="http://displaytag.sf.net" %>
<%@taglib prefix="portal" uri="WEB-INF/tags/portal.tld" %>

<html>
    <head>
        <title>Output Files for <c:out value="${param.activityId}"/></title>
    </head>
    <body> 
        <h1>Output ${param.travName} ${param.processName} Version ${param.processVersion}</h1>

        <sql:query var="outQuery" scope="page">
            SELECT creationTS, name, value, catalogKey, schemaName, schemaVersion, schemaInstance, virtualPath FROM FilepathResultHarnessed 
            WHERE FilepathResultHarnessed.activityId=?<sql:param value="${param.activityId}"/>
        </sql:query>
        <c:if test="${outQuery.rowCount>0}" >

            <%--
            <display:table name="${outQuery.rows}" export="true" class="datatable"/> 
        </c:if>
            --%>


            <display:table name="${outQuery.rows}" id="row" export="true" class="datatable">
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
                <display:column property="creationTS" title="Timestamp" sortable="true" headerClass="sortable"/>
            </display:table>

        </c:if>


    </body>
</html>
