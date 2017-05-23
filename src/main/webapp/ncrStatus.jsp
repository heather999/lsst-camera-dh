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

    <%-- find all the NCR labels --%>
    
<sql:query var="ncrLabelQ">
    select DISTINCT L.name, L.id FROM Label L
    INNER JOIN LabelHistory LH on L.id=LH.labelId
    INNER JOIN LabelGroup LG on LG.id=L.labelGroupId
    INNER JOIN Labelable LL on LL.id=LG.labelableId
    WHERE LOWER(LL.name)='ncr' AND LOWER(LG.name)!='priority';
</sql:query>
    
    
<sql:query var="priorityLabelQ">
  select DISTINCT L.name, L.id FROM Label L
  INNER JOIN LabelGroup LG on LG.id=L.labelGroupId
  INNER JOIN Labelable LL on LL.id=LG.labelableId
  WHERE LOWER(LL.name)='ncr' AND LOWER(LG.name)='priority';
</sql:query>
    

<h1>NCR Current Status</h1>

<input type=button onClick="parent.open('https://confluence.slac.stanford.edu/display/LSSTCAM/NCR+Traveler')" value='Confluence Doc'>

<filter:filterTable>
    <filter:filterInput var="lsst_num" title="LSST_NUM (substring search)"/>
    <filter:filterSelection title="Subsystem" var="subsystem" defaultValue="0">
        <filter:filterOption value="0">Any</filter:filterOption>
        <c:forEach var="sub" items="${subsystemQ.rows}">
            <filter:filterOption value="${sub.id}"><c:out value="${sub.name}"/></filter:filterOption>
        </c:forEach>
    </filter:filterSelection>
    <filter:filterSelection title="Label" var="label" defaultValue="-1">
        <filter:filterOption value="0">Any</filter:filterOption>
        <c:forEach var="lab" items="${ncrLabelQ.rows}">
            <filter:filterOption value="${lab.id}"><c:out value="${lab.name}"/></filter:filterOption>
        </c:forEach>
        <filter:filterOption value="-1">ExcludeMistakes</filter:filterOption>
    </filter:filterSelection>
    <filter:filterSelection title="Priority" var="priorityLab" defaultValue="0">
        <filter:filterOption value="0">Any</filter:filterOption>
        <c:forEach var="p" items="${priorityLabelQ.rows}">
            <filter:filterOption value="${p.id}"><c:out value="${p.name}"/></filter:filterOption>
        </c:forEach>
    </filter:filterSelection>
    <filter:filterSelection title="Status" var="ncrStatus" defaultValue="1">
        <filter:filterOption value="0">Any</filter:filterOption>
        <filter:filterOption value="1">Open</filter:filterOption>
        <filter:filterOption value="2">Done</filter:filterOption>
    </filter:filterSelection>
</filter:filterTable>

       
        
        
<c:set var="selectedLsstId" value="${lsst_num}" scope="page"/>
<c:if test="${! empty param.lsstId}">
    <c:set var="selectedLsstId" value="${param.lsstId}" scope="page"/>
</c:if>

<c:set var="ncrTable" value="${portal:getNcrTable(pageContext.session, selectedLsstId, subsystem, label, priorityLab, ncrStatus)}"/>


<%-- defaultsort index starts from 1 --%>
<display:table name="${ncrTable}" export="true" defaultsort="4" defaultorder="descending" class="datatable" id="hdl" >
    <display:column title="NCR Number" sortable="true" sortProperty="rootActivityId" >
        <c:url var="actLink" value="http://lsst-camera.slac.stanford.edu/eTraveler/exp/LSST-CAMERA/displayActivity.jsp">
            <c:param name="activityId" value="${hdl.rootActivityId}"/>
            <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
        </c:url>
        <a href="${actLink}" target="_blank">${hdl.rootActivityId}</a>
    </display:column>
    <display:column title="LSST_NUM" sortable="true" sortProperty="lsstNum">
        <c:url var="hdwNcrLink" value="http://lsst-camera.slac.stanford.edu/eTraveler/exp/LSST-CAMERA/displayHardware.jsp">
            <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
            <c:param name="hardwareId" value="${hdl.hdwId}"/>
        </c:url>
        <a href="${hdwNcrLink}" target="_blank"><c:out value="${hdl.lsstNum}"/></a>
    </display:column>
    <display:column title="Run Number" sortable="true" >${hdl.runNum}</display:column>
    <display:column title="Hardware Type" sortable="true" >${hdl.hdwType}</display:column>
    <display:column title="NCR Start Time" sortable="true" >${hdl.ncrCreationTime}</display:column>
    <display:column title="Priority" sortable="true" >${hdl.priority}</display:column>
    <display:column title="Current NCR Status" sortable="true" >${hdl.statusName}</display:column>
    <display:column title="Current Step" sortable="true" >${hdl.currentStep}</display:column>
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

