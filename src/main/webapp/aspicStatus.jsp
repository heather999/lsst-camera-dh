<%@page import="java.sql.Statement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="org.srs.web.base.db.ConnectionManager"%>
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="display" uri="http://displaytag.sf.net" %>
<%@taglib prefix="portal" uri="WEB-INF/tags/portal.tld" %>
<%@taglib prefix="srs_utils" uri="http://srs.slac.stanford.edu/utils" %>
<%@taglib prefix="filter" uri="http://srs.slac.stanford.edu/filter"%>

<head>
    <title>ASPIC Overview</title>
</head>


<%-- Select CCD as the HardwareType for this page, scope session means all the pages? set scope to page --%>
<c:set var="aspicHdwTypeId" value="1" scope="page"/>  


<h1>ASPIC Current Status and Location</h1>


<filter:filterTable>
    <filter:filterInput var="lsst_num" title="LSST_NUM (substring search)"/>
</filter:filterTable>

<srs_utils:refresh />
<c:set var="aspicGroup" value="LCA-11721"/>
<c:set var="manu" value="any"/>
<c:set var="hdwStatLocTable" value="${portal:getHdwStatRelationshipTable(pageContext.session, aspicHdwTypeId, lsst_num, manu, aspicGroup)}"/>

<%-- defaultsort index starts from 1 --%>
<display:table name="${hdwStatLocTable}" export="true" defaultsort="9" defaultorder="descending" class="datatable" id="hdl" >
    <%-- <display:column title="LsstId" sortable="true" >${hdl.lsstId}</display:column> --%>
    <display:column title="LSST_NUM" sortable="true">
        <c:url var="outLink" value="allHarnessedOutput.jsp">
            <c:param name="lsstNum" value="${hdl.lsstId}"/>
            <c:param name="hdwGroup" value="LCA-11721"/>
            <c:param name="schema" value="aspic_activity"/>
            <c:param name="major" value="activity_type"/>
            <c:param name="minor" value="status"/>
        </c:url>                
        <a href="${outLink}" target="_blank"><c:out value="${hdl.lsstId}"/></a>
    </display:column>
    <display:column title="Date Registered" sortable="true" >${hdl.creationDate}</display:column>
    <display:column title="Overall Component Status" sortable="true" >${hdl.status}</display:column>
    <display:column title="Site" sortable="true" >${hdl.site}</display:column>
    <display:column title="Location" sortable="true" >${hdl.location}</display:column>
    <display:column title="Relationship" sortable="true" >${hdl.relationshipName}</display:column>
    <display:column title="Current Traveler" sortable="true" >${hdl.curTravelerName}</display:column>
    <display:column title="Current Process Step" sortable="true" >${hdl.curActivityProcName}</display:column>
    <display:column title="Current Process Step Status" sortable="true" >${hdl.curActivityStatus}</display:column>
    <display:column title="Most Recent Timestamp" sortable="true" >${hdl.curActivityLastTime}</display:column>
    <display:column title="NCR" sortable="true" >${hdl.inNCR}</display:column>
    <display:setProperty name="export.excel.filename" value="sensorStatus.xls"/> 
    <display:setProperty name="export.csv.filename" value="sensorStatus.csv"/> 
    <display:setProperty name="export.xml.filename" value="sensorStatus.xml"/> 
</display:table>

<c:if test="${'Dev' == appVariables.dataSourceMode}">
    <c:set var="demoGroup" value="LCA-ASPIC"/>
    <br>
    <br>
    <b>DEMO for LCA-ASPIC Group</b>
    <c:set var="demoTable" value="${portal:getHdwStatRelationshipTable(pageContext.session, aspicHdwTypeId, lsst_num, manu, demoGroup)}"/>
    <display:table name="${demoTable}" export="false" defaultsort="9" defaultorder="descending" class="datatable" id="demo" >
        <display:column title="LSST_NUM" sortable="true">
            <c:url var="outLink" value="allHarnessedOutput.jsp">
                <c:param name="lsstNum" value="${demo.lsstId}"/>
                <c:param name="hdwGroup" value="LCA-11721"/>
                <c:param name="schema" value="aspic_activity"/>
                <c:param name="major" value="activity_type"/>
                <c:param name="minor" value="status"/>
            </c:url>                
            <a href="${outLink}" target="_blank"><c:out value="${demo.lsstId}"/></a>
        </display:column>
        <display:column title="Date Registered" sortable="true" >${demo.creationDate}</display:column>
        <display:column title="Overall Component Status" sortable="true" >${demo.status}</display:column>
        <display:column title="Site" sortable="true" >${demo.site}</display:column>
        <display:column title="Location" sortable="true" >${demo.location}</display:column>
        <display:column title="Relationship" sortable="true" >${demo.relationshipName}</display:column>
        <display:column title="Current Traveler" sortable="true" >${demo.curTravelerName}</display:column>
        <display:column title="Current Process Step" sortable="true" >${demo.curActivityProcName}</display:column>
        <display:column title="Current Process Step Status" sortable="true" >${demo.curActivityStatus}</display:column>
        <display:column title="Most Recent Timestamp" sortable="true" >${demo.curActivityLastTime}</display:column>
        <display:column title="NCR" sortable="true" >${demo.inNCR}</display:column>
    </display:table>
</c:if>