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
<%@taglib prefix="dp" tagdir="/WEB-INF/tags/dataportal"%>
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
    <filter:filterCheckbox title="Signatures" var="signatures" defaultValue="false"/>
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


<dp:ncr lsst_num="${lsst_num}" signatures="${signatures}" subsystem="${subsystem}" label="${label}" priority="${priorityLab}" ncrStatus="${ncrStatus}" />

