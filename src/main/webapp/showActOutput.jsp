<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="portal" uri="WEB-INF/tags/portal.tld" %>
<%@taglib prefix="etraveler" tagdir="/WEB-INF/tags/eTrav"%>

<html>
    <head>
        <title>Results</title>
        <style type="text/css">
            table.datatable th, table.datatable td {
                text-align: left;
            }
        </style>
    </head>
    <body> 


        <h1>Data and Results</h1>

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


        <sql:query var="downloadQuery" scope="page">
            SELECT virtualPath FROM FilepathResultHarnessed 
            WHERE FilepathResultHarnessed.activityId=?<sql:param value="${param.actId}"/>
        </sql:query>
            
        <c:choose>
            <c:when test="${downloadQuery.rowCount>0}" >

                <%-- Note use of concat in the query, the AS statement was not working otherwise 
        http://stackoverflow.com/questions/14431907/how-to-access-duplicate-column-names-with-jstl-sqlquery
                --%>

                <ul>
                    <sql:query var="moreProcessInfo" scope="page">
                        SELECT A.id, concat(P.name,'') as process, A.processId, A.iteration,
                        P.version AS version
                        FROM Process P, Activity A  
                        WHERE P.id=A.processId AND A.id=${param.actId}
                    </sql:query>
                    <c:set var="processInfo" value="${moreProcessInfo.rows[0]}"/>    
                    <c:url var="resultsLink" value="procResults.jsp">
                        <c:param name="activityId" value="${param.actId}"/>
                        <c:param name="process" value="${processInfo.process}"/>
                        <c:param name="version" value="${processInfo.version}"/>
                        <c:param name="travName" value="${param.actName}"/>
                    </c:url>
                    <li>
                        <a target="_blank" href="${resultsLink}">Summary of ${processInfo.process} v${processInfo.version} iter ${processInfo.iteration} actId: ${curAct}</a>

                        <b>

                            &nbsp;&nbsp;&nbsp;&nbsp  <%-- poor practice but quick for now --%>
                            <c:set var="firstRow" value="${downloadQuery.rows[0]}" scope="page"/>
                            <c:set var="curPath" value="${portal:truncateString(firstRow.virtualPath,'/')}" scope="page"/>
                            <c:url var="dcLink" value="http://srs.slac.stanford.edu/DataCatalog/">
                                <c:param name="folderPath" value="${curPath}"/>
                                <c:param name="experiment" value="LSST-CAMERA"/>
                                <c:param name="showFileList" value="true"/>
                            </c:url>
                            <a href="${dcLink}" style="color: rgb(6,82,32)" target="_blank"><c:out value="Download Files"/></a>


                        </b>

                    </li>
                </ul>
            </c:when>
            <c:otherwise>
                No Data Available 
            </c:otherwise>
        </c:choose>




    </body>
</html>
