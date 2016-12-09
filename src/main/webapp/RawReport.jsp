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
        <title>Raw Report</title>
        <style>
            img {page-break-before: avoid;}
            h2.break {page-break-before: always;}
        </style>
    </head>
    <body>
        <fmt:setTimeZone value="UTC"/>
        <ru:printButton/>
        <sql:query var="sensor">
            select hw.lsstId, act.end, act.id, pr.name from Activity act 
            join Hardware hw on act.hardwareId=hw.id 
            join Process pr on act.processId=pr.id 
            join ActivityStatusHistory statusHist on act.id=statusHist.activityId 
            where statusHist.activityStatusId=1 and act.id = ?
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

        <h1>Raw Report for ${lsstId}</h1>
        Generated <fmt:formatDate value="${end}" pattern="yyy-MM-dd HH:mm z"/> by Job Id <ru:jobLink id="${actId}"/>
        <sql:query var="data">
            select p.name, x.variable,x.value,x.type from (
                select res.activityId, res.name variable, res.value, "String" type from StringResultHarnessed res 
                union all
                select res.activityId, res.name, res.value, "Integer" type from IntResultHarnessed res 
                union all
                select res.activityId, res.name, res.value, "Float" type from FloatResultHarnessed res 
                union all
                select res.activityId, res.name, res.value, "File" type from FilepathResultHarnessed res 
            ) x
            join Activity act on x.activityId=act.id 
            join Process p on act.processid=p.id
            where act.parentActivityId=?
            <sql:param value="${param.parentActivityId}"/>
        </sql:query>
        <display:table name="${data.rows}"   class="datatable" >
            <display:column property="name" title="Process"/>
            <display:column property="variable" title="Name"/>
            <display:column property="value"/>
            <display:column property="type"/>
        </display:table>

    </body>
</html>
