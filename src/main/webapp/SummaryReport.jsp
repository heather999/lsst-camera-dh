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
        <style>
            img {page-break-before: avoid;}
            h2.break {page-break-before: always;}
        </style>
    </head>
    <body>
        <fmt:setTimeZone value="UTC"/>
        <c:set var="debug" value="${param.debug}"/>
        <sql:query var="sensor">
            select hw.lsstId,p.name,a.id from Activity a 
            join Process p on (a.processId=p.id)
            join Hardware hw on a.hardwareId=hw.id 
            join RunNumber r on r.rootActivityId=a.id
            where r.runNumber=?
            <sql:param value="${param.run}"/>
        </sql:query> 
        <c:set var="lsstId" value="${sensor.rows[0].lsstId}"/>  
        <c:set var="actId" value="${sensor.rows[0].id}"/>  
        <c:set var="end" value="${sensor.rows[0].end}"/>  
        <c:set var="reportName" value="${sensor.rows[0].name}"/>
        <sql:query var="reports" dataSource="${appVariables.reportDisplayDb}">
            select id, name, report_title from report where travelername=?
            <sql:param value="${reportName}"/>
        </sql:query>
        <c:if test="${reports.rowCount==0}">
            Unknown report name ${reportName}
        </c:if>
        <c:if test="${reports.rowCount>0}">
            <c:set var="reportId" value="${reports.rows[0].id}"/>
            <sql:query var="data">
                select a.id from Activity a
                join Process p on (a.processId=p.id)
                where a.rootActivityId=? and p.name=?
                <sql:param value="${actId}"/>
                <sql:param value="${reports.rows[0].name}"/>        
            </sql:query>
            <c:set var="parentActivityId" value="${data.rows[0].id}"/>
            <c:choose>
                <c:when test="${empty param.component}">
                    <c:set var="theMap" value="${portal:getReportValues(pageContext.session,reportId==8?actId:parentActivityId,reportId)}"/>
                    <c:set var="subcomponents" value="${theMap.sensorlist.value}"/>
                    <c:if test="${!empty subcomponents}">
                        <c:set var="subComponentMap" value="${portal:getReportValuesForSubcomponents(pageContext.session,reportId==8?actId:parentActivityId,reportId==8?10:9,subcomponents)}"/>
                        <c:if test="${!empty subComponentMap}">
                            <c:set var="subSpecs" value="${portal:getSpecifications(pageContext.session,9)}"/>
                        </c:if>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <c:set var="theMap" value="${portal:getReportValuesForSubcomponent(pageContext.session,reportId==8?actId:parentActivityId,reportId==8?10:9, param.component)}"/>
                    <c:set var="reportId" value="9"/>
                </c:otherwise>
            </c:choose>
            <c:if test="${debug}">
                <br>ReportId = ${reportId}
                <br>actId = ${actId}
                <br>reportName = ${reportName}
                <br>parentActivityId = ${parentActivityId}
                <c:forEach var="map" items="${theMap}">
                    <br>${map}
                </c:forEach>
                <br>subComponents: ${subcomponents}
                <c:forEach var="map" items="${subComponentMap}">
                    <br>${map}
                </c:forEach>
            </c:if>

            <ru:printButton/>
            <h1>
                ${reports.rows[0].report_title} <a href="device.jsp?lsstId=${lsstId}">${lsstId}</a> 
                <c:if test="${!empty param.component}">component <a href="device.jsp?lsstId=${param.component}">${param.component}</a></c:if> 
                run <a href="run.jsp?run=${param.run}">${param.run}</a>
            </h1>
            Generated <fmt:formatDate value="${end}" pattern="yyy-MM-dd HH:mm z"/> by Job Id <ru:jobLink id="${actId}"/>
            <sql:query var="sections" dataSource="${appVariables.reportDisplayDb}"> 
                select section,title,displaytitle,extra_table,page_break from report_display_info where report=? 
                <sql:param value="${reportId}"/>
                <c:if test="${sectionNum == '1'}">
                    and displaytitle = 'Y' 
                </c:if>
                order by display_order asc 
            </sql:query>
            <c:forEach var="sect" items="${sections.rows}">  
                <h2 class='${sect.page_break==1 ? 'break' : 'nobreak'}'>${sect.displaytitle == 'Y' ? sect.section : ''}  ${sect.displaytitle =='Y' ? sect.title : ''}</h2>
                <ru:summaryTable sectionNum="${sect.section}" data="${theMap}" reportId="${reportId}" run="${param.run}" subData="${subComponentMap}"/>
                <c:if test="${!empty sect.extra_table}">
                    <c:catch var="x">
                        <c:set var="tdata" value="${sect.extra_table}"/>
                        <display:table name="${portal:jexlEvaluateSubcomponentData(param.run, theMap, subComponentMap, subSpecs, tdata)}" class="datatable"/>
                    </c:catch>
                    <c:if test="${!empty x}">No data returned <br/></c:if>
                </c:if>
                <sql:query var="images"  dataSource="${appVariables.reportDisplayDb}"> 
                    select image_url, to_char(caption) caption from report_image_info where section=? and report=? order by display_order asc
                    <sql:param value="${sect.section}"/>
                    <sql:param value="${reportId}"/>
                </sql:query>
                <%-- if more than one row is returned for images just take the 1st one. Per J. Chiang's email --%>    
                <c:forEach var="image" items="${images.rows}">
                    <sql:query var="filepath">
                        select catalogKey from FilepathResultHarnessed res 
                        join Activity act on res.activityId=act.id where act.${reportId==8||reportId==9?'rootActivityId':'parentActivityId'}=?
                        and virtualPath rlike ?
                        <sql:param value="${reportId==8||reportId==9?actId:parentActivityId}"/>
                        <sql:param value=".*/${empty param.component ? lsstId : param.component}${image.image_url}"/>
                    </sql:query>
                    <c:if test="${filepath.rowCount==0}">
                        Missing image: ${image.image_url}
                    </c:if>
                    <img src="http://srs.slac.stanford.edu/DataCatalog/get?dataset=${filepath.rows[0].catalogKey}" alt="${lsstId}${image.image_url}"/>
                    <c:if test="${!empty image.caption}">
                    <center> <c:out value="${image.caption}"/></center>
                    </c:if>  
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

            <c:if test="${sect.title == 'eTraveler Activity'}">
                <sql:query var="eTravIDs">
                    select res.activityId, res.value from StringResultHarnessed res join Activity act on res.activityId=act.id 
                    where res.name='job_name' and res.value in ('fe55_offline','read_noise_offline','bright_defects_offline','dark_defects_offline','traps_offline','dark_current_offline','cte_offline','prnu_offline','flat_pairs_offline','qe_offline')
                    and act.parentActivityId = ?
                    <sql:param value="${parentActivityId}"/>
                </sql:query>
                <c:if test="${eTravIDs.rowCount > 0}">
                    <display:table name="${eTravIDs.rows}" class="datatable" />
                </c:if>  
            </c:if>

        </c:forEach>
    </c:if>
</body>
</html>
