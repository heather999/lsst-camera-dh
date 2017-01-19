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
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>
<%@taglib prefix="srs_utils" uri="http://srs.slac.stanford.edu/utils" %>
<%@taglib prefix="filter" uri="http://srs.slac.stanford.edu/filter"%>

<head>
    <title>NCR Overview</title>
</head>

<sql:query var="subsystemQ">
    SELECT id, name FROM Subsystem;
</sql:query>


<h1>NCR Current Status</h1>

<filter:filterTable>
    <filter:filterInput var="lsst_num" title="LSST_NUM (substring search)"/>
    <filter:filterSelection title="Subsystem" var="subsystem" defaultValue="0">
        <filter:filterOption value="0">Any</filter:filterOption>
        <c:forEach var="sub" items="${subsystemQ.rows}">
            <filter:filterOption value="${sub.id}"><c:out value="${sub.name}"/></filter:filterOption>
        </c:forEach>
    </filter:filterSelection>
</filter:filterTable>

<c:set var="selectedLsstId" value="${lsst_num}" scope="page"/>
<c:if test="${! empty param.lsstId}">
    <c:set var="selectedLsstId" value="${param.lsstId}" scope="page"/>
</c:if>

<c:set var="ncrTable" value="${portal:getNcrTable(pageContext.session, selectedLsstId, subsystem)}"/>


<%-- defaultsort index starts from 1 --%>
<display:table name="${ncrTable}" export="true" defaultsort="4" defaultorder="descending" class="datatable" id="hdl" >
    <display:column title="NCR Number" sortable="true">
        <c:url var="actLink" value="http://lsst-camera.slac.stanford.edu/eTraveler/exp/LSST-CAMERA/displayActivity.jsp">
            <c:param name="activityId" value="${hdl.rootActivityId}"/>
            <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
        </c:url>
        <a href="${actLink}" target="_blank">${hdl.rootActivityId}</a>
    </display:column>
    <%-- <display:column title="LSST_NUM" sortable="true"> ${hdl.lsstNum}</display:column> --%>
    <display:column title="LSST_NUM" sortable="true" >
        <c:url var="hdwNcrLink" value="http://lsst-camera.slac.stanford.edu/eTraveler/exp/LSST-CAMERA/displayHardware.jsp">
            <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
            <c:param name="hardwareId" value="${hdl.hdwId}"/>
        </c:url>
        <a href="${hdwNcrLink}" target="_blank"><c:out value="${hdl.lsstNum}"/></a>
    </display:column>
    <display:column title="Run Number" sortable="true" >${hdl.runNum}</display:column>
    <display:column title="Hardware Type" sortable="true" >${hdl.hdwType}</display:column>
    <display:column title="NCR Start Time" sortable="true" >${hdl.ncrCreationTime}</display:column>
    <display:column title="Current NCR Status" sortable="true" >${hdl.statusName}</display:column>
    <display:column title="Closed?" sortable="true" >
        <c:choose>
            <c:when test="${hdl.finalStatus == true}">
                <b>
                    <font color="green">
                    <c:out value="DONE"/>
                    </font>
                </b>
            </c:when>
            <c:otherwise>
                <font color="purple">
                <b>
                    <c:out value="OPEN"/>
                </b>
                </font>
            </c:otherwise>
        </c:choose>
    </display:column>
    <display:setProperty name="export.excel.filename" value="ncrStatus.xls"/> 
    <display:setProperty name="export.csv.filename" value="ncrStatus.csv"/> 
    <display:setProperty name="export.xml.filename" value="ncrStatus.xml"/> 
</display:table>

