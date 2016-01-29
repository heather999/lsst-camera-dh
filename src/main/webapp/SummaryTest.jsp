<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="portal" uri="WEB-INF/tags/portal.tld" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="display" uri="http://displaytag.sf.net" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- 
    Document   : SummaryTest
    Created on : Jan 13, 2016, 1:19:08 PM
    Author     : chee
--%>

 
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Summary of Tests</title>
    </head>
    <body>
        <h1>Summary Of Tests (page under construction)</h1>
 
        <%-- get a list of all the sensors to display to user --%>
        <sql:query var="sensor" dataSource="jdbc/rd-lsst-cam-dev-ro">
            select act.id, act.parentActivityId, hw.lsstId, statusHist.activityStatusId from Activity act join Hardware hw on act.hardwareId=hw.id 
            join Process pr on act.processId=pr.id join ActivityStatusHistory statusHist on act.id=statusHist.activityId 
            where pr.name='test_report_offline' order by act.parentActivityId desc   
        </sql:query>

    <p><c:out value="sensor count ${sensor.rowCount}"/></p>
    
    <c:choose>
        <c:when test="${empty param}">
            The list contains the activity Id, the schema name, the parent activity Id and the activity status id, in that order.<br/>
            Select one (for test reports only):
            <form name="sensorform" id="sensorform" action="SummaryTest.jsp?rectype=NEWSENSOR" method="get" >
                <table>
                    <thead>
                    <td>
                    <tr>
                        <td><select name="schemaInfo" id="schemaInfo" size="25">
                            <c:forEach var="arow" items="${sensor.rows}">
                                <c:set var="sensorString" value="${arow.id} ${arow.parentActivityId} ${arow.lsstId} ${arow.activityStatusId}"/>
                                <option value="${sensorString}">${arow.id} ${arow.lsstId} ${arow.parentActivityId} ${arow.activityStatusId}</option>
                            </c:forEach>
                            </select>
                        </td>
                    </tr>
                    <tr><td><input type="submit" value="submit" name="submit"/></td><td><input type="reset" value="reset" name="reset"/></td></tr>
                    </td>
                    </thead>
                </table>
            </form>
        </c:when>
        <c:when test="${! empty param}">
            <c:set var="string" value="${fn:split(param.schemaInfo,' ')}"/>
            <c:set var="actid" value="${string[0]}"/> 
            <c:set var="parentActivityId" value="${string[1]}"/>
            <c:set var="schema" value="${string[2]}"/>
            <c:set var="actHistStatus" value="${string[3]}"/>
            <p>You selected: <br/>activity Id ${actid}<br/> parentActivityId ${parentActivityId}<br/> schema ${schema} <br/> status ${actHistStatus}</p>
          
            <%-- which jobs were used for this parentActivityId --%>
            <sql:query var="processes" dataSource ="jdbc/rd-lsst-cam-dev-ro">
                select act.id, act.parentActivityId, pr.name from Activity act join Process pr on
                act.processId = pr.id where act.parentActivityId = ?
                <sql:param value="${parentActivityId}"/>
            </sql:query>
             
            <table class="datatable" border="1">
                <tbody>
                    <tr><th>SchemaName</th>
                        <th>Name</th>
                        <th>spec. ID</th>
                        <th>Description</th>
                        <th>Specification</th>
                        <th>Measurement</th>
                        <th>Datatable Queried</th>
                    </tr>
                    
               <c:forEach var="pr" items="${processes.rows}">
                    <c:if test="${fn:contains(pr,'_offline')}">
                      <c:set var="prname" value="${fn:replace(pr.name,'_offline','')}"/>
                    </c:if>
                    <%-- find the testnames to get the name(s)  --%>
                    <sql:query var="processlist" dataSource="jdbc/config-prod">
                        select namelist, ntype, specid from summary_md where testname like ?
                        <sql:param value="${prname}%"/>
                    </sql:query>
                     
                    <%-- build string of names associated with schemaName selected to pass to tag --%>
                        <c:set var="listOfnames" value=""/>
                        <c:forEach var="x" items="${processlist.rows}" varStatus = "loop">
                            <c:set var="specInfo" value="${x.specid}"/>
                          <%--  <c:out value="SpecID=${!empty specInfo ? specInfo : 'no specid' }"/><br/> --%>
                           
                            <c:if test="${loop.index == 0}">
                                <c:set var="listOfnames" value="${x.namelist}"/>
                                <c:if test="${!empty x.ntype}">
                                    <c:set var="ntype" value="${x.ntype}"/>
                                </c:if>
                            </c:if>
                            <c:if test="${loop.index > 0}">
                                <c:set var="listOfnames" value="${listOfnames}, ${x.namelist}"/>
                            </c:if>
                        </c:forEach>
                       
                        <c:if test="${fn:length(listOfnames) > 0}">
                            <c:choose>
                                <c:when test="${ntype=='f' || ntype == 'b'}">
                                   
                                     <sql:query var="lcaInfo" dataSource="jdbc/config-prod">
                                       select description, specification, scope from lca128 where specid = ?
                                     <sql:param value="${specInfo}"/>
                                     </sql:query>
                                   
                                     <c:set var="dbtable" value="FloatResultHarnessed"/>
                                     <%-- results returned as a list so loop over it to get the actual values --%>
                                     <c:set var="resultsFloat" value="${portal:getSummaryResults(pageContext.session, prname, parentActivityId, dbtable, fn:split(listOfnames, ','))}"/>  
                                     <c:forEach var="f" items="${resultsFloat}">
                                        <tr>
                                            <td>${prname}</td>
                                            <td>${f.tmpname}</td>
                                            <td>${!empty specInfo ? specInfo : 'unknown'}</td>
                                            <td>${lcaInfo.rows[0].description}</td>
                                            <td>${lcaInfo.rows[0].specification}</td>
                                            <td>${f.min} - ${f.max}</td>
                                            <td>${dbtable}</td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:when test="${ntype =='i' || ntype == 'b'}">
                                     <sql:query var="lcaInfo" dataSource="jdbc/config-prod">
                                       select description, specification, scope from lca128 where specid = ?
                                     <sql:param value="${specInfo}"/>
                                     </sql:query>
                                    <c:set var="dbtable" value="IntResultHarnessed"/>
                                    <c:set var="resultsInt" value="${portal:getSummaryResults(pageContext.session, prname, parentActivityId, dbtable, fn:split(listOfnames, ','))}"/>  
                                    <c:forEach var="i" items="${resultsInt}">
                                        <tr>
                                            <td>${prname}</td>
                                            <td>${i.tmpname}</td>
                                            <td>${!empty specInfo ? specInfo : 'unknown'}</td>
                                            <td>${lcaInfo.rows[0].description}</td>
                                            <td>${lcaInfo.rows[0].specification}</td>
                                            <td>${i.min} - ${i.max}</td>
                                            <td>${dbtable}</td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                            </c:choose>
                        </c:if>
                    </c:forEach>
                     
                </tbody>
            </table>
        </c:when>
    </c:choose>
    </body>
</html>
