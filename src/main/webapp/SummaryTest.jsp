<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="portal" uri="WEB-INF/tags/portal.tld" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="display" uri="http://displaytag.sf.net" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- 
    Document   : SummaryTest
    Created on : Jan 13, 2016, 1:19:08 PM
    Author     : chee
--%>

 
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Summary of Tests</title>
    </head>
    <body>
        <h1>Summary Of Tests</h1>
        
        <sql:query var="lca128" dataSource="jdbc/config-prod">
           select specid,description,specification, scope from LCA128
        </sql:query>

        <sql:query var="sensor">
            select act.id, act.parentActivityId, hw.lsstId, statusHist.activityStatusId from Activity act join Hardware hw on act.hardwareId=hw.id 
            join Process pr on act.processId=pr.id join ActivityStatusHistory statusHist on act.id=statusHist.activityId 
            where pr.name='test_report_offline' order by act.parentActivityId desc   
        </sql:query>

    <p><c:out value="sensor count ${sensor.rowCount}"/></p>
    <c:choose>
        <c:when test="${empty param}">
            The list contains the activity Id, the schema name, the parent activity Id and the activity status id, in that order.<br/>
            Select one (for test reports only):
            <form name="sensorform" id="sensorform" action="SummaryTest.jsp?rectype=NEWSENSOR" method="get" >
                <table>
                    <thead>
                    <td>
                    <tr>
                        <td><select name="schemaInfo" id="schemaInfo" size="6">
                            <c:forEach var="arow" items="${sensor.rows}">
                                <c:set var="sensorString" value="${arow.id} ${arow.parentActivityId} ${arow.lsstId} ${arow.activityStatusId}"/>
                                <option value="${sensorString}">${arow.id} ${arow.lsstId} ${arow.parentActivityId} ${arow.activityStatusId}</option>
                            </c:forEach>
                            </select>
                        </td>
                    </tr>
                    <tr><td><input type="submit" value="submit" name="submit"/></td><td><input type="reset" value="reset" name="reset"/></td></tr>
                    </td>
                    </thead>
                </table>
            </form>
        </c:when>
        <c:when test="${! empty param}">
            
            <c:set var="string" value="${fn:split(param.schemaInfo,' ')}"/>
            <c:set var="actid" value="${string[0]}"/> 
            <c:set var="parentActivityId" value="${string[1]}"/>
            <c:set var="schema" value="${string[2]}"/>
            <c:set var="actHistStatus" value="${string[3]}"/>
            <p>You selected: <br/>activity Id ${actid}<br/> parentActivityId ${parentActivityId}<br/> schema ${schema} <br/> status ${actHistStatus}</p>
            
            <sql:query var="summarylist" dataSource="jdbc/config-prod">
              select testName, namelist, ntype, specid from Summary_md
            </sql:query> 
            <c:out value="summarylist rows = ${summarylist.rowCount}"/>
            
            <sql:query var="activities"> 
                select act.id, act.parentActivityId, pr.name from Activity act join Process pr on act.processId=pr.id where act.parentActivityId=?
                <sql:param value="${parentActivityId}"/>
            </sql:query>
            
            <table class="datatable" border="1">
                <tbody>
                <th><td>Status</td> <td>spec. ID</td><td>Description</td><td>Specification</td><td>Measurement</td></th>
                    <c:forEach var="row" items="${summarylist.rows}">
                        <c:set var="SchemaNameFloat" value="${portal:getSummaryResults(pageContext.session, row.testName, parentActivityId, row.ntype, fn:split(row.testName, ','))}"/>
                        <c:if test="${! empty SchemaNameFloat}">
                            <c:set var="dataParts" value="${fn:split(SchemaNameFloat,',')}"/>
                            <tr> <td>?</td><td></td>  <td>${row.specid}</td>  <td></td> <td></td><td>${dataParts[1]} - ${dataParts[2]}</td> </tr>
                        </c:if>
                    </c:forEach>
                </tbody>
            </table>
        </c:when>
    </c:choose>
    </body>
</html>
