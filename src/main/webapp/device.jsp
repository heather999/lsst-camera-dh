<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="file" uri="http://portal.lsst.org/fileutils" %>
<%@taglib uri="http://srs.slac.stanford.edu/filter" prefix="filter"%>
<%@taglib uri="http://srs.slac.stanford.edu/utils" prefix="utils"%>
<%@taglib prefix="dp" tagdir="/WEB-INF/tags/dataportal"%>

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

        <dp:runList mostRecent="true" device="${param.lsstId}"/>     

    </body>
</html>
