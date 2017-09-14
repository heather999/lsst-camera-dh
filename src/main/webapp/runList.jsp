<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="file" uri="http://portal.lsst.org/fileutils" %>
<%@taglib uri="http://srs.slac.stanford.edu/filter" prefix="filter"%>
<%@taglib prefix="dp" tagdir="/WEB-INF/tags/dataportal"%>

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
        <filter:filterTable>
            <filter:filterCheckbox title="Most Recent" var="mostRecent" defaultValue="true"/>
            <filter:filterSelection title="Status" var="status" defaultValue='-1'>
                <filter:filterOption value="-1">Any</filter:filterOption>
                <filter:filterOption value="-2">Any final</filter:filterOption>
                <filter:filterOption value="-3">Any non-final</filter:filterOption>
                <sql:query var="statii">
                    select id,name from ActivityFinalStatus order by id
                </sql:query>
                <c:forEach var="row" items="${statii.rows}">
                    <filter:filterOption value="${row.id}">${row.name}</filter:filterOption>
                </c:forEach>
            </filter:filterSelection>
            <filter:filterSelection title="Traveler" var="traveler" defaultValue="any">
                <filter:filterOption value="any">Any</filter:filterOption>
                <sql:query var="travelers">
                    select distinct p.name
                    from Activity a 
                    join Process p on (a.processId=p.id)
                    where a.parentActivityId is null order by p.name
                </sql:query>
                <c:forEach var="row" items="${travelers.rows}">
                    <filter:filterOption value="${row.name}">${row.name}</filter:filterOption>
                </c:forEach>
            </filter:filterSelection>
            <filter:filterSelection title="Subsystem" var="subsystem" defaultValue="any">
                <filter:filterOption value="any">Any</filter:filterOption>
                <sql:query var="subsystems">
                    select name from Subsystem order by name
                </sql:query>
                <c:forEach var="row" items="${subsystems.rows}">
                    <filter:filterOption value="${row.name}">${row.name}</filter:filterOption>
                </c:forEach>
            </filter:filterSelection>
            <filter:filterSelection title="Site" var="site" defaultValue="any">
                <filter:filterOption value="any">Any</filter:filterOption>
                <sql:query var="sites">
                    select name from Site order by name
                </sql:query>
                <c:forEach var="row" items="${sites.rows}">
                    <filter:filterOption value="${row.name}">${row.name}</filter:filterOption>
                </c:forEach>
            </filter:filterSelection>
            <filter:filterSelection title="Label" var="labels" defaultValue="any">
                <filter:filterOption value="any">Don't care</filter:filterOption>
                <filter:filterOption value="anyLabel">Any</filter:filterOption>
                <filter:filterOption value="none">None</filter:filterOption>
                <sql:query var="labels">
                    select DISTINCT concat(LG.name,':',L.name) name, L.id FROM Label L
                    INNER JOIN LabelGroup LG on LG.id=L.labelGroupId
                    join Labelable on Labelable.id=LG.labelableId
                    WHERE Labelable.name="run"
                    ORDER BY LG.name, L.name
                </sql:query>
                <c:forEach var="row" items="${labels.rows}">
                    <filter:filterOption value="${row.id}">${row.name}</filter:filterOption>
                </c:forEach>
            </filter:filterSelection>
            <filter:filterInput title="Run min" var="runMin"/>
            <filter:filterInput title="Run max" var="runMax"/>
        </filter:filterTable>

        <dp:runList mostRecent="${mostRecent}" runMin="${runMin}" runMax="${runMax}" site="${site}" status="${status}" subsystem="${subsystem}" traveler="${traveler}" labels="${labels}"/>     
    </body>
</html>
