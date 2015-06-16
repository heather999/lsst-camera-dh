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
         <title>Output Files for <c:out value="${param.activityId}"/></title>
    </head>
    <body> 
        <h1>Output ${param.processName} Version ${param.processVersion}</h1>

             
                    <sql:query var="outQuery" scope="page">
                        SELECT creationTS, virtualPath, value FROM FilepathResultHarnessed 
                        WHERE FilepathResultHarnessed.activityId=?<sql:param value="${param.activityId}"/> ORDER BY creationTS
                    </sql:query>
                    <c:if test="${outQuery.rowCount>0}" >
                        <display:table name="${outQuery.rows}" export="true" class="datatable"/> 
                    </c:if>
 
        
             


    </body>
</html>
