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
        <title>Summary Report</title>
    </head>
    <body>
        <h1>Summary Report</h1>
            
        <sql:query var="sensor" dataSource="jdbc/rd-lsst-cam-dev-ro">
            select hw.lsstId, act.id from Activity act join Hardware hw on act.hardwareId=hw.id 
            join Process pr on act.processId=pr.id join ActivityStatusHistory statusHist on act.id=statusHist.activityId 
            where statusHist.activityStatusId=1 and pr.name='test_report_offline' and act.parentActivityId = ?
            <sql:param value="${param.parentActivityId}"/>
        </sql:query> 
            
             
        <c:if test="${sensor.rowCount > 0}" >
            <c:set var="lsstId" value="${sensor.rows[0].lsstId}"/>  
        </c:if>    
             <%-- get a list of all the queries --%> 
        <sql:query var="reportqry" dataSource="jdbc/config-prod">
            select rkey, query from report_queries
        </sql:query>

        <%-- get a list of all the specs --%> 
        <sql:query var="summary" dataSource="jdbc/config-prod">
            select specid, description, spec_display, jexl_status, jexl_measurement from report_specs
        </sql:query>
            
            <c:if test="${! empty param}">
                
                <c:set var="parentActivityId" value="${param.parentActivityId}"/>

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

                <h1>Electro-Optical Test Results for ${lsstId}</h1>
                <%--  <display:table name="${theMap.entrySet()}" id="dataTable"/> --%>
                <display:table name="${summary.rows}" id="row" defaultsort="2" class="datatable" export="true">
                    <display:column title="Status">
                        <c:catch var="x">
                            <c:set var="status" value="${portal:jexlEvaluateData(theMap, row.jexl_status)}"/>
                            ${empty status ? "..." : status ? "&#x2714;" : "&#x2718;"}
                        </c:catch>
                        <c:if test="${!empty x}">???</c:if>
                    </display:column>
                    <display:column property="SpecId" title="Spec. ID"/>
                    <display:column property="Description"/>
                    <display:column property="Spec_Display" title="Specification"/>
                    <display:column title="Value">
                        <c:catch var="x">
                            ${portal:jexlEvaluateData(theMap, row.jexl_measurement)} 
                        </c:catch>
                        <c:if test="${!empty x}">???</c:if>
                    </display:column>
                </display:table>
                <c:set var="tdata" value="u.toTable([\"Amp\",\"Full Well\",\"Nonlinearity\"],u.range(1,16),u.fetch(\"full_well\"),u.fetch(\"max_frac_dev\"))"/>
                <display:table name="${portal:jexlEvaluateData(theMap, tdata)}" class="datatable"/>
         
            </c:if>
    </body>
</html>