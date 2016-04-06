<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Summary of Tests 2</title>
    </head>
    <body>
        <h1>Summary Of Tests 2 (page under construction)</h1>

        <%-- get a list of all the parentActivityIds --%> 
        <sql:query var="sensor" dataSource="jdbc/rd-lsst-cam-dev-ro">
            select hw.lsstId, act.id, act.parentActivityId, statusHist.activityStatusId, pr.name from Activity act join Hardware hw on act.hardwareId=hw.id 
            join Process pr on act.processId=pr.id join ActivityStatusHistory statusHist on act.id=statusHist.activityId 
            where statusHist.activityStatusId=1 and pr.name='test_report_offline' order by act.parentActivityId desc   
        </sql:query> 

        <p><c:out value="sensor count ${sensor.rowCount}"/></p>

        <%-- get a list of all the queries --%> 
        <sql:query var="reportqry" dataSource="jdbc/config-prod">
            select rkey, query from report_queries
        </sql:query>

        <%-- get a list of all the specs --%> 
        <sql:query var="summary" dataSource="jdbc/config-prod">
            select specid, description, spec_display, jexl_status, jexl_measurement from report_specs
        </sql:query>

        <c:choose>
            <c:when test="${empty param}">
                <display:table name = "${sensor.rows}" id="row" class="dataTable">

                    <display:column property="parentActivityId" title="ParentActivityId" href="SummaryTest2.jsp" paramId="parentActivityId"/>
                    <display:column property="lsstId" title="lsstId"/>
                </display:table>
            </c:when>     
            <c:when test="${! empty param}">
                <c:out value="${param.parentActivityId}"/>
                <c:out value="${param.lsstId}"/>
                <c:set var="parentActivityId" value="${param.parentActivityId}"/>
                <c:set var="lsstId" value="${param.lsstId}"/>

                <jsp:useBean id="theMap" class="java.util.HashMap" scope="page"/> 
                <c:forEach var="row" items="${reportqry.rows}">
                    <c:set var="key" value="${row.rkey}"/>
                    <sql:query var="results" dataSource="jdbc/rd-lsst-cam-dev-ro">
                        ${row.query}
                        <sql:param value="${parentActivityId}"/>
                    </sql:query> 

                    <% java.util.ArrayList theList = new java.util.ArrayList(); %>
                    <c:forEach var="res" items="${results.rows}">
                        <c:set var="value" value="${res.value}"/>
                        <% theList.add(pageContext.getAttribute("value")); %>
                    </c:forEach>
                    <% ((java.util.Map) pageContext.getAttribute("theMap")).put(pageContext.getAttribute("key"), theList);%> 
                </c:forEach> 

                <h1>Electro-Optical Test Results for Sensor ${lsstId}</h1>
                <%--  <display:table name="${theMap.entrySet()}" id="dataTable"/> --%>
                <display:table name="${summary.rows}" id="row" defaultsort="2" class="datatable" export="true">
                    <display:column title="Status">
                        <c:set var="status" value="${portal:jexlEvaluateData(theMap, row.jexl_status)}"/>
                        ${empty status ? "..." : status ? "&#x2714;" : "&#x2718;"}
                    </display:column>
                    <display:column property="SpecId" title="Spec. ID"/>
                    <display:column property="Description"/>
                    <display:column property="Spec_Display" title="Specification"/>
                    <display:column title="Value">
                        ${portal:jexlEvaluateData(theMap, row.jexl_measurement)}  
                    </display:column>
                </display:table>

            </c:when>
            <c:otherwise>
                <c:out value="No rows returned from queries"/>
            </c:otherwise>
        </c:choose>
    </body>
</html>


<%--
<c:choose>
    <c:when test="${empty param}">
        The list contains the lsstHwId, the activity Id, the parent activity Id, in that order.<br/>
        Select one (for test reports only):
        <form name="sensorform" id="sensorform" action="SummaryTest2.jsp?rectype=NEWSENSOR" method="get" >
            <table>
                <thead>
                    <tr>
                        <td><select name="schemaInfo" id="schemaInfo" size="25">
                                <c:forEach var="arow" items="${sensor.rows}">
                                    <c:set var="sensorString" value="${arow.lsstId}, ${arow.id}, ${arow.parentActivityId}"/>
                                    <option value="${sensorString}"> ${arow.lsstId}, ${arow.id}, ${arow.parentActivityId}</option>
                                </c:forEach>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td><input type="submit" value="submit" name="submit"/></td><td><input type="reset" value="reset" name="reset"/></td>
                    </tr>
                </thead>
            </table>
        </form>
    </c:when>
    <c:when test="${! empty param}">
        <c:set var="string" value="${fn:split(param.schemaInfo,',')}"/>
        <c:set var="hwid" value="${string[0]}"/> 
        <c:set var="actid" value="${string[1]}"/> 
        <c:set var="parentActivityId" value="${string[2]}"/>
        <c:set var="actHistStatus" value="${string[3]}"/>

                <table border="1" cellspacing="2" cellpadding="8">
                    <tr>
                        <th>hwID</th> <th> actID</th> <th>ParentActivityID</th>
                    </tr>
                    <tr>
                        <td>${hwid}</td><td>${actid}</td><td>${parentActivityId}</td>
                    </tr>
                </table>
                <p></p>
--%>
<%-- select id, rkey, query from report_queries --%>

<%--
<sql:query var="reportqry" dataSource="jdbc/config-prod">
    select rkey, query from report_queries
</sql:query>

                <jsp:useBean id="theMap" class="java.util.HashMap" scope="page"/> 

                <c:choose> 
                    <c:when test="${reportqry.rowCount > 0}">
                        <c:forEach var="row" items="${reportqry.rows}">
                            <c:set var="key" value="${row.rkey}"/>
                            <sql:query var="results" dataSource="jdbc/rd-lsst-cam-dev-ro">
                                ${row.query}
                                <sql:param value="${parentActivityId}"/>
                            </sql:query> 

                            <% java.util.ArrayList theList = new java.util.ArrayList(); %>
                            <c:forEach var="res" items="${results.rows}">
                                <c:set var="value" value="${res.value}"/>
                                <% theList.add(pageContext.getAttribute("value")); %>
                            </c:forEach>
                            <% ((java.util.Map) pageContext.getAttribute("theMap")).put(pageContext.getAttribute("key"), theList);%>                               

                        </c:forEach> 

                    </c:when>
                    <c:otherwise>
                        <c:out value="No rows returned ${reports.rowCount}"/>
                    </c:otherwise>
                </c:choose>
                <display:table name="${theMap.entrySet()}" id="dataTable"/>

                <sql:query var="summary" dataSource="jdbc/config-prod">
                    select specid, description, spec_display, jexl_status, jexl_measurement from report_specs
                </sql:query>

                <display:table name="${summary.rows}" id="row" defaultsort="1">
                    <display:column property="SpecId"/>
                    <display:column property="Description"/>
                    <display:column property="Spec_Display" title="Spec"/>
                    <display:column title="Value">
                       ${portal:jexlEvaluateData(theMap, row.jexl_measurement)}  
                    </display:column>
                    <display:column title="Status">
                        ${portal:jexlEvaluateData(theMap, row.jexl_status)}
                    </display:column>
                </display:table>

                 
            </c:when>
        </c:choose>
--%>
