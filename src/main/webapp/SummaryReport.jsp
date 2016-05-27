<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib prefix="ru" tagdir="/WEB-INF/tags/reports"%>
<%@taglib prefix="datacat" uri="http://srs.slac.stanford.edu/tlds/datacat"%>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Summary Report</title>
        <style>
            img {page-break-before: avoid;}
            h2.break {page-break-before: always;}
        </style>
    </head>
    <body>
        <fmt:setTimeZone value="UTC"/>
        <c:set var="debug" value="false"/>
        <sql:query var="sensor">
            select hw.lsstId, act.end, act.id, pr.name from Activity act 
            join Hardware hw on act.hardwareId=hw.id 
            join Process pr on act.processId=pr.id join ActivityStatusHistory statusHist on act.id=statusHist.activityId 
            where statusHist.activityStatusId=1 and pr.name='test_report_offline' and act.parentActivityId = ?
            <sql:param value="${param.parentActivityId}"/>
        </sql:query> 
        <c:set var="lsstId" value="${sensor.rows[0].lsstId}"/>  
        <c:set var="actId" value="${sensor.rows[0].id}"/>  
        <c:set var="end" value="${sensor.rows[0].end}"/>  
        <c:set var="reportName" value="${sensor.rows[0].name}"/>
        <c:set var="parentActivityId" value="${param.parentActivityId}"/>
        <sql:query var="reports" dataSource="jdbc/config-prod">
            select id from report where name=?
            <sql:param value="${reportName}"/>
        </sql:query>
        <c:set var="reportId" value="${reports.rows[0].id}"/>
        <c:set var="theMap" value="${portal:getReportValues(pageContext.session,parentActivityId,reportId)}"/>
        <c:if test="${debug}">
            <display:table name="${theMap.entrySet()}" id="theMap"/>  <%-- shows what's in the map --%> 
        </c:if>

        <h1>Summary Report for ${lsstId}</h1>
        Generated <fmt:formatDate value="${end}" pattern="yyy-MM-dd HH:mm z"/> by Job Id <ru:jobLink id="${actId}"/>

        <sql:query var="sections" dataSource="jdbc/config-prod">
            select section,title,extra_table,page_break from report_display_info where report=? order by display_order asc
            <sql:param value="${reportId}"/>
        </sql:query>
        <c:forEach var="sect" items="${sections.rows}">  
            <h2 class='${sect.page_break==1 ? 'break' : 'nobreak'}'>${sect.section} ${sect.title}</h2>
            <ru:summaryTable sectionNum="${sect.section}" data="${theMap}" reportId="${reportId}"/>
            <c:if test="${!empty sect.extra_table}">
                <c:catch var="x">
                    <c:set var="tdata" value="${sect.extra_table}"/>
                    <display:table name="${portal:jexlEvaluateData(theMap, tdata)}" class="datatable"/>
                </c:catch>
                <c:if test="${!empty x}">No data returned <br/></c:if>
            </c:if>
            <sql:query var="images"  dataSource="jdbc/config-prod">
                select image_url from report_image_info where section=? and report=? order by display_order asc
                <sql:param value="${sect.section}"/>
                <sql:param value="${reportId}"/>
            </sql:query>
            <c:forEach var="image" items="${images.rows}">
                <datacat:query var="datasets">
                    <datacat:folderPath value="${appVariables.datacatSearch}${actId}"/>
                    site=='SLAC' && dataType=='LSSTSENSORTEST' && fileFormat='png' && name='${lsstId}${image.image_url}'
                </datacat:query>
                <c:if test="${empty datasets}">
                    Missing image: ${lsstId}${image.image}
                </c:if>
                <c:forEach var="dataset" items="${datasets}">
                    <c:set var="pk" value="${dataset.viewInfo.getLocation('SLAC').pk}"/>
                    <img src="http://srs.slac.stanford.edu/DataCatalog/get?datasetLocation=${pk}" alt="${lsstId}${image.image_url}"/>
                </c:forEach>
            </c:forEach>
            
            <c:if test="${sect.title == 'Software Versions'}">
                <sql:query var="vers">
                   select distinct res.name, res.value from StringResultHarnessed res join Activity act on res.activityId=act.id  where  name in ( 'harnessedJobs_version','eotest_version', 'LSST_stack_version','lcatr_harness_version' , 'lcatr_schema_version') and parentActivityId=?
                   <sql:param value="${parentActivityId}"/>
                </sql:query>
                <c:if test="${vers.rowCount > 0}">
                    <display:table name="${vers.rows}"   class="datatable" />
                </c:if>  
            </c:if>
                    
        </c:forEach>
    </body>
</html>
