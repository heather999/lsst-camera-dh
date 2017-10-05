<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>
<%@taglib prefix="filter" uri="http://srs.slac.stanford.edu/filter"%>
<%@taglib prefix="et" tagdir="/WEB-INF/tags/eTrav"%>



<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Sensor Acceptance Reports Available</title>
    </head>
    <body>
        <h1>Sensor Acceptance Reports Available</h1>

        <c:set var="ccdManuString" value="${portal:getHardwareTypesFromGroup(pageContext.session, 'Generic-CCD')}" scope="page" />
        <sql:query var="manuQ" scope="page">
            SELECT DISTINCT manufacturer FROM Hardware, HardwareType where Hardware.hardwareTypeId=HardwareType.id AND HardwareType.id IN ${ccdManuString} ORDER BY manufacturer;
        </sql:query>

        <sql:query var="labelGQ" scope="page">
            select DISTINCT L.name, L.id FROM Label L
            INNER JOIN LabelHistory LH on L.id=LH.labelId
            INNER JOIN LabelGroup LG on LG.id=L.labelGroupId
            INNER JOIN Labelable LL on LL.id=LG.labelableId
            WHERE LL.name="hardware" AND LG.name="SR_Grade";
        </sql:query>

        <sql:query var="labelCQ" scope="page">
            select DISTINCT L.name, L.id FROM Label L
            INNER JOIN LabelHistory LH on L.id=LH.labelId
            INNER JOIN LabelGroup LG on LG.id=L.labelGroupId
            INNER JOIN Labelable LL on LL.id=LG.labelableId
            WHERE LL.name="hardware" AND LG.name="SR_Contract";
        </sql:query>

        <filter:filterTable>
            <filter:filterInput var="lsst_num" title="LSST_NUM (substring search)"/>
            <filter:filterSelection title="Manufacturer" var="manu" defaultValue="any">
                <filter:filterOption value="any">Any</filter:filterOption>
                <c:forEach var="hdw" items="${manuQ.rows}">
                    <filter:filterOption value="${hdw.manufacturer}"><c:out value="${hdw.manufacturer}"/></filter:filterOption>
                </c:forEach>
            </filter:filterSelection>
            <filter:filterSelection title="Grade" var="grade" defaultValue="0">
                <filter:filterOption value="0">Any</filter:filterOption>
                <c:forEach var="g" items="${labelGQ.rows}">
                    <filter:filterOption value="${g.id}"><c:out value="${g.name}"/></filter:filterOption>
                </c:forEach> 
            </filter:filterSelection>
            <filter:filterSelection title="Contract" var="contract" defaultValue="0">
                <filter:filterOption value="0">Any</filter:filterOption>
                <c:forEach var="c" items="${labelCQ.rows}">
                    <filter:filterOption value="${c.id}"><c:out value="${c.name}"/></filter:filterOption>
                </c:forEach> 
            </filter:filterSelection>
            <filter:filterSelection title="PreshipAuthorized" var="authorized" defaultValue="0">
                <filter:filterOption value="0">Any</filter:filterOption>
                <filter:filterOption value="1">Authorized</filter:filterOption>
                <filter:filterOption value="2">Not Authorized</filter:filterOption>
            </filter:filterSelection>
            <filter:filterSelection title="Accepted" var="accept" defaultValue="0">
                <filter:filterOption value="0">Any</filter:filterOption>
                <filter:filterOption value="1">Accepted</filter:filterOption>
                <filter:filterOption value="2">Not Accepted</filter:filterOption>
            </filter:filterSelection>
            <filter:filterSelection title="NCRs" var="ncr" defaultValue="0">
                <filter:filterOption value="0">Any</filter:filterOption>
                <filter:filterOption value="1">No NCRs</filter:filterOption>
                <filter:filterOption value="2">Has NCRs</filter:filterOption>
            </filter:filterSelection>
        </filter:filterTable>


        <c:set var="sensorsWithAcceptance" value="${portal:getSensorAcceptanceTable(pageContext.session, lsst_num, manu, authorized, accept, ncr, appVariables.dataSourceMode, grade, contract)}"/>

        <display:table name="${sensorsWithAcceptance}" export="true" class="datatable" id="sen" defaultsort="1" >
            <display:column title="Sensor" sortProperty="lsstId" sortable="true" class="sortable" >
                <c:url var="acceptanceLink" value="SensorAcceptanceReport.jsp">
                    <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
                    <c:param name="lsstId" value="${sen.lsstId}"/>
                    <c:param name="eotestVer" value="${sen.vendorEoTestVer}"/>
                    <c:param name="ts3eotestVer" value="${sen.ts3EoTestVer}"/>
                </c:url>
                <a href="${acceptanceLink}" target="_blank"><c:out value="${sen.lsstId}"/></a>
            </display:column>
            <display:column title="Grade" sortable="true">${sen.grade}</display:column>
            <display:column title="Contract" sortable="true">${sen.contract}</display:column>
            <display:column title="RTM" sortable="true">
            <et:hdwLink lsstNum="${sen.rtm}" var="mylink"/>
            <a href="${mylink}" target="_blank"><c:out value="${sen.rtm}"/></a>
            </display:column>
            <display:column title="Ingest" sortable="true" >${sen.vendorIngestDate}</display:column>
            <display:column title="Vendor-LSST<br/>eotest Ver" sortable="true" >${sen.sreot2Date}<br>${sen.vendorEoTestVer}</display:column>
            <display:column title="LSST-LSST<br/>eotest Ver" sortable="true" >${sen.ts3EoTestVer}</display:column>
            <display:column title="Vendor-LSST MET" sortable="true" >${sen.met05Date}</display:column>
            <display:column title="Authorized" sortable="true" >
                <c:choose>
                    <c:when test="${empty sen.preshipApproved}">  <%-- if preshipApproval flag is unavailable --%>
                        <c:choose>
                            <c:when test="${empty sen.preshipApprovedStatus}">
                                NA
                            </c:when>
                            <c:otherwise>
                                ${sen.preshipApprovedStatus}
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:otherwise> <%-- check preship Approval --%>
                        <c:choose>
                            <c:when test="${sen.preshipApproved == true}">
                                <font color="green">
                                ${sen.preshipApprovedDate}
                                </font>
                            </c:when>
                            <c:otherwise>
                                <font color="red">
                                REJECTED
                                <br>
                                ${sen.preshipApprovedDate}
                                </font>
                            </c:otherwise>
                        </c:choose>
                    </c:otherwise>
                </c:choose>
                <%--${empty sen.preshipApproved ? ( empty sen.preshipApprovedStatus ? 'NA' : sen.preshipApprovedStatus) : sen.preshipApproved ? sen.preshipApprovedDate : '<font color="red">&#x2718;<span>'}--%>

            </display:column>

            <display:column title="Received at BNL" sortable="true" > ${sen.bnlSensorReceipt}
                <c:if test="${!empty sen.bnlSensorReceiptStatus}">
                    <c:if test="${!empty sen.bnlSensorReceipt}">
                        <br>
                    </c:if>
                    ${sen.bnlSensorReceiptStatus}
                </c:if>
            </display:column>
            <display:column title="Accepted" sortable="true" >
                <c:choose>
                    <c:when test="${empty sen.sensorAccepted}">  <%-- if sensorAccepted flag is unavailable --%>
                        NA
                        <%--
                        <c:choose>
                            <c:when test="${empty sen.sensorAcceptedStatus}">
                                NA
                            </c:when>
                            <c:otherwise>
                                ${sen.sensorAcceptedStatus}
                            </c:otherwise>
                        </c:choose>
                        --%>
                    </c:when>
                    <c:otherwise> <%-- check sensor Acceptance --%>
                        <c:choose>
                            <c:when test="${sen.sensorAccepted == true}">
                                <font color="green">
                                ${sen.sensorAcceptedDate}
                                </font>
                            </c:when>
                            <c:otherwise>
                                <font color="red">
                                Returned to Vendor
                                <br>
                                ${sen.sensorAcceptedDate}
                                </font>
                            </c:otherwise>
                        </c:choose>
                    </c:otherwise>
                </c:choose>
            </display:column>
            <display:column title="Any NCRs?" >
                <c:choose>
                    <c:when test="${sen.anyNcrs == true}">
                        <c:url var="ncrLink" value="ncrStatus.jsp">
                            <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
                            <c:param name="lsstId" value="${sen.lsstId}"/>
                            <c:param name="Status" value="0"/>
                            <c:param name="submit" value="Filter"/>
                        </c:url>                
                        <a href="${ncrLink}" target="_blank"><c:out value="NCRs"/></a>
                    </c:when>
                    <c:otherwise>
                        <font color="green">
                        <b>No</b>
                        </font>
                    </c:otherwise>
                </c:choose>
            </display:column>
            <display:setProperty name="export.excel.filename" value="sensorAcceptance.xls"/> 
            <display:setProperty name="export.csv.filename" value="sensorAcceptance.csv"/> 
            <display:setProperty name="export.xml.filename" value="sensorAcceptance.xml"/> 
        </display:table>

        <%--
    ${empty sen.preshipApproved ? ( empty sen.preshipApprovedStatus ? 'NA' : sen.preshipApprovedStatus) : sen.preshipApproved ? '<font color="green">&#x2714;</span>' : '<font color="red">&#x2718;<span>'}
        --%>
    </body>
</html

