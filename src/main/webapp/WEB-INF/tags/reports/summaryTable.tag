<%-- 
    Document   : Summary Table
    Created on : Apr 20, 2016, 3:04:03 PM
    Author     : chee
--%>
<%@tag description="Summary Table" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>
<%@taglib prefix="display" uri="http://displaytag.sf.net"%>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>
<%@taglib prefix="ru" tagdir="/WEB-INF/tags/reports"%>

<%-- The list of normal or fragment attributes can be specified here: --%>
<%@attribute name="sectionNum" type="java.lang.String" required="true"%>
<%@attribute name="data" type="java.util.Map" required="true"%>

<sql:query var="specs" dataSource="jdbc/config-prod">
    select specid, description, spec_display, jexl_status, jexl_measurement, jexl_jobid from report_specs
    <c:if test="${sectionNum != '1'}">
        where section=? <sql:param value="${sectionNum}"/>
    </c:if>
</sql:query>

<c:if test="${specs.rowCount != 0}">
    <display:table name="${specs.rows}" id="row" defaultsort="2" class="datatable">
        <display:column title="Status">
            <c:catch var="x">
                <c:set var="status" value="${portal:jexlEvaluateData(data, row.jexl_status)}"/>
                ${empty status ? "..." : status ? '<font color="green">&#x2714;</span>' : '<font color="red">&#x2718;<span>'}
            </c:catch>
            <c:if test="${!empty x}">???</c:if>
        </display:column>
        <display:column property="SpecId" title="Spec. ID"/>
        <display:column property="Description"/>
        <display:column property="Spec_Display" title="Specification"/>
        <display:column title="Value">
            <c:catch var="x">
                ${portal:jexlEvaluateData(data, row.jexl_measurement)} 
            </c:catch>
            <c:if test="${!empty x}">???</c:if>
        </display:column>
        <display:column title="Job Id">
            <c:catch var="x">
                <ru:jobLink id="${portal:jexlEvaluateData(data, row.jexl_jobid)}"/> 
            </c:catch>
            <c:if test="${!empty x}">???</c:if>
        </display:column>
    </display:table>
</c:if>
