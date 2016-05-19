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
    <title>CCD Overview</title>
</head>
<c:set var="ccdGroup" value="Generic-CCD" scope="page"/>
<c:set var="ccdTypeString" value="${portal:getHardwareTypesFromGroup(pageContext.session,ccdGroup)}"/>
<sql:query var="manufacturerQ">
    SELECT DISTINCT manufacturer FROM Hardware, HardwareType where Hardware.hardwareTypeId=HardwareType.id AND HardwareType.id IN ${ccdTypeString} ORDER BY manufacturer;
</sql:query>

<%-- Select CCD as the HardwareType for this page, scope session means all the pages? set scope to page --%>
<c:set var="ccdHdwTypeId" value="1" scope="page"/>  
<%-- HMK Jan 7 2016 Appears unused
<sql:query  var="ccdList"  >
    select  Hardware.id,Hardware.lsstId from Hardware,HardwareType where Hardware.hardwareTypeId=HardwareType.id and (HardwareType.id=? OR HardwareType.id=9 OR HardwareType.id=10) 
    <sql:param value="${ccdHdwTypeId}"/>
</sql:query>
--%>



<h1>CCD Current Status and Location</h1>


<filter:filterTable>
    <filter:filterInput var="lsst_num" title="LSST_NUM (substring search)"/>
    <filter:filterSelection title="Manufacturer" var="manu" defaultValue="any">
        <filter:filterOption value="any">Any</filter:filterOption>
            <c:forEach var="hdw" items="${manufacturerQ.rows}">
            <filter:filterOption value="${hdw.manufacturer}"><c:out value="${hdw.manufacturer}"/></filter:filterOption>
            </c:forEach>
    </filter:filterSelection>
</filter:filterTable>

<srs_utils:refresh />
<c:set var="hdwStatLocTable" value="${portal:getHdwStatLocTable(pageContext.session,ccdHdwTypeId, lsst_num, manu, ccdGroup, true)}"/>

<%-- defaultsort index starts from 1 --%>
<display:table name="${hdwStatLocTable}" export="true" defaultsort="9" defaultorder="descending" class="datatable" id="hdl" >
    <%-- <display:column title="LsstId" sortable="true" >${hdl.lsstId}</display:column> --%>
    <display:column title="LSST_NUM" sortable="true">
        <c:url var="explorerLink" value="oneComponent.jsp">
            <c:param name="lsstIdValue" value="${hdl.lsstId}"/>
        </c:url>                
        <a href="${explorerLink}"><c:out value="${hdl.lsstId}"/></a>
    </display:column>
    <display:column title="Date Registered" sortable="true" >${hdl.creationDate}</display:column>
    <display:column title="Overall Component Status" sortable="true" >${hdl.status}</display:column>
    <display:column title="Site" sortable="true" >${hdl.site}</display:column>
    <display:column title="Location" sortable="true" >${hdl.location}</display:column>
    <display:column title="Current Traveler" sortable="true" >${hdl.curTravelerName}</display:column>
    <display:column title="Current Process Step" sortable="true" >${hdl.curActivityProcName}</display:column>
    <display:column title="Current Process Step Status" sortable="true" >${hdl.curActivityStatus}</display:column>
    <display:column title="Most Recent Timestamp" sortable="true" >${hdl.curActivityLastTime}</display:column>
    <display:column title="NCR" sortable="true" >${hdl.inNCR}</display:column>
    <display:setProperty name="export.excel.filename" value="sensorStatus.xls"/> 
    <display:setProperty name="export.csv.filename" value="sensorStatus.csv"/> 
    <display:setProperty name="export.xml.filename" value="sensorStatus.xml"/> 
</display:table>
<%--
  <display:column title="Traveler Elasped Time (s)" sortable="true" >${hdl.elapsedTravTime}</display:column> 
  --%>
  
  