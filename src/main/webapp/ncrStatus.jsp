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
    <title>NCR Overview</title>
</head>
<c:set var="ccdGroup" value="Generic-CCD" scope="page"/>
<c:set var="ccdTypeString" value="${portal:getHardwareTypesFromGroup(pageContext.session,ccdGroup)}"/>
<sql:query var="manufacturerQ">
    SELECT DISTINCT manufacturer FROM Hardware, HardwareType where Hardware.hardwareTypeId=HardwareType.id AND HardwareType.id IN ${ccdTypeString} ORDER BY manufacturer;
</sql:query>




<h1>NCR Current Status</h1>


<filter:filterTable>
    <filter:filterInput var="lsst_num" title="LSST_NUM (substring search)"/>
    <filter:filterSelection title="Manufacturer" var="manu" defaultValue="any">
        <filter:filterOption value="any">Any</filter:filterOption>
            <c:forEach var="hdw" items="${manufacturerQ.rows}">
            <filter:filterOption value="${hdw.manufacturer}"><c:out value="${hdw.manufacturer}"/></filter:filterOption>
            </c:forEach>
    </filter:filterSelection>
</filter:filterTable>

<c:set var="ncrTable" value="${portal:getNcrTable(pageContext.session, lsst_num)}"/>


<%-- defaultsort index starts from 1 --%>
<display:table name="${ncrTable}" export="true" defaultsort="7" defaultorder="descending" class="datatable" id="hdl" >
    <display:column title="NCR ID" sortable="true">
        <c:url var="actLink" value="http://lsst-camera.slac.stanford.edu/eTraveler/exp/LSST-CAMERA/displayActivity.jsp">
            <c:param name="activityId" value="${hdl.rootActivityId}"/>
            <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
        </c:url>
        <a href="${actLink}" target="_blank">${hdl.rootActivityId}</a>
    </display:column>
    <display:column title="LSST_NUM" sortable="true">
        <c:url var="explorerLink" value="oneComponent.jsp">
            <c:param name="lsstIdValue" value="${hdl.lsstNum}"/>
        </c:url>                
        <a href="${explorerLink}"><c:out value="${hdl.lsstNum}"/></a>
    </display:column>
    <display:column title="Hardware Type" sortable="true" >${hdl.hdwType}</display:column>
    <display:column title="NCR Start Time" sortable="true" >${hdl.ncrCreationTime}</display:column>
    <display:column title="Current NCR Status" sortable="true" >${hdl.statusName}</display:column>
    <display:column title="Final Status?" sortable="true" >${hdl.finalStatus}</display:column>
    <display:setProperty name="export.excel.filename" value="ncrStatus.xls"/> 
    <display:setProperty name="export.csv.filename" value="ncrStatus.csv"/> 
    <display:setProperty name="export.xml.filename" value="ncrStatus.xml"/> 
</display:table>

  