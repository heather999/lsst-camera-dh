<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="file" uri="http://portal.lsst.org/fileutils" %>

<%-- 
    Provide a run centric listing of eTravelers
    Document   : runList.jsp
    Created on : Sep 18, 2016, 5:32:51 PM
    Author     : tonyj
--%>

<!DOCTYPE html>
<html>
    <head>
        <title>eTraveler Runs</title>
    </head>
    <body>
        <h1>eTraveler Runs</h1>
        <fmt:setTimeZone value="UTC"/>

        <sql:query var="runs">
            select * from (
                select a.id,a.begin,a.end,p.name ,h.lsstid,h.manufacturer,f.name as status, t.name hardwareType,
                (select count(*) from Activity aa join FilepathResultHarnessed ff on (aa.id=ff.activityId) where aa.rootActivityId=a.id) as fileCount
                from Activity a 
                join Process p on (a.processId=p.id)
                join Hardware h on (a.hardwareId=h.id)
                join HardwareType t on (h.hardwareTypeId = t.id)
                join ActivityStatusHistory s on (s.id = (select max(id) from ActivityStatusHistory ss where ss.activityId=a.id))
                join ActivityFinalStatus f on (f.id=s.activityStatusId)
                where a.parentActivityId is null and a.id=(select max(id) from Activity aaa where aaa.processId=a.processId and aaa.hardwareId=a.hardwareId) 
            ) x
        </sql:query>

        <display:table name="${runs.rows}" sort="list" defaultsort="1" defaultorder="descending" class="datatable" id="run" >
            <display:column property="id" title="Run" sortable="true"/>
            <display:column property="name" title="Traveler" sortable="true"/>
            <display:column property="lsstid" title="Device" sortable="true"/>
            <display:column property="hardwareType" title="Device Type" sortable="true"/>
            <display:column property="status" title="Status" sortable="true"/>
            <display:column sortProperty="begin" title="Begin (UTC)" sortable="true">
                <fmt:formatDate value="${run.begin}" pattern="yyyy-MM-dd HH:mm:ss"/>
            </display:column>
            <display:column sortProperty="end" title="End (UTC)" sortable="true">
                <fmt:formatDate value="${run.end}" pattern="yyyy-MM-dd HH:mm:ss"/>
            </display:column>
            <display:column title="Links" class="leftAligned">
                <c:if test="${run.fileCount>0}">
                    <c:url var="files" value="runFiles.jsp">
                        <c:param name="run" value="${run.id}"/>
                    </c:url>
                    <a href="${files}">Files</a>
                </c:if>
            </display:column>
        </display:table>
    </body>
</html>
