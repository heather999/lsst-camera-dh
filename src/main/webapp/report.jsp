<%-- 
    Document   : datasetSearchExample
    Created on : Nov 13, 2015, 1:11:03 PM
    Author     : bvan
--%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="portal" uri="WEB-INF/tags/portal.tld" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Report Page</title>
    </head>
    <body>
        
        
        <h1>Photoresponse Non-uniformity</h1>
        <c:set var="datasets" value="${portal:getMosaicDatasets(pageContext.request)}"/>
        <table>
            <tbody>
                <c:forEach var="dataset" items="${datasets}">
                     <c:out value="DATASET=${dataset}"/>
                    <c:set var="searchMetadata" value="${dataset.metadata}"/> 
                    <c:set var="datasetLocations" value="${dataset.viewInfo.locations}"/>
                    <c:forEach var="location" items="${datasetLocations}" varStatus="status">
                        <c:if test="${location.isMaster().booleanValue()}">
                            <c:set var="masterLocation" value="${location}" />
                        </c:if>
                    </c:forEach>
                    <tr>
                        <td><img src="http://srs.slac.stanford.edu/DataCatalog/get?datasetLocation=${masterLocation.pk}" alt="mosaic"/></td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
        
        <h1>System Gain and Photon Transfer Curves</h1>
        <c:set var="datasets" value="${portal:getAmpResultDatasets(pageContext.request)}"/>
        <table>
            <tbody>
                <c:forEach var="dataset" items="${datasets}">
                    <c:out value="DATASET=${dataset}"/>
                    <c:set var="searchMetadata" value="${dataset.metadata}"/> 
                    <c:set var="datasetLocations" value="${dataset.viewInfo.locations}"/>
                    <c:forEach var="location" items="${datasetLocations}" varStatus="status">
                        <c:if test="${location.isMaster().booleanValue()}">
                            <c:set var="masterLocation" value="${location}" />
                        </c:if>
                    </c:forEach>
                    <tr>
                        <td><img src="http://srs.slac.stanford.edu/DataCatalog/get?datasetLocation=${masterLocation.pk}" alt="amp results"/></td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </body>
</html>
