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
        <title>JSP Page</title>
    </head>
    <body>
        <h1>Basic  Datasets</h1>
        <c:set var="datasets" value="${portal:getDatasets(pageContext.request)}"/>
        <table>

            <tbody>
                <c:forEach var="dataset" items="${datasets}">
                    <%-- A dataset's metadata and it's locations are in a viewInfo object. 
                         We can set the var datasetLocations to the locations we found for convenience.
                    --%>
                    <c:set var="versionMetadata" value="${dataset.viewInfo.version.metadata}"/> 
                    <c:set var="datasetLocations" value="${dataset.viewInfo.locations}"/>
                    <c:forEach var="location" items="${datasetLocations}" varStatus="status">
                        <%-- We actually need to do a tiny bit of processing to find the master location --%>
                        <c:if test="${location.isMaster().booleanValue()}">
                            <c:set var="masterLocation" value="${location}" />
                        </c:if>
                    </c:forEach>
                    <tr>
                        <td>${dataset.name}</td>
                        <td>${dataset.path}</td>
                        <td>${masterLocation.site}</td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
        
        <h1>Mosaic Datasets</h1>
        <c:set var="datasets" value="${portal:getMosaicDatasets(pageContext.request)}"/>
        <table>

            <tbody>
                <c:forEach var="dataset" items="${datasets}">
                    <%-- A dataset's metadata and it's locations are in a viewInfo object. 
                         We can set the var datasetLocations to the locations we found for convenience.
                    --%>
                    <c:set var="searchMetadata" value="${dataset.metadata}"/> 
                    <c:set var="datasetLocations" value="${dataset.viewInfo.locations}"/>
                    <c:forEach var="location" items="${datasetLocations}" varStatus="status">
                        <%-- We actually need to do a tiny bit of processing to find the master location --%>
                        <c:if test="${location.isMaster().booleanValue()}">
                            <c:set var="masterLocation" value="${location}" />
                        </c:if>
                    </c:forEach>
                    <tr>
                        <td>${dataset.name}</td>
                        <td>${dataset.path}</td>
                        <td>${masterLocation.site}</td>
                        <td>${searchMetadata}</td> <%-- Note: This is a map! --%>
                        <td><img src="http://srs.slac.stanford.edu/DataCatalog/get?datasetLocation=${masterLocation.pk}"/></td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
        
        <h1>Amp Result Datasets</h1>
        <c:set var="datasets" value="${portal:getAmpResultDatasets(pageContext.request)}"/>
        <table>

            <tbody>
                <c:forEach var="dataset" items="${datasets}">
                    <%-- A dataset's metadata and it's locations are in a viewInfo object. 
                         We can set the var datasetLocations to the locations we found for convenience.
                    --%>
                    <c:set var="searchMetadata" value="${dataset.metadata}"/> 
                    <c:set var="datasetLocations" value="${dataset.viewInfo.locations}"/>
                    <c:forEach var="location" items="${datasetLocations}" varStatus="status">
                        <%-- We actually need to do a tiny bit of processing to find the master location --%>
                        <c:if test="${location.isMaster().booleanValue()}">
                            <c:set var="masterLocation" value="${location}" />
                        </c:if>
                    </c:forEach>
                    <tr>
                        <td>${dataset.name}</td>
                        <td>${dataset.path}</td>
                        <td>${masterLocation.site}</td>
                        <td>${searchMetadata}</td> <%-- Note: This is a map! --%>
                        <td><img src="http://srs.slac.stanford.edu/DataCatalog/get?datasetLocation=${masterLocation.pk}"/></td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </body>
</html>
