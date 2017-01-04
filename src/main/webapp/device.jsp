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
            select * from Hardware where lsstId=?
            <sql:param value="${param.lsstId}"/>
        </sql:query>
        <c:set var="device" value="${result.rows[0]}"/>

        <h2>Summary</h2>
        <table class="datatable">
            <utils:trEvenOdd reset="true"><th>Device</th><td>${device.lsstId}</td></utils:trEvenOdd>
            <utils:trEvenOdd><th>Manufacturer</th><td>${device.manufacturer}</td></utils:trEvenOdd>
            <utils:trEvenOdd><th>Model</th><td>${device.model}</td></utils:trEvenOdd>
            <utils:trEvenOdd><th>Manufacture Date</th><td><fmt:formatDate value="${device.manufactureDate}" pattern="yyyy-MM-dd"/></td></utils:trEvenOdd>
        </table>
    </body>
</html>
