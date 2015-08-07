<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="portal" uri="WEB-INF/tags/portal.tld" %>
<%@taglib prefix="etraveler" tagdir="/WEB-INF/tags/eTrav"%>

<html>
    <head>
        <title>Results</title>
         <style type="text/css">
table.datatable th, table.datatable td {
	text-align: left;
}
            </style>
    </head>
    <body> 
        <h1>Results</h1>


        <c:set var="hdwId" value="${param.hdwId}" scope="page"/> 

        <c:set var="travelerList" value="${portal:getTravelerCol(pageContext.session,hdwId,true)}" scope="page"/>


        <c:forEach var="curTraveler" items="${travelerList}"> 
            

            <c:set var="actList" value="${portal:getActivitiesForTraveler(pageContext.session,curTraveler.actId,hdwId)}"/> 

            <%--
            <c:set var="actListStr" value="${portal:getActString(pageContext.session, curTraveler.actId, hdwId)}" />
            <h4>String "${actListStr}" </h4>
            --%>

            <c:set var="firstTime" value="true"/>
            <c:set var="actListWithOutput" value="${portal:getActivityListWithOutput(pageContext.session,actList)}"/>
            <c:forEach var="curAct" items="${actListWithOutput}" varStatus="status">
                <%--<c:set var="actId" value="${curAct}"/> --%>
<%--                <c:set var="hasOutput" value="${portal:doesActivityHaveOutput(pageContext.session,actId)}"/> --%>

                 
                    <c:if test="${firstTime==true}">
                    <h3>${curTraveler.name} activityId: ${curTraveler.actId}</h3><br>
                    <c:set var="firstTime" value="false"/>
                    </c:if>
                <sql:query var="moreProcessInfo" scope="page">
                    SELECT A.id, concat(P.name,'') as process, A.processId, A.iteration,
                    P.version AS version
                    FROM Process P, Activity A  
                    WHERE P.id=A.processId AND A.id=${curAct}
                </sql:query>
                <c:set var="processInfo" value="${moreProcessInfo.rows[0]}"/>    
                 <c:url var="resultsLink" value="procResults.jsp">
                    <c:param name="activityId" value="${curAct}"/>
                    <c:param name="process" value="${processInfo.process}"/>
                    <c:param name="version" value="${processInfo.version}"/>
                    <c:param name="travName" value="${curTraveler.name}"/>
                </c:url>
                <h4><a target="_blank" href="${resultsLink}">Link to ${processInfo.process} version ${processInfo.version} iteration ${processInfo.iteration} activityId: ${curAct}</a></h4>
                
        </c:forEach> <%-- End Activity Loop --%>

       
    </c:forEach>  <%-- End Traveler Loop --%>


</body>
</html>
