<%-- 
    Document   : runList
    Created on : Jan 8, 2017, 10:09:38 AM
    Author     : tonyj
--%>

<%@tag description="A tag for generating run lists" pageEncoding="UTF-8"%>

<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="file" uri="http://portal.lsst.org/fileutils" %>

<%@attribute name="mostRecent" type="java.lang.Boolean" description="Display only most recent run for each traveler"%>
<%@attribute name="runMin" type="java.lang.String" description="Minimum run number to display"%>
<%@attribute name="runMax" type="java.lang.String" description="Maximum run number to display"%>
<%@attribute name="traveler" type="java.lang.String" description="Traveler to display"%>
<%@attribute name="subsystem" type="java.lang.String" description="Subsystem to display"%>
<%@attribute name="site" type="java.lang.String" description="Site to display"%>
<%@attribute name="status" type="java.lang.String" description="Status to display"%>
<%@attribute name="device" type="java.lang.String" description="Device to display"%>

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
    <c:if test="${mostRecent}">
        and a.id=(select max(id) from Activity aaa where aaa.processId=a.processId and aaa.hardwareId=a.hardwareId)
    </c:if>
    <c:if test="${!empty runMin}">
        and r.runInt>=?
        <sql:param value="${runMin}"/>
    </c:if>
    <c:if test="${!empty runMax}">
        and r.runInt<=?
        <sql:param value="${runMax}"/>
    </c:if>
    <c:if test="${!empty traveler && traveler!='any'}">
        and p.name=?
        <sql:param value="${traveler}"/>
    </c:if>           
    <c:if test="${!empty subsystem && subsystem!='any'}">
        and ss.name=?
        <sql:param value="${subsystem}"/>
    </c:if>   
    <c:if test="${!empty site && site!='any'}">
        and i.name=?
        <sql:param value="${site}"/>
    </c:if> 
    <c:if test="${!empty device && device!='any'}">
        and h.lsstId=?
        <sql:param value="${device}"/>
    </c:if> 
    <c:choose>
        <c:when test="${status>=0}">
            and f.id=?
            <sql:param value="${status}"/>
        </c:when>
        <c:when test="${status==-2}">
            and f.isFinal=true
        </c:when>
        <c:when test="${status==-3}">
            and f.isFinal=false
        </c:when>
    </c:choose>
    ) x
</sql:query>

<display:table name="${runs.rows}" sort="list" defaultsort="1" defaultorder="descending" class="datatable" id="run" >
    <display:column property="runNumber" sortProperty="runInt" title="Run" sortable="true" href="run.jsp" paramId="run"/>
    <display:column property="name" title="Traveler" sortable="true"/>
    <display:column property="hardwareType" title="Device Type" sortable="true"/>
    <c:if test="${empty device || device=='any'}">
       <display:column property="lsstid" title="Device" sortable="true" href="device.jsp" paramId="lsstId"/>
    </c:if>
    <display:column property="status" title="Status" sortable="true"/>
    <display:column property="subsystem" title="Subsystem" sortable="true"/>
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
            <c:if test="${run.name=='Simulated_RAFT-EOT-01'}">
                <c:url var="report" value="SummaryReport.jsp">
                    <c:param name="run" value="${run.runNumber}"/>
                </c:url>
                <a href="${report}">EO-RAFT</a>
            </c:if>
            <c:if test="${run.name=='Simulated_RTM-EOT-01'}">
                <c:url var="report" value="SummaryReport.jsp">
                    <c:param name="run" value="${run.runNumber}"/>
                </c:url>
                <a href="${report}">EO-RAFT</a>
            </c:if>
            <c:if test="${run.name=='SR-RTM-EOT-03'}">
                <c:url var="report" value="SummaryReport.jsp">
                    <c:param name="run" value="${run.runNumber}"/>
                </c:url>
                <a href="${report}">EO-RAFT</a>
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
