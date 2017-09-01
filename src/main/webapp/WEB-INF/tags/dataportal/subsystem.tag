<%@tag description="Display Subsystem Overview" pageEncoding="UTF-8"%>

<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="display" uri="http://displaytag.sf.net" %>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>
<%@taglib prefix="srs_utils" uri="http://srs.slac.stanford.edu/utils" %>
<%@taglib prefix="filter" uri="http://srs.slac.stanford.edu/filter"%>


<%@attribute name="sub" required="true"%>
<%@attribute name="subname" required="true"%>
<%@attribute name="explorer" required="true"%>
<%@attribute name="bygroup" required="false"%>
<%@attribute name="title" required="true"%>

<h1>${title}</h1>

<c:choose>
    <c:when test = "${empty bygroup}">    
        <c:set var="hdwTypeString" value="${portal:getHardwareTypesFromSubsystem(pageContext.session,sub)}" scope="page"/>
        <c:set var="bygroupFlag" value="false" scope="page"/>
    </c:when>
    <c:otherwise>
        <c:set var="hdwTypeString" value="${portal:getHardwareTypesFromGroup(pageContext.session,sub)}" scope="page"/>
        <c:set var="bygroupFlag" value="true" scope="page"/>
    </c:otherwise>
</c:choose>

<c:if test="${! empty hdwTypeString}">
    <sql:query var="manufacturerQ" scope="page">
        SELECT DISTINCT manufacturer FROM Hardware, HardwareType where Hardware.hardwareTypeId=HardwareType.id AND HardwareType.id IN ${hdwTypeString} ORDER BY manufacturer;
    </sql:query>

     
    <sql:query var="labelQ" scope="page">
    select DISTINCT L.name, L.id, LG.name AS groupName FROM Label L
    INNER JOIN LabelHistory LH on L.id=LH.labelId
    INNER JOIN LabelGroup LG on LG.id=L.labelGroupId
    INNER JOIN Labelable LL on LL.id=LG.labelableId
    INNER JOIN Subsystem S on S.id=LG.subsystemId
    WHERE S.shortName = "${subname}" AND LL.name="hardware"
    ORDER BY LG.name;
    </sql:query>
    
    <filter:filterTable>
        <filter:filterInput var="lsst_num" title="LSST_NUM (substring search)"/>
        <filter:filterSelection title="Manufacturer" var="manu" defaultValue="any">
            <filter:filterOption value="any">Any</filter:filterOption>
                <c:forEach var="hdw" items="${manufacturerQ.rows}">
                <filter:filterOption value="${hdw.manufacturer}"><c:out value="${hdw.manufacturer}"/></filter:filterOption>
                </c:forEach>
        </filter:filterSelection>
            
        <filter:filterSelection title="Labels" var="labelsChosen" defaultValue="0">
            <filter:filterOption value="0">Any</filter:filterOption>
            <c:forEach var="label" items="${labelQ.rows}">
                <filter:filterOption value="${label.id}"><c:out value="${label.groupName}:${label.name}"/></filter:filterOption>
                </c:forEach> 
        </filter:filterSelection>
            
    </filter:filterTable>


    <c:set var="hdwStatLocTable" value="${portal:getHdwStatLocTable(pageContext.session,ccdHdwTypeId, lsst_num, manu, sub, bygroupFlag, labelsChosen)}"/>

    <%--
    <c:forEach var='parameter' items='${paramValues}'> 
        <c:out value='${parameter.key}'/>
        <c:forEach var='value' items='${parameter.value}'>
            <c:out value='${value}'/>   
        </c:forEach>
    </c:forEach>
--%>

<%-- embed CSS style for lable list below --%>
<style type="text/css">
  ul {
    list-style-type: none;
    padding: 0;
    margin: 0;
  }
  </style>
  
    <%-- defaultsort index starts from 1 --%>
    <display:table name="${hdwStatLocTable}" export="true" defaultsort="9" defaultorder="descending" class="datatable" id="hdl" >
        <%-- <display:column title="LsstId" sortable="true" >${hdl.lsstId}</display:column> --%>
        <display:column title="LSST_NUM" sortable="true">
            <c:url var="explorerLink" value="${explorer}">
                <c:param name="lsstIdValue" value="${hdl.lsstId}"/>
            </c:url>                
            <a href="${explorerLink}"><c:out value="${hdl.lsstId}"/></a>
        </display:column>
        <display:column title="Date Registered" sortable="true" >${hdl.creationDate}</display:column>
        <display:column title="Overall Component Status" sortable="true" >${hdl.status}</display:column>
        <display:column title="Site" sortable="true" >${hdl.site}</display:column>
        <display:column title="Location" sortable="true" >${hdl.location}</display:column>
        <display:column title="Current Run/Traveler" sortable="true" >${hdl.curTravelerName}</display:column>
        <display:column title="Current Process Step" sortable="true" >${hdl.curActivityProcName}</display:column>
        <display:column title="Current Process Step Status" sortable="true" >${hdl.curActivityStatus}</display:column>
        <display:column title="Most Recent Timestamp" sortable="true" >${hdl.curActivityLastTime}</display:column>
        <display:column title="NCR" sortable="true" >${hdl.inNCR}</display:column>
        <display:column title="Labels" sortable="true" >
            <ul>
                <c:forEach var="l" items="${hdl.labelMap}">
                    <li>${l.value}</li>
                    </c:forEach>
            </ul>
        </display:column>
        <display:setProperty name="export.excel.filename" value="sensorStatus.xls"/> 
        <display:setProperty name="export.csv.filename" value="sensorStatus.csv"/> 
        <display:setProperty name="export.xml.filename" value="sensorStatus.xml"/> 
    </display:table>

</c:if>  