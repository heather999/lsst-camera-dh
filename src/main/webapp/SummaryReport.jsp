<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib prefix="ru" tagdir="/WEB-INF/tags/reports"%>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Summary Report</title>
        <%-- this is separate from SummaryTest2.jsp in case others will use this code --%>
    </head>
    <body>
        <h1>Summary Report</h1>
        <c:set var="debug" value="false"/>
        
         <%-- All The Queries --%>  
        <sql:query var="sensor" dataSource="jdbc/rd-lsst-cam-dev-ro">
            select hw.lsstId, act.id from Activity act join Hardware hw on act.hardwareId=hw.id 
            join Process pr on act.processId=pr.id join ActivityStatusHistory statusHist on act.id=statusHist.activityId 
            where statusHist.activityStatusId=1 and pr.name='test_report_offline' and act.parentActivityId = ?
            <sql:param value="${param.parentActivityId}"/>
        </sql:query> 
        <c:if test="${sensor.rowCount > 0}" >
            <c:set var="lsstId" value="${sensor.rows[0].lsstId}"/>  
        </c:if>   
       <sql:query var="reportqry" dataSource="jdbc/config-prod">
           select rkey, id, query from report_queries
       </sql:query>
       <sql:query var="specs" dataSource="jdbc/config-prod">
           select section, specid, description, spec_display, jexl_status, jexl_measurement from report_specs
           order by section desc
       </sql:query>
       <sql:query var="sections" dataSource="jdbc/config-prod">
           select d.section,title,page_break,display_order from report_display_info d order by display_order asc
       </sql:query>
       <sql:query var="imageqry" dataSource="jdbc/config-prod">
          select section, image_url from report_image_info            
       </sql:query>   
       
       
       <c:set var="parentActivityId" value="${param.parentActivityId}"/>
       <c:set var="theMap" value="${portal:getReportValues(pageContext.session,parentActivityId)}"/>
       <c:if test="${debug}">
           <display:table name="${theMap.entrySet()}" id="dataTable"/>  <%-- shows what's in the map --%> 
       </c:if>
       <jsp:useBean id="theMap" class="java.util.HashMap" scope="page"/> 
             
       <c:forEach var="row" items="${reportqry.rows}">
         <c:set var="key" value="${row.rkey}"/>
         <c:set var="spec_id" value="${row.id}"/>
         <sql:query var="results" dataSource="jdbc/rd-lsst-cam-dev-ro">
            ${row.query}
            <sql:param value="${parentActivityId}"/>
         </sql:query> 
       </c:forEach>  
            
       <h1>Electro-Optical Test Results for ${lsstId}</h1>
        
        <c:forEach var="sect" items="${sections.rows}">  
          <%--  <h1>${sect.section} ${sect.title}</h1>  --%>
            <c:if test="${!empty sect.section}">
                <ru:reportUtil sectionNum="${sect.section}" data="${theMap}"/>
            </c:if>                      
       </c:forEach>
    </body>
</html>