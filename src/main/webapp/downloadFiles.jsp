<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="file" uri="http://portal.lsst.org/fileutils" %>


<%-- 
    Document   : downloadFiles
    Created on : Sep 17, 2016, 11:16:47 AM
    Author     : tonyj
--%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Download files</title>
    </head>
    <body>
        <sql:query var="files">
            select f.virtualPath,f.catalogKey,f.creationTS from FilepathResultHarnessed f WHERE f.id in (${fn:join(paramValues.datasetToDwnld, ",")})
        </sql:query>
        <file:zip fileName="run-${param.run}.zip" comment="${param.root}">
            <c:forEach var="file" items="${files.rows}">
                <c:url var="downloadURL" value="http://srs.slac.stanford.edu/DataCatalog/get">
                    <c:param name="dataset" value="${file.catalogKey}"/>
                </c:url>
                <file:entry name="run-${param.run}/${file:relativize(param.root,file.virtualPath)}" url="${downloadURL}" createDate="${file.creationTS}"/>
            </c:forEach>
        </file:zip>
    </body>
</html>
