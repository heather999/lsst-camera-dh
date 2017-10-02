<%-- 
    Document   : url
    Created on : Jan 8, 2017, 11:43:13 AM
    Author     : tonyj
--%>

<%@tag description="Analogous to <c:url> but includes dataSourceMode parameter automatically" pageEncoding="UTF-8"%>

<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@attribute name="var" rtexprvalue="false" required="true"%>
<%@attribute name="value" required="true" rtexprvalue="true"%>
<%@attribute fragment="true" name="body"%>
<%@variable alias="result" name-from-attribute="var" scope="AT_END"%>

<c:url var="result" value="${value}">
    <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
    <jsp:invoke fragment="body"/>
</c:url>
