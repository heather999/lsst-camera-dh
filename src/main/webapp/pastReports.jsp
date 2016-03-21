<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="display" uri="http://displaytag.sf.net" %>
<%@taglib prefix="portal" uri="WEB-INF/tags/portal.tld" %>

<html>
    <head>
        <title>Previous Reports></title>
    </head>
    <body> 
     
        <c:set var="myRow" value="${param.row-1}"/>
        
        
        <c:choose>
            <c:when test="${param.on==1}">
                <h1>All SR-EOT-1 Reports for ${param.lsstnum}</h1>
                <c:set var="reportList" value="${h_reportsTable[myRow].onlineReportCol}" scope="page"/>
                
            </c:when>
            <c:otherwise>
                <h1>All SR-EOT-02 Reports for ${param.lsstnum}</h1>
                <c:set var="reportList" value="${h_reportsTable[myRow].offlineReportCol}" scope="page"/>
                
            </c:otherwise>
        </c:choose>
                        
       
        <display:table name="${reportList}" export="true" defaultsort="1" defaultorder="descending" class="datatable" id="onrep" >
            <display:column title="Date" sortable="true" >${onrep.creationDate}</display:column>
            <display:column title="SR-EOT-1 Test Report" sortable="true" >
                <c:choose>
                    <c:when test="${onrep.testReportPath == 'NA'}">
                        <c:out value="NA"/>
                    </c:when>
                    <c:otherwise>
                        <c:url var="onlineReportLink" value="http://srs.slac.stanford.edu/DataCatalog/">
                            <c:param name="dataset" value="${onrep.catalogKey}"/>
                            <c:param name="experiment" value="LSST-CAMERA"/>
                        </c:url>
                        <a href="${onlineReportLink}" target="_blank"><c:out value="${onrep.testReportPath}"/></a> 
                        <br>
                        <c:url var="onlineDirLink" value="http://srs.slac.stanford.edu/DataCatalog/">
                            <c:param name="folderPath" value="${onrep.testReportDirPath}"/>
                            <c:param name="experiment" value="LSST-CAMERA"/>
                        </c:url>
                        <a href="${onlineDirLink}" target="_blank"><c:out value="All Report Data"/></a>
                    </c:otherwise>
                </c:choose>
            </display:column>
        </display:table>





    </body>
</html>
