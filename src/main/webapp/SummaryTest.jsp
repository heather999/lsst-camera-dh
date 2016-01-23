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
            
            <%-- query used to get the testnames --%>
            <sql:query var="summaryTestname" dataSource="jdbc/config-prod">
                select distinct testname, ntype from summary_md
            </sql:query>
            
            <%-- determine which datatable to read from on rd_lsst_cam MySQL database f=float, i-int and b=both  
            <c:out value="Datatable used in query:"/><br/>
            <c:forEach var="tes" items="${summaryTestname.rows}">
                <c:choose>
                <c:when test="${tes.ntype == 'f'}">
                    <c:out value="${tes.testname} from FloatResultHarnessed"/><br/>
                </c:when>
                <c:when test="${tes.ntype =='i'}">
                    <c:out value="${tes.testname} from IntResultHarnessed"/><br/>
                </c:when>
                <c:when test="${tes.ntype == 'b'}">
                   <c:out value="${tes.testname} from FloatResultHarnessed and IntResultHarnessed"/><br/>
                </c:when>   
                </c:choose>
            </c:forEach> --%>
                   <p></p>
            <table class="datatable" border="1">
                <tbody>
                    <tr><th>Status</th> 
                        <th>spec. ID</th>
                        <th>Description</th>
                        <th>Specification</th>
                        <th>Measurement</th>
                    </tr>
                    <%-- loop over the testnames to get the name(s) then build a string of these names to pass to tag --%>
                    <c:forEach var="sum" items="${summaryTestname.rows}" varStatus="loop">
                         
                        <sql:query var="namelistString" dataSource="jdbc/config-prod">
                            select namelist from summary_md where testname = ?
                            <sql:param value="${sum.testname}"/>
                        </sql:query>
                    
                        <c:set var="listOfnames" value=""/>
                        <c:forEach var="x" items="${namelistString.rows}" varStatus = "loop">
                            <c:if test="${loop.index == 0}">
                                <c:set var="listOfnames" value="${x.namelist}"/>
                            </c:if>
                            <c:if test="${loop.index > 0}">
                                <c:set var="listOfnames" value="${listOfnames}, ${x.namelist}"/>
                            </c:if>
                        </c:forEach>
                         
                         
                        <%-- call tag with args --%>
                        <c:set var="SchemaNameFloat" value="${portal:getSummaryResults(pageContext.session, sum.testName, parentActivityId, sum.ntype, fn:split(listOfnames, ','))}"/>  
                        <c:forEach var="lons" items="${listOfnames}"> 
                            <sql:query var="specInfo" dataSource="jdbc/config-prod">
                                select specid from summary_md where testname = ? and namelist = ?
                                <sql:param value="${sum.testName}"/>
                                <sql:param value="${lons}"/>
                            </sql:query>
                            <c:set var="specID" value="${specInfo.rows[0].specid}"/>
                            
                            <sql:query var="lca" dataSource="jdbc/config-prod">
                                select description, specification, scope from lca128 where specid=?
                                <sql:param value="${specID}"/>
                            </sql:query>
                            <c:set var="description" value="${lca.rows[0].description}"/>
                            <c:set var="specification" value="${lca.rows[0].specification}"/>
                            <c:set var="scope" value="${lca.rows[0].scope}"/>
                            
                            <c:forEach var="line" items="${SchemaNameFloat}">
                                <c:set var="lval" value="${fn:split(line,',')}"/>
                                <c:forEach var="subline" items="${lval}">
                                    <c:if test="${fn:contains(subline,'min')}">
                                        <c:set var="min" value="${fn:replace(subline,'min=','')}-"/>
                                    </c:if>
                                     <c:if test="${fn:contains(subline,'max')}">
                                        <c:set var="max" value="${fn:replace(subline,'max=','')}"/>
                                        <c:set var="max" value="${fn:replace(max,'}','')}"/>
                                    </c:if>
                                </c:forEach>
                            </c:forEach>
                        </c:forEach>
                        <tr>
                            <td>
                            ${actHistStatus}
                            </td>
                             <td>
                             ${specID}
                            </td>
                             <td>
                              ${description}
                            </td>
                             <td>
                             ${specification}
                            </td>
                             <td>
                              ${min}-${max}
                            </td>
                        </tr>
                        <%--
                        <c:forEach var="line" items="${SchemaNameFloat}">
                            
                            <sql:query var="lca128" dataSource="jdbc/config-prod">
                               select specid,description,specification,scope from LCA128 where specid = ?
                               <sql:param value="CCD-007"/>
                            </sql:query> 
                            
                            <c:set var="specID" value="${lca128.rows[0].specid}"/>
                            <c:set var="description" value="${lca128.rows[0].description}"/>
                            <c:set var="specification" value="${lca128.rows[0].specification}"/>
                            <c:set var="scope" value="${lca128.rows[0].scope}"/>
                                                                                    
                            <c:set var="lval" value="${fn:split(line,',')}"/>
                            <tr>
                                    <td>${actHistStatus}</td>  
                                    <td>${specID}</td>  
                                    <td>${description}</td> 
                                    <td>${specification}</td> 
                            <c:forEach var="subline" items="${lval}">
                                <c:if test="${fn:contains(subline,'min')}">
                                    <c:set var="min" value="<td>${subline}-"/>
                                </c:if>
                                 <c:if test="${fn:contains(subline,'max')}">
                                    <c:set var="max" value="${subline}</td>"/>
                                </c:if>
                            </c:forEach>
                            ${min}${max}
                                        </tr>
                        </c:forEach>
                        --%>
                         
                        
                    </c:forEach>
                         
                     
                </tbody>
            </table>
        </c:when>
    </c:choose>
    </body>
</html>
