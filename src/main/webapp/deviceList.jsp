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
    Filterable list of devices, including links to reports where appropriate
    Author     : tonyj
--%>

<!DOCTYPE html>
<html>
    <head>
        <title>eTraveler Devices</title>
    </head>
    <body>
        <h1>eTraveler Devices</h1>
        <fmt:setTimeZone value="UTC"/>
        <filter:filterTable>
            <filter:filterSelection title="Status" var="status" defaultValue='-1'>
                <filter:filterOption value="-1">Any</filter:filterOption>
                <sql:query var="statii">
                    select id,name from HardwareStatus where isStatusValue=true order by id
                </sql:query>
                <c:forEach var="row" items="${statii.rows}">
                    <filter:filterOption value="${row.id}">${row.name}</filter:filterOption>
                </c:forEach>
            </filter:filterSelection>
            <filter:filterSelection title="Type" var="group" defaultValue="9">
                <sql:query var="groups">
                    select id,name from HardwareGroup order by name
                </sql:query>
                <c:forEach var="row" items="${groups.rows}">
                    <filter:filterOption value="${row.id}">${row.name}</filter:filterOption>
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
            <filter:filterSelection title="Label" var="label" defaultValue="any">
                <filter:filterOption value="any">Any</filter:filterOption>
                <filter:filterOption value="none">None</filter:filterOption>
                <sql:query var="labels">
                    select id,name from HardwareStatus where isStatusValue=false
                </sql:query>
                <c:forEach var="row" items="${labels.rows}">
                    <filter:filterOption value="${row.id}">${row.name}</filter:filterOption>
                </c:forEach>
            </filter:filterSelection>
        </filter:filterTable>
        <sql:query var="devices">
            select * from (
            select h.id,h.lsstId,h.manufacturer,h.model,h.manufactureDate,t.name type,ss.name subsystem,l.name location,i.name site,st.name status,l.labels
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
            left outer join ( 
            select hlh.hardwareId,group_concat(ls.name) labels,group_concat(ls.id) lids  from HardwareStatusHistory hlh 
            join HardwareStatus ls on (ls.id=hlh.hardwareStatusId) 
            where hlh.id in ( 
            select max(ss.id) from HardwareStatusHistory ss 
            join HardwareStatus stst on (ss.hardwareStatusId=stst.id)
            where ss.hardwareId=hlh.hardwareId and stst.isStatusValue=false group by hardwareStatusId
            )
            and hlh.adding=true
            group by hlh.hardwareId
            order by ls.name
            ) l on (l.hardwareId=h.id)
            where true
            <c:if test="${subsystem!='any'}">
                and ss.name=?
                <sql:param value="${subsystem}"/>
            </c:if> 
            <c:if test="${site!='any'}">
                and i.name=?
                <sql:param value="${site}"/>
            </c:if> 
            <c:if test="${status>=0}">
                and st.id=?
                <sql:param value="${status}"/>
            </c:if>
            <c:if test="${group!=9}">
                and t.id in (select hardwareTypeId from HardwareTypeGroupMapping where hardwareGroupId=?)
                <sql:param value="${group}"/>
            </c:if>
            <c:choose>
                <c:when test="${label=='any'}">
                </c:when>
                <c:when test="${label=='none'}">
                    and lids is null
                </c:when>
                <c:when test="${!empty label}">
                    and find_in_set(?,lids)<>0
                    <sql:param value="${label}"/>
                </c:when>
            </c:choose>                
            ) x
        </sql:query>

        <display:table name="${devices.rows}" sort="list" defaultsort="1" defaultorder="descending" class="datatable" id="device">
            <display:column property="lsstId" title="Device" sortable="true" href="device.jsp" paramId="lsstId"/>
            <display:column property="manufacturer" title="Manufacturer" sortable="true"/>
            <display:column property="model" title="Model" sortable="true"/>
            <display:column property="type" title="Type" sortable="true"/>
            <display:column sortProperty="manufactureDate" title="Manufacture Date" sortable="true">
                <fmt:formatDate value="${device.manufactureDate}" pattern="yyyy-MM-dd"/>
            </display:column>
            <display:column property="subsystem" title="Subsystem" sortable="true"/>
            <display:column property="location" title="Location" sortable="true"/>
            <display:column property="site" title="Site" sortable="true"/>
            <display:column property="status" title="Status" sortable="true"/>
            <display:column property="labels" title="Labels" sortable="true"/>
            <display:column title="Reports" class="leftAligned">
                <c:if test="${device.type=='ITL-CCD' || device.type=='e2v-CCD'}">
                    <c:url var="deviceReport" value="SensorAcceptanceReport.jsp">
                        <c:param name="lsstId" value="${device.lsstId}"/>
                    </c:url>
                    <a href="${deviceReport}">SA</a>
                </c:if>
            </display:column>
        </display:table>
    </body>
</html>
