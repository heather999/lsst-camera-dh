<%-- 
    Document   : Sensor Acceptance Table
    Created on : Apr 20, 2016, 3:04:03 PM
    Author     : heather
--%>
<%@tag description="Sensor Acceptance Table" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>
<%@taglib prefix="display" uri="http://displaytag.sf.net"%>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>
<%@taglib prefix="ru" tagdir="/WEB-INF/tags/reports"%>

<%-- The list of normal or fragment attributes can be specified here: --%>
<%@attribute name="sectionNum" type="java.lang.String" required="true"%>
<%@attribute name="data" type="java.util.Map" required="true"%>
<%@attribute name="reportId" type="java.lang.Integer" required="true"%>
<%@attribute name="dataTS3" type="java.util.Map" required="false"%>
<%@attribute name="dataVend" type="java.util.Map" required="false"%>



<sql:query var="specs" dataSource="${appVariables.reportDisplayDb}">
    select specid, description, spec_display, jexl_status, jexl_measurement, jexl_jobid from report_specs where report=?
    <sql:param value="${reportId}"/>
    <c:if test="${sectionNum != '1'}">
        and section=? <sql:param value="${sectionNum}"/>
    </c:if>
    <c:if test="${sectionNum == '1'}">
        and in_summary = 'Y' 
    </c:if>
</sql:query>

<div id="SensorAcceptance" class="print">
    <c:if test="${specs.rowCount != 0}">
        <display:table name="${specs.rows}" id="row" defaultsort="1" class="datatable">

            <display:column property="SpecId" title="Spec. ID"/>
            <display:column property="Description"/>
            <display:column property="Spec_Display" title="Specification"/>
            <display:column title="Vendor-Vendor">
                <c:choose>
                    <c:when test="${empty dataVend}">
                        NA
                    </c:when>
                    <c:otherwise>
                        <c:catch var="x">
                            ${portal:jexlEvaluateData(dataVend, row.jexl_measurement)}     
                        </c:catch>
                        <c:if test="${!empty x}">???</c:if>
                    </c:otherwise>
                </c:choose>
            </display:column>
            <display:column title="Status">
                <c:choose>
                    <c:when test="${empty dataVend}">
                        NA
                    </c:when>
                    <c:otherwise>
                        <c:catch var="x">
                            <c:set var="status" value="${portal:jexlEvaluateData(dataVend, row.jexl_status)}"/>
                            ${empty status ? "..." : status ? '<font color="green">&#x2714;</span>' : '<font color="red">&#x2718;<span>'}
                        </c:catch>
                        <c:if test="${!empty x}">???</c:if>
                    </c:otherwise>
                </c:choose>
            </display:column>
                        <%--
            <display:column title="Job Id">
                <c:choose>
                    <c:when test="${empty dataVend}">
                        NA
                    </c:when>
                    <c:otherwise>
                        <c:catch var="x">
                            <ru:jobLink id="${portal:jexlEvaluateData(dataVend, row.jexl_jobid)}"/> 
                        </c:catch>
                        <c:if test="${!empty x}">???</c:if>
                    </c:otherwise>
                </c:choose>
            </display:column>
                        --%>
            <display:column title="Vendor-LSST">
                <c:catch var="x">
                    ${portal:jexlEvaluateData(data, row.jexl_measurement)} 
                </c:catch>
                <c:if test="${!empty x}">???</c:if>
            </display:column>
            <display:column title="Status">
                <c:catch var="x">
                    <c:set var="status" value="${portal:jexlEvaluateData(data, row.jexl_status)}"/>
                    ${empty status ? "..." : status ? '<font color="green">&#x2714;</span>' : '<font color="red">&#x2718;<span>'}
                </c:catch>
                <c:if test="${!empty x}">???</c:if>
            </display:column>
                <%--
            <display:column title="Job Id">
                <c:catch var="x">
                    <ru:jobLink id="${portal:jexlEvaluateData(data, row.jexl_jobid)}"/> 
                </c:catch>
                <c:if test="${!empty x}">???</c:if>
            </display:column>
                --%>
            <display:column title="LSST-LSST">
                <c:choose>
                    <c:when test="${empty dataTS3}">
                        NA
                    </c:when>
                    <c:otherwise>
                        <c:catch var="x">
                            ${portal:jexlEvaluateData(dataTS3, row.jexl_measurement)}     
                        </c:catch>
                        <c:if test="${!empty x}">???</c:if>
                    </c:otherwise>
                </c:choose>
            </display:column>
            <display:column title="Status">
                <c:choose>
                    <c:when test="${empty dataTS3}">
                        NA
                    </c:when>
                    <c:otherwise>
                        <c:catch var="x">
                            <c:set var="status" value="${portal:jexlEvaluateData(dataTS3, row.jexl_status)}"/>
                            ${empty status ? "..." : status ? '<font color="green">&#x2714;</span>' : '<font color="red">&#x2718;<span>'}
                        </c:catch>
                        <c:if test="${!empty x}">???</c:if>
                    </c:otherwise>
                </c:choose>
            </display:column>
                        <%--
            <display:column title="Job Id">
                <c:choose>
                    <c:when test="${empty dataTS3}">
                        NA
                    </c:when>
                    <c:otherwise>
                        <c:catch var="x">
                            <ru:jobLink id="${portal:jexlEvaluateData(dataTS3, row.jexl_jobid)}"/> 
                        </c:catch>
                        <c:if test="${!empty x}">???</c:if>
                    </c:otherwise>
                </c:choose>
            </display:column>
                        --%>
        </display:table>
    </c:if>
                                                
                        
</div>
