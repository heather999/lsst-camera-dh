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

<%-- 
    One stop shop for device related info
    Author     : tonyj
--%>

<!DOCTYPE html>
<html>
    <head>
        <title>eTraveler Device ${param.lsstId}</title>
    </head>
    <body>
        <h1>eTraveler Device ${param.lsstId}</h1>
        <fmt:setTimeZone value="UTC"/>

        <sql:query var="result">
            select * from (
            select h.id,h.lsstId,h.manufacturer,h.model,h.manufactureDate,t.name type,ss.name subsystem,l.name location,i.name site,st.name status,
            (select group_concat(ls.name) from HardwareStatusHistory hlh 
               join HardwareStatus ls on (ls.id=hlh.hardwareStatusId) 
               where hlh.id in ( 
               select max(ss.id) from HardwareStatusHistory ss 
                  join HardwareStatus stst on (ss.hardwareStatusId=stst.id)
                  where ss.hardwareId=h.id and stst.isStatusValue=false group by hardwareStatusId
               )
               and hlh.adding=true
               group by hlh.hardwareId
               order by ls.name
            ) labels
            from Hardware h
            join HardwareType t on (h.hardwareTypeId = t.id)
            join Subsystem ss on (ss.id=t.subsystemId)
            join HardwareLocationHistory hlh on (hlh.id= (select max(id) from HardwareLocationHistory ll where ll.hardwareId=h.id))
            join Location l on (l.id=hlh.locationId)
            join Site i on (i.id=l.siteId)
            left outer join HardwareStatusHistory hsh on (hsh.id= (
               select max(ss.id) from HardwareStatusHistory ss 
               join HardwareStatus stst on (ss.hardwareStatusId=stst.id)
               where ss.hardwareId=h.id and stst.isStatusValue=true))
            left outer join HardwareStatus st on (hsh.hardwareStatusId=st.id)
            where h.lsstId=?
            ) x
            <sql:param value="${param.lsstId}"/>
        </sql:query>
        <c:set var="device" value="${result.rows[0]}"/>

        <h2>Summary</h2>
        <table class="datatable">
            <utils:trEvenOdd reset="true"><th>Device</th><td>${device.lsstId}</td></utils:trEvenOdd>
            <utils:trEvenOdd><th>Manufacturer</th><td>${device.manufacturer}</td></utils:trEvenOdd>
            <utils:trEvenOdd><th>Model</th><td>${device.model}</td></utils:trEvenOdd>
            <utils:trEvenOdd><th>Type</th><td>${device.type}</td></utils:trEvenOdd>
            <utils:trEvenOdd><th>Manufacture Date</th><td><fmt:formatDate value="${device.manufactureDate}" pattern="yyyy-MM-dd"/></td></utils:trEvenOdd>
            <utils:trEvenOdd><th>Subsystem</th><td>${device.subsystem}</td></utils:trEvenOdd>
            <utils:trEvenOdd><th>Current Location</th><td>${device.location}</td></utils:trEvenOdd>
            <utils:trEvenOdd><th>Current Site</th><td>${device.site}</td></utils:trEvenOdd>
            <utils:trEvenOdd><th>Current Status</th><td>${device.status}</td></utils:trEvenOdd>
            <utils:trEvenOdd><th>Labels</th><td>${device.labels}</td></utils:trEvenOdd>
        </table>
         <c:url var="hardware" value="/eTraveler/exp/LSST-CAMERA/displayHardware.jsp">
            <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
            <c:param name="hardwareId" value="${device.id}"/>
        </c:url>
        See also the <a href="${hardware}">full e-Traveler Component page</a>.
        <h2>Reports for device</h2>
        
        <c:if test="${device.type=='ITL-CCD' || device.type=='e2v-CCD'}">
            <c:url var="deviceReport" value="SensorAcceptanceReport.jsp">
                <c:param name="lsstId" value="${device.lsstId}"/>
            </c:url>
            <a href="${deviceReport}">Sensor Acceptance Report</a>
        </c:if>

        <h2>Runs for device</h2>

        <sql:query var="runs">
            select * from (
            select r.runInt,r.runNumber,a.begin,a.end,p.name ,h.lsstid,h.manufacturer,f.name as status, t.name hardwareType,ss.name subsystem,i.name Site,
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
            where a.parentActivityId is null 
            and a.id=(select max(id) from Activity aaa where aaa.processId=a.processId and aaa.hardwareId=a.hardwareId)
            and h.lsstId=?
            <sql:param value="${param.lsstId}"/>
            ) x
        </sql:query>

        <display:table name="${runs.rows}" sort="list" defaultsort="1" defaultorder="descending" class="datatable" id="run" >
            <display:column property="runNumber" sortProperty="runInt" title="Run" sortable="true" href="run.jsp" paramId="run"/>
            <display:column property="name" title="Traveler" sortable="true"/>
            <display:column property="status" title="Status" sortable="true"/>
            <display:column property="site" title="Site" sortable="true"/>
            <display:column sortProperty="begin" title="Begin (UTC)" sortable="true">
                <fmt:formatDate value="${run.begin}" pattern="yyyy-MM-dd HH:mm:ss"/>
            </display:column>
            <display:column sortProperty="end" title="End (UTC)" sortable="true">
                <fmt:formatDate value="${run.end}" pattern="yyyy-MM-dd HH:mm:ss"/>
            </display:column>
            <display:column title="Reports" class="leftAligned">
                <c:if test="${run.fileCount+run.floatCount+run.intCount+run.StringCount>0}">
                    <c:url var="report" value="RawReport.jsp">
                        <c:param name="run" value="${run.runNumber}"/>
                    </c:url>
                    <a href="${report}">Raw</a> 
                    <c:if test="${run.name=='SR-EOT-02'}">
                        <c:url var="report" value="SummaryReport.jsp">
                            <c:param name="run" value="${run.runNumber}"/>
                        </c:url>
                        <a href="${report}">EO</a>
                    </c:if>
                    <c:if test="${run.name=='SR-RSA-MET-07'}">
                        <c:url var="report" value="SummaryReport.jsp">
                            <c:param name="run" value="${run.runNumber}"/>
                        </c:url>
                        <a href="${report}">MET</a>
                    </c:if>
                </c:if>
            </display:column>
            <display:column title="Links" class="leftAligned">
                <c:if test="${run.fileCount>0}">
                    <c:url var="files" value="runFiles.jsp">
                        <c:param name="run" value="${run.runNumber}"/>
                    </c:url>
                    <a href="${files}">Files</a>
                </c:if>
            </display:column>
        </display:table>

    </body>
</html>
