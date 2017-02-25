<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib prefix="ru" tagdir="/WEB-INF/tags/reports"%>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>
<%@taglib uri="http://srs.slac.stanford.edu/filter" prefix="filter"%>

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
            select hw.lsstId from Activity act 
            join Hardware hw on act.hardwareId=hw.id 
            join RunNumber r on r.rootActivityId=act.id
            where r.runNumber=?
            <sql:param value="${param.run}"/>
        </sql:query> 
        <c:set var="lsstId" value="${sensor.rows[0].lsstId}"/>  
        <h1>Raw Report for <a href="device.jsp?device=${lsstid}">${lsstId}</a> run <a href="run.jsp?run=${param.run}">${param.run}</a></h1>
            <filter:filterTable>
                <filter:filterSelection title="Process" var="process" defaultValue='-1'>
                    <filter:filterOption value="-1">All</filter:filterOption>
                <sql:query var="processes">
                    select p.name,p.id
                    from RunNumber r
                    join Activity a on (a.rootActivityId=r.rootActivityId)
                    join Process p on (a.processId=p.id)
                    where r.runNumber=?
                    <sql:param value="${param.run}"/>
                </sql:query>
                <c:forEach var="row" items="${processes.rows}">
                    <filter:filterOption value="${row.id}">${row.name}</filter:filterOption>
                </c:forEach>
            </filter:filterSelection>
            <filter:filterSelection title="Name" var="name" defaultValue='ALL'>
                <filter:filterOption value="ALL">All</filter:filterOption>
                <sql:query var="names">
                    select distinct x.name from (
                    select res.activityId, name from StringResultHarnessed res 
                    union all
                    select res.activityId, name from IntResultHarnessed res 
                    union all
                    select res.activityId, name from FloatResultHarnessed res 
                    union all
                    select res.activityId, name from FilepathResultHarnessed res 
                    ) x
                    join Activity act on x.activityId=act.id 
                    join RunNumber r on r.rootActivityId=act.rootActivityId
                    where r.runNumber=? order by x.name
                    <sql:param value="${param.run}"/>
                </sql:query>
                <c:forEach var="row" items="${names.rows}">
                    <filter:filterOption value="${row.name}">${row.name}</filter:filterOption>
                </c:forEach>
            </filter:filterSelection> 
            <filter:filterSelection title="Schema" var="schema" defaultValue='ALL'>
                <filter:filterOption value="ALL">All</filter:filterOption>
                <sql:query var="schemes">
                    select distinct x.schemaName from (
                    select res.activityId, schemaName from StringResultHarnessed res 
                    union all
                    select res.activityId, schemaName from IntResultHarnessed res 
                    union all
                    select res.activityId, schemaName from FloatResultHarnessed res 
                    union all
                    select res.activityId, schemaName from FilepathResultHarnessed res 
                    ) x
                    join Activity act on x.activityId=act.id 
                    join RunNumber r on r.rootActivityId=act.rootActivityId
                    where r.runNumber=? order by x.schemaName
                    <sql:param value="${param.run}"/>
                </sql:query>
                <c:forEach var="row" items="${schemes.rows}">
                    <filter:filterOption value="${row.schemaName}">${row.schemaName}</filter:filterOption>
                </c:forEach>
            </filter:filterSelection>                   
            <filter:filterSelection title="Type" var="type" defaultValue='ALL'>
                <filter:filterOption value="ALL">All</filter:filterOption>
                <filter:filterOption value="File">File</filter:filterOption>
                <filter:filterOption value="Float">Float</filter:filterOption>
                <filter:filterOption value="Int">Int</filter:filterOption>
                <filter:filterOption value="String">String</filter:filterOption>
            </filter:filterSelection>
            <input type="hidden" name="run" value="${param.run}"/>
        </filter:filterTable>
        <sql:query var="data">
            select p.name, x.variable,x.value,x.type,x.instance, x.schemaName from (
            select res.id, res.activityId, res.name variable, res.value, "String" type, schemaInstance instance, schemaName from StringResultHarnessed res 
            union all
            select res.id, res.activityId, res.name, res.value, "Integer" type, schemaInstance, schemaName from IntResultHarnessed res 
            union all
            select res.id, res.activityId, res.name, CAST(res.value as Char), "Float" type, schemaInstance, schemaName from FloatResultHarnessed res 
            union all
            select res.id, res.activityId, res.name, res.value, "File" type, schemaInstance, schemaName from FilepathResultHarnessed res 
            ) x
            join Activity act on x.activityId=act.id 
            join Process p on act.processid=p.id
            join RunNumber r on r.rootActivityId=act.rootActivityId
            where r.runNumber=?
            <sql:param value="${param.run}"/>
            <c:if test="${process != -1}">
                and p.id=?
                <sql:param value="${process}"/>
            </c:if>
            <c:if test="${name != 'ALL'}">
                and x.variable=?
                <sql:param value="${name}"/>
            </c:if>
            <c:if test="${schema != 'ALL'}">
                and x.schemaName=?
                <sql:param value="${schema}"/>
            </c:if>
            <c:if test="${type != 'ALL'}">
                and x.type=?
                <sql:param value="${type}"/>
            </c:if>
            order by p.name, x.variable, x.instance
        </sql:query>
        <display:table name="${data.rows}" class="datatable" >
            <display:column property="name" title="Process" sortable="true"/>
            <display:column property="variable" title="Name" sortable="true"/>
            <display:column property="instance" sortable="true"/>
            <display:column property="schemaName" title="Schema" sortable="true"/>
            <display:column property="type" sortable="true"/>
            <display:column property="value" sortable="true"/>
        </display:table>

    </body>
</html>
