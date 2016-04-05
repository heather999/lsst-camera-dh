<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="portal" uri="WEB-INF/tags/portal.tld" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="display" uri="http://displaytag.sf.net" %>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>
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
 
        <c:set var="debugMode" value="false"/>
        
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
                
                <th>Status</th><th>Spec. ID</th><th>Description</th><th>Specification</th><th>Measurement</th><th>Datatable Used</th>
                    
               <c:forEach var="pr" items="${processes.rows}">
                    <c:if test="${fn:contains(pr,'_offline')}">
                      <c:set var="prname" value="${fn:replace(pr.name,'_offline','')}"/>
                    </c:if>
                    <%-- find the schemaNames to get the name(s)  --%>
                    <sql:query var="processlist" dataSource="jdbc/config-prod">
                        select namelist, floatresult, intresult, strresult, specid, description from summary_md where schemaname like ? and namelist is not null
                        <sql:param value="${prname}%"/>
                    </sql:query>
                    
                    <%-- build string of names associated with schemaName selected to pass to tag --%>
                        <c:set var="listOfnames" value=""/>
                        <c:set var="tablesUsed" value=""/>
                        <c:forEach var="x" items="${processlist.rows}" varStatus = "loop">
                                <c:if test="${x.floatresult == 'Y'}">
                                    <c:if test="${empty tablesUsed}">
                                        <c:set var="tablesUsed" value="FloatResultHarnessed"/>
                                    </c:if>
                                    <c:if test="${!fn:contains(tablesUsed,'FloatResultHarnessed')}">
                                       <c:set var="tablesUsed" value="${tablesUsed},FloatResultHarnessed"/>
                                    </c:if>
                                </c:if>
                                <c:if test="${x.intresult == 'Y'}">
                                    <c:if test="${empty tablesUsed}">
                                        <c:set var="tablesUsed" value="IntResultHarnessed"/>
                                    </c:if>
                                    <c:if test="${!fn:contains(tablesUsed,'IntResultHarnessed')}">
                                       <c:set var="tablesUsed" value="${tablesUsed},IntResultHarnessed"/>
                                    </c:if>
                                </c:if>
                                <c:if test="${strresult == 'Y'}">
                                    <c:if test="${empty tablesUsed}">
                                        <c:set var="tablesUsed" value="StringResultHarnessed"/>
                                    </c:if>
                                    <c:if test="${!fn:contains(tablesUsed,'StringResultHarnessed')}">
                                       <c:set var="tablesUsed" value="${tablesUsed},StringResultHarnessed"/>
                                    </c:if>
                                </c:if>
                            
                                <c:if test="${loop.index == 0}">
                                    <c:set var="listOfnames" value="${x.namelist}"/>
                                </c:if>
                                <c:if test="${loop.index > 0}">
                                    <c:set var="listOfnames" value="${listOfnames}, ${x.namelist}"/>
                                </c:if>
                        </c:forEach>
                        
                        <c:if test="${empty tablesUsed}">
                            <c:set var="tablesUsed" value="FloatResultHarnessed"/>
                        </c:if>
                        TABLES USED: ${tablesUsed}<br/>
                        <c:out value="SchemaName=${prname}, ActID=${pr.id},"/><br/>
                        <c:out value="${listOfnames}"/><br/>  
                       
                        <c:forEach var="x" items="${listOfnames}">
                            <c:forEach var="y" items="${tablesUsed}">
                                <c:if test="${debugMode}">
                                <c:out value="select res.schemaInstance, res.value from ${y} res join Activity act on res.activityId=act.id where res.schemaName like ${prname} and res.name=${x} and act.parentActivityId=${pr.parentActivityId}"/><br/>
                                </c:if>
                                <sql:query var="temp" dataSource ="jdbc/rd-lsst-cam-dev-ro">
                                select res.schemaInstance, res.value from ${y} res join Activity act on res.activityId=act.id where res.schemaName like ? and res.name=? and act.parentActivityId=?
                                <sql:param value="${prname}%"/>
                                <sql:param value="${x}"/>
                                <sql:param value="${pr.parentActivityId}"/>  
                                </sql:query>
                            </c:forEach>
                        </c:forEach> 
                        
                        <c:set var="listOfnumbers" value=""/>
                        <c:if test="${temp.rowCount > 0}">
                            <c:forEach var="s" items="${temp.rows}" varStatus="loop">
                                <c:if test="${loop.index == 0}">
                                   <c:set var="listOfnumbers" value="${s.value}"/>
                                </c:if>
                                <c:if test="${loop.index > 0}">
                                   <c:set var="listOfnumbers" value="${listOfnumbers}, ${s.value}"/>
                                </c:if>
                            </c:forEach>
                        </c:if>
                    
                        <c:if test="${!empty listOfnumbers}">
                    <%--
                            <c:set var="resultMin" value="${portal:getMinimumFromList(pageContext.session, fn:split(listOfnumbers, ','))}"/> 
                             <c:out value="${MINIMUM=resultMin}"/> --%>
                        </c:if>
                        
                        <%--
                        <c:if test="${fn:contains('FloatResultHarnessed',tableUsed)}">  
                            <c:set var="resultsFloat" value="${portal:getSummaryResults(pageContext.session, prname, parentActivityId, 'FloatResultHarnessed', fn:split(listOfnames, ','))}"/>   
                            <c:out value="${resultsFloat}"/>    
                       </c:if> --%>
                        <p></p>
                       
                    </c:forEach>
                     
                </tbody>
            </table>
        
        </c:when>
    </c:choose>
    </body>
</html>
