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
    </head>
    <body> 
        <h1>Results</h1>


        <c:set var="hdwId" value="${param.hdwId}" scope="page"/> 

        <c:set var="travelerList" value="${portal:getTravelerCol(pageContext.session,hdwId)}" scope="page"/>


        <c:forEach var="curTraveler" items="${travelerList}"> 
            <h3>${curTraveler.name} activityId: ${curTraveler.actId}</h3><br>

            <c:set var="actList" value="${portal:getActivitiesForTraveler(pageContext.session,curTraveler.actId,hdwId)}"/> 

            <%--
            <c:set var="actListStr" value="${portal:getActString(pageContext.session, curTraveler.actId, hdwId)}" />
            <h4>String "${actListStr}" </h4>
            --%>

            <c:forEach var="curAct" items="${actList}" varStatus="status">
                <sql:query var="moreProcessInfo" scope="page">
                    SELECT A.id, concat(P.name,'') as process, A.processId, A.inNCR, A.iteration,
                    P.version AS version,A.begin,A.end
                    FROM Process P, Activity A  
                    WHERE P.id=A.processId AND A.id=${curAct}
                </sql:query>
                <c:set var="processInfo" value="${moreProcessInfo.rows[0]}"/>    
            <etraveler:jhResultWidget activityId="${curAct}" processName="${processInfo.process}" version="${processInfo.version}"/>
            <sql:query var="outQ" scope="page">
                SELECT name, value, catalogKey, schemaName, schemaVersion, schemaInstance, virtualPath FROM FilepathResultHarnessed 
                WHERE FilepathResultHarnessed.activityId=?<sql:param value="${curAct}"/>
            </sql:query>
            <c:if test="${outQ.rowCount>0}" >
                <c:url var="processLink" value="outputFiles.jsp">
                    <c:param name="activityId" value="${curAct}"/>
                    <c:param name="travName" value="${curTraveler.name}"/>
                    <c:param name="processName" value="${processInfo.process}"/>
                    <c:param name="processVersion" value="${processInfo.version}"/>
                </c:url>
                <h4><a target="_blank" href="${processLink}" >Link to ${processInfo.process} version ${processInfo.version} iteration ${processInfo.iteration} Output Files</a></h4>
            </c:if>
        </c:forEach> <%-- End Activity Loop --%>

        <br>
    </c:forEach>  <%-- End Traveler Loop --%>




</body>
</html>
