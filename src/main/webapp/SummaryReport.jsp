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
            h2 {page-break-before: always;}
        </style>
    </head>
    <body>
        <c:set var="debug" value="false"/>
        <sql:query var="sensor" dataSource="jdbc/rd-lsst-cam-dev-ro">
            select hw.lsstId, act.id from Activity act 
            join Hardware hw on act.hardwareId=hw.id 
            join Process pr on act.processId=pr.id join ActivityStatusHistory statusHist on act.id=statusHist.activityId 
            where statusHist.activityStatusId=1 and pr.name='test_report_offline' and act.parentActivityId = ?
            <sql:param value="${param.parentActivityId}"/>
        </sql:query> 
        <c:set var="lsstId" value="${sensor.rows[0].lsstId}"/>  
        <c:set var="actId" value="${sensor.rows[0].id}"/>  
        <c:set var="parentActivityId" value="${param.parentActivityId}"/>
        <c:set var="theMap" value="${portal:getReportValues(pageContext.session,parentActivityId)}"/>
        <c:if test="${debug}">
            <display:table name="${theMap.entrySet()}" id="theMap"/>  <%-- shows what's in the map --%> 
        </c:if>

        <h1>Summary Report for ${lsstId}</h1>

        <sql:query var="sections" dataSource="jdbc/config-prod">
            select section,title,extra_table,page_break from report_display_info order by display_order asc
        </sql:query>
        <c:forEach var="sect" items="${sections.rows}">  
            <h2>${sect.section} ${sect.title}</h2>
            <ru:reportUtil sectionNum="${sect.section}" data="${theMap}"/>
            <c:if test="${!empty sect.extra_table}">
                <c:set var="tdata" value="${sect.extra_table}"/>
                <display:table name="${portal:jexlEvaluateData(theMap, tdata)}" class="datatable"/>
            </c:if>
            <sql:query var="images"  dataSource="jdbc/config-prod">
                select image_url from report_image_info where section=? order by display_order asc
                <sql:param value="${sect.section}"/>
            </sql:query>
            <c:forEach var="image" items="${images.rows}">
                <datacat:query var="datasets">
                    <datacat:folderPath value="/LSST/mirror/SLAC-test/test/**/${actId}"/>
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
        </c:forEach>
    </body>
</html>
