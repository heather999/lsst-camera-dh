<%-- 
    Document   : url
    Created on : Oct 2, 2017, 11:43:13 AM
    Author     : heather
--%>

<%@tag description="Analogous to <c:url> but includes dataSooureMode parameter automatically" pageEncoding="UTF-8"%>

<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>

<%@attribute name="lsstNum" required="true"%>
<%--<%@attribute fragment="true" name="body"%>--%>

<%@attribute name="var" rtexprvalue="false" required="true"%>
<%@variable alias="etHdwLink" name-from-attribute="var" scope="AT_END"%>

<sql:query var="hdwQ" scope="page">
    select Hardware.id FROM Hardware
    WHERE Hardware.lsstId = ?
    <sql:param value="${lsstNum}"/>
</sql:query>

<c:set var="curHdwData" value="${hdwQ.rows[0]}"/>

<c:url var="etHdwLink" value="http://lsst-camera.slac.stanford.edu/eTraveler/exp/LSST-CAMERA/displayHardware.jsp">
    <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
    <c:param name="hardwareId" value="${curHdwData.id}"/>
   <%-- <jsp:invoke fragment="body"/> --%>
</c:url>
