<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="file" uri="http://portal.lsst.org/fileutils" %>
<%@taglib uri="http://srs.slac.stanford.edu/filter" prefix="filter"%>
<%@taglib uri="http://srs.slac.stanford.edu/utils" prefix="utils"%>
<%@taglib prefix="dp" tagdir="/WEB-INF/tags/dataportal"%>

<%-- 
    One stop shop for run related info
    Author     : tonyj
--%>

<!DOCTYPE html>
<html>
    <head>
        <title>eTraveler Run ${param.run}</title>
    </head>
    <body>
        <h1>eTraveler Run ${param.run}</h1>
        <fmt:setTimeZone value="UTC"/>

        <sql:query var="result">
            select * from (
            select r.runInt,r.runNumber,a.begin,a.end,a.id,p.name ,h.lsstid,h.manufacturer,f.name as status, t.name hardwareType,ss.name subsystem,i.name Site,ll.labels, rr.labels reportLabels,
            (select count(*) from Activity aa join FilepathResultHarnessed ff on (aa.id=ff.activityId) where aa.rootActivityId=a.id) as fileCount,
            (select count(*) from Activity aa join FloatResultHarnessed ff on (aa.id=ff.activityId) where aa.rootActivityId=a.id) as floatCount,
            (select count(*) from Activity aa join IntResultHarnessed ff on (aa.id=ff.activityId) where aa.rootActivityId=a.id) as intCount,
            (select count(*) from Activity aa join StringResultHarnessed ff on (aa.id=ff.activityId) where aa.rootActivityId=a.id) as StringCount
            from Activity a 
            join Process p on (a.processId=p.id)
            join Hardware h on (a.hardwareId=h.id)
            join HardwareType t on (h.hardwareTypeId = t.id)
            join TravelerType tt on (p.id=tt.rootProcessId)
            join Subsystem ss on (ss.id=tt.subsystemId)
            join ActivityStatusHistory s on (s.id = (select max(id) from ActivityStatusHistory ss where ss.activityId=a.id))
            join ActivityFinalStatus f on (f.id=s.activityStatusId)
            join HardwareLocationHistory hlh on (hlh.id= (select max(id) from HardwareLocationHistory ll where ll.hardwareId=h.id and (a.end is null or ll.creationTS < a.end)))
            join Location l on (l.id=hlh.locationId)
            join Site i on (i.id=l.siteId)
            join RunNumber r on (r.rootActivityId=a.id)
            left outer join ( 
                select lh.objectId,group_concat(concat(lg.name,':',l.name) ORDER BY lg.name, l.name SEPARATOR ', ') labels,group_concat(l.id ORDER BY lg.name, l.name) lids
                from Label l
                join LabelGroup lg on (lg.id=l.labelgroupid)
                join Labelable la on (la.id=lg.labelableid and la.tableName='RunNumber')
                join LabelHistory lh on (lh.id=(select max(id) from LabelHistory lhh where lhh.objectid=lh.objectId and lhh.LabelableId=la.id and lhh.labelId=l.id))
                where lh.adding=true
                group by lh.objectId
            ) ll on (ll.objectId=r.id)
            left outer join (
                select lh.objectId,group_concat(l.name ORDER BY l.name SEPARATOR ',') labels,group_concat(l.id ORDER BY lg.name, l.name) lids
                from Label l
                join LabelGroup lg on (lg.id=l.labelgroupid)
                join Labelable la on (la.id=lg.labelableid and la.tableName='TravelerType')
                join LabelHistory lh on (lh.id=(select max(id) from LabelHistory lhh where lhh.objectid=lh.objectId and lhh.LabelableId=la.id and lhh.labelId=l.id))
                where lh.adding=true
                group by lh.objectId               
            ) rr on (rr.objectid=tt.id)
            where a.parentActivityId is null 
            and r.runInt = ?
            ) x
            <sql:param value="${param.run}"/>
        </sql:query>
        <c:set var="run" value="${result.rows[0]}"/>

        <h2>Summary</h2>
        <table class="datatable">
            <utils:trEvenOdd reset="true"><th>Run Number</th><td>${run.runNumber}</td></utils:trEvenOdd>
            <c:url var="travelerURL" value="http://lsst-camera.slac.stanford.edu/eTraveler/exp/LSST-CAMERA/displayActivity.jsp">
                <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
                <c:param name="activityId" value="${run.id}"/>
            </c:url>
            <utils:trEvenOdd><th>Traveler</th><td><a href="${travelerURL}">${run.name}</a></td></utils:trEvenOdd>
            <utils:trEvenOdd><th>Device Type</th><td>${run.hardwareType}</td></utils:trEvenOdd>
            <utils:trEvenOdd><th>Device</th><td>${run.lsstid}</td></utils:trEvenOdd>
            <utils:trEvenOdd><th>Status</th><td>${run.status}</td></utils:trEvenOdd>
            <utils:trEvenOdd><th>Subsystem</th><td>${run.subsystem}</td></utils:trEvenOdd>
            <utils:trEvenOdd><th>Site</th><td>${run.site}</td></utils:trEvenOdd>
            <utils:trEvenOdd><th>Labels</th><td>${run.labels}</td></utils:trEvenOdd>
            <utils:trEvenOdd><th>Begin</th><td><fmt:formatDate value="${run.begin}" pattern="yyyy-MM-dd HH:mm:ss"/></td></utils:trEvenOdd>
            <utils:trEvenOdd><th>End</th><td><fmt:formatDate value="${run.end}" pattern="yyyy-MM-dd HH:mm:ss"/></td></utils:trEvenOdd>
            </table>

        <c:if test="${run.fileCount+run.floatCount+run.intCount+run.StringCount>0}">
            <h2>Reports</h2>
            <ul>
                <li><a href="RawReport.jsp?run=${param.run}">Raw Report</a> (data dump)</li>
                <c:forEach var="reportLabel" items="${fn:split(run.reportLabels,',')}">
                   <li><a href="SummaryReport.jsp?run=${param.run}">${reportLabel}</a></li>
                </c:forEach>
            </ul>
        </c:if>

        <c:if test="${run.fileCount+run.floatCount+run.intCount+run.StringCount>0}">
            <h2>Files</h2>
            <ul>
                <li><a href="runFiles.jsp?run=${param.run}">Files</a></li>
            </ul>            
        </c:if>
    </body>
</html>
