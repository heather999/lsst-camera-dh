<%-- 
    Document   : jobLink
    Created on : May 2, 2016, 4:27:59 PM
    Author     : tonyj
--%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%@tag description="Create links to job ids" pageEncoding="UTF-8"%>

<%-- The list of normal or fragment attributes can be specified here: --%>
<%@attribute name="id" type="java.lang.String" required="true"%>

<c:set var="isNumber" value="${id.matches('[0-9]+')}"/>
<c:if test="${isNumber}">
    <c:url var="url" value="/displayActivity.jsp" context="//lsst-camera.slac.stanford.edu/eTraveler">
        <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
        <c:param name="activityId" value="${id}"/>
    </c:url>
    <a href="${url}">
</c:if> 
${id}
<c:if test="${isNumber}">
    </a>
</c:if> 
