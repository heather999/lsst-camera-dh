<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="display" uri="http://displaytag.sf.net" %>
<%@taglib uri="http://camera.lsst.org/portal" prefix="portal" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

 
<%-- 
    Author     : chee
--%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Test Report Page</title>
    </head>
    <body>
        
    <sql:query var="LCA128spec" dataSource="jdbc/config-prod">
        select * from lca128
    </sql:query>
    
    <c:set var="schemaFloat" value="${fn:split('flat_pairs,cte,dark_current,qe_analysis,prnu',',')}"/>
    <c:set var="schemaInt" value="${fn:split('bright_defects,dark_defects,traps,dark_current,qe_analysis,prnu',',')}"/>
     
    <sql:query var="sensor">
       select act.id, act.parentActivityId, hw.lsstId, statusHist.activityStatusId from Activity act join Hardware hw on act.hardwareId=hw.id 
       join Process pr on act.processId=pr.id join ActivityStatusHistory statusHist on act.id=statusHist.activityId 
       where pr.name='test_report_offline' order by act.parentActivityId desc   
    </sql:query>
    
    <p><c:out value="sensor count ${sensor.rowCount}"/></p>
    
    <c:choose>
        <c:when test="${empty param}">
            The list contains the activity Id, the schema name, the parent activity Id and the activity status id, in that order.<br/>
            Select one (for test reports only):
            <form name="sensorform" id="sensorform" action="TestReportPage.jsp?rectype=NEWSENSOR" method="get" >
                <table>
                    <thead>
                    <td>
                    <tr>
                        <td><select name="schemaInfo" id="schemaInfo" size="6">
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
            
            
            

                                                 
            <%-- activities for parentActivityId  --%>
            <p>parentActId = ${parentActivityId}</p>
            
            <sql:query var="activities"> 
                select act.id, act.parentActivityId, pr.name from Activity act join Process pr on act.processId=pr.id where act.parentActivityId=?
                <sql:param value="${parentActivityId}"/>
            </sql:query>
                
            <c:forEach var="activityInfo" items="${activities.rows}">
                
                <sql:query var="floatName">
                    select schemaName, name from FloatResultHarnessed where activityId = ?
                    <sql:param value="${activityInfo.activityId}"/>
                </sql:query>
                
                <c:if test="${floatName.rowCount > 0}">
                    <c:set var="sname" value="${floatName.rows[0].name}"/>
                    <c:set var="schemaName" value="${floatName.rows[0].schemaName}"/>
                    <c:out value="set schemaName to: ${schemaName}  name to : ${sname}"/><br/>
                </c:if>
                
                <sql:query var="IntName">
                    select schemaName from IntResultHarnessed where activityId = ?
                    <sql:param value="${activityInfo.id}"/>
                </sql:query>
                <c:if test="${IntName.rowCount > 0}">
                    <c:set var="schemaName" value="${IntName.rows[0].schemaName}"/>
                </c:if>
                
                <c:out value="activityId ${activityInfo.id}"/>
                <c:set var="actname" value="activity ${fn:replace(activityInfo.name,'_offline','')}"/>
                <c:out value="parentActivityId ${activityInfo.parentActivityId}"/><br/>
                <c:out value="schemaName ${schemaName}"/><br/>
                <c:out value="${actname}"/><br/>
                
                <sql:query var="noiseinfo">
                  select res.schemaInstance, res.value from FloatResultHarnessed res join Activity act on res.activityId=act.id
                  where res.name=? and res.schemaName=? and act.parentActivityId=? order by res.value asc
                  <sql:param value="${actname}"/>
                  <sql:param value="${schemaName}"/>
                  <sql:param value="${activityInfo.parentActivityId}"/>
                </sql:query>
                <c:out value="rowcount ${noiseInfo.rowCount}"/><br/><br/>
            </c:forEach>
            
            <%-- read_noise min and max --%> 
            <sql:query var="noiseinfo">
               select res.schemaInstance, res.value from FloatResultHarnessed res join Activity act on res.activityId=act.id
               where res.name='read_noise' and res.schemaName='read_noise' and act.parentActivityId=? order by res.value asc
               <sql:param value="${parentActivityId}"/>
            </sql:query>
            
            <c:forEach var="noise" items="${noiseinfo.rows}" varStatus="loop">
                <c:if test="${loop.first}">
                    <c:set var="noiseMin" value="${noise.value}"/>
                    <c:out value="noiseMin ${noiseMin}"/>
                </c:if>
                <c:if test="${loop.last}">
                    <c:set var="noiseMax" value="${noise.value}"/>
                    <c:out value="noiseMax ${noiseMax}"/><br/>
                </c:if>
            </c:forEach>  
            
            <%-- flat_pairs, full well --%> 
            <sql:query var="flatinfo">
                select res.schemaInstance, res.value from FloatResultHarnessed res join Activity act on res.activityId=act.id 
                where res.schemaName='flat_pairs' and res.name='full_well' and act.parentActivityId=? order by res.value asc
                <sql:param value="${parentActivityId}"/>
            </sql:query>
            <c:forEach var="flat" items="${flatinfo.rows}" varStatus="loop">
                 <c:if test="${loop.first}">
                    <c:set var="flatMin" value="${flat.value}"/>
                    <c:out value="flatMin ${flatMin}"/>
                </c:if>
                <c:if test="${loop.last}">
                    <c:set var="flatMax" value="${flat.value}"/>
                    <c:out value="flatMax ${flatMax}"/><br/>
                </c:if>
            </c:forEach>
             
            <%--
            <display:table class="datatable" id="nrow" name="${noiseinfo.rows}">
                <display:column property="status" title="Status" sortable="true" headerClass="sortable">
                    ${actHistStatus}
                </display:column>
                <display:column property="specId" title="Spec. ID" sortable="true" headerClass="sortable">
                    spec goes here
                </display:column>
                <display:column property="description" title="Description" sortable="true" headerClass="sortable">
                    description goes here
                </display:column>
                <display:column property="specification" title="Specification" sortable="true" headerClass="sortable">
                    specification goes here
                </display:column>
                <display:column property="measurement" title="Measurement" sortable="true" headerClass="sortable">
                    
                </display:column>
            </display:table> --%>
           
        </c:when>
    </c:choose>
    
    <%--
    <c:forEach var="s" items="${sensor.rows}">
        <sql:query var="activity">
            select act.id, act.parentActivityId from Activity act join Hardware hw on act.hardwareId=hw.id 
            join Process pr on act.processId=pr.id join ActivityStatusHistory statusHist on act.id=statusHist.activityId 
            where statusHist.activityStatusId=1 and hw.lsstId=? and 
            pr.name='test_report_offline' order by act.parentActivityId desc
            <sql:param value="${s.lsstId}"/>
        </sql:query>

        <display:table name="${processId.rows}" class="datatable" id="row" >
           <display:column property="id" title="actvity id" sortable="true"/>
           <display:column property="parentActivityId" title="parent activity id" sortable="true"/>
           <display:column property="name" title="process"/>
        </display:table>
    </c:forEach> --%>
    
    <%--
    <sql:query var="processId">
        select act.id, act.parentActivityId, pr.name from Activity act
        join Process pr on act.processId=pr.id where lower(pr.name) = 'test_report_offline' 
    </sql:query>
    
    <sql:query var="noise">
        select res.schemaInstance, res.value from FloatResultHarnessed res join Activity act on res.activityId=act.id where
        res.schemaName='read_noise' and lower(res.name)='read_noise' and act.parentActivityId=13214
    </sql:query>
    
    <sql:query var="ccd008">
        select res.schemaInstance, res.value from FloatResultHarnessed res join
        Activity act on res.activityId=act.id where res.schemaName='flat_pairs'
        and res.name='full_well' and act.parentActivityId=13214
    </sql:query>
    
    <sql:query var="ccd009">
        select res.schemaInstance, res.value from FloatResultHarnessed res join
        Activity act on res.activityId=act.id where res.schemaName='flat_pairs'
        and res.name='max_frac_dev' and act.parentActivityId=13214
    </sql:query>
    
    <sql:query var="ccd010a">
        select res.schemaInstance, res.value from FloatResultHarnessed res join
Activity act on res.activityId=act.id where res.schemaName='cte' and
res.name='cti_high_serial' and act.parentActivityId=13214 
    </sql:query>
    
    <sql:query var="ccd010b">
         select res.schemaInstance, res.value from FloatResultHarnessed res join
Activity act on res.activityId=act.id where res.schemaName='cte' and
res.name='cti_high_serial_error' and act.parentActivityId=13214
    </sql:query>
    
    <sql:query var="ccd010c">
        select res.schemaInstance, res.value from FloatResultHarnessed res join
Activity act on res.activityId=act.id where res.schemaName='cte' and
res.name='cti_low_serial' and act.parentActivityId=13214
    </sql:query>
    
    <sql:query var="ccd010d">
       select res.schemaInstance, res.value from FloatResultHarnessed res join
       Activity act on res.activityId=act.id where res.schemaName='cte' and
       res.name='cti_low_serial_error' and act.parentActivityId=13214
    </sql:query>
    
     
    <c:if test="${processId.rowCount > 0}">
       hardware rowCount=${processId.rowCount}<p/>
        <display:table name="${processId.rows}" class="datatable" id="row" >
           <display:column property="id" title="actvity id" sortable="true"/>
           <display:column property="parentActivityId" title="parent activity id" sortable="true"/>
           <display:column property="name" title="process"/>
        </display:table>
    </c:if>
       --%>
       
       
     <%--
    <table>
        <tr>
            <td>
    <c:if test="${hwID.rowCount > 0}">
       hardware rowCount=${hwID.rowCount}<p/>
               select act.id, act.parentActivityId, pr.name from Activity act

        <display:table name="${hwID.rows}" class="datatable" id="row" >
           <display:column property="id" title="ID" sortable="true">
               ${row.id}
           </display:column>
           <display:column property="lsstId" title="lsstId" sortable="true">
               ${row.lsstId}
           </display:column>
        </display:table>
    </c:if>
    </td>
    
    <td> 
   <c:if test="${noise.rowCount > 0}">
       <display:table name="${noise.rows}" class="datatable" id="nrow" >
           <display:column property="schemaInstance" title="Noise" sortable="true">
               ${nrow.schemaInstance}
           </display:column>
           <display:column property="value" title="value" sortable="true">
               ${nrow.value}
           </display:column>
        </display:table>
   </c:if>   
  </td>
  
  <td>
         <c:if test="${ccd008.rowCount > 0}">
         <display:table name="${ccd008.rows}" class="datatable" id="c8row" >
           <display:column property="schemaInstance" title="CCD8" sortable="true">
               ${c8row.schemaInstance}
           </display:column>
           <display:column property="value" title="value" sortable="true">
               ${c8row.value}
           </display:column>
        </display:table>
         </c:if>
  </td>
    </tr>
    </table>       
--%>
<%--
<c:forEach var="dataset" items="${datasets}">
    <h3>dataset=${dataset.metadata} </h3>
    <c:catch var="exception">
       <c:set var="viewTheInfo" value="${dataset.viewInfo.locations}"/>
    </c:catch>
    <c:choose>    
    <c:when test="${exception != null}">
        <h3>viewInfo not available </h3>
    </c:when>
    <c:when test="${exception == null}">
        <c:set var="elements" value="${fn:split(viewTheInfo,',')}"/>
        <c:forEach var="elem" items="${elements}">
             ELEMENT:${elem}<br/>
        </c:forEach>
        <h3>viewTheInfo=${viewTheInfo} </h3>
    </c:when>    
    </c:choose>
</c:forEach>

         
    <h3>Sensor Results</h3>    
    <table border="1" width="90%">
        <tbody>
            <tr><th>Status</th><th>Spec. ID</th><th>Description</th><th>Specification</th><th>Measurement</th></tr>
        </tbody>
    </table>  
    
    <h3>Read Noise Results</h3>    
    <table border="1" width="90%">
    <tbody>
        <tr><th>Status</th><th>Spec. ID</th><th>Description</th><th>Specification</th><th>Measurement</th></tr>
    </tbody>
    </table> 
    <h3>Plot for READ NOISE</h3>
    <p></p>
        
    <h3>Full Well and Nonlinearity Results</h3>    
    <table border="1" width="90%">
    <tbody>
        <tr><th>Status</th><th>Spec. ID</th><th>Description</th><th>Specification</th><th>Measurement</th></tr>
    </tbody>
    </table> 
     
    <table border="1" width="50%">
    <tbody>
        <tr><th>Amp</th><th>Full Well</th><th>Nonlinearity</th></tr>
    </tbody>
    </table> 
    <p></p>  
     
     
      <table>
            <tbody>
                <c:forEach var="dataset" items="${datasets}">  
                    <%-- A dataset's metadata and it's locations are in a viewInfo object. 
                         We can set the var datasetLocations to the locations we found for convenience.
                    --%>
                  <%--  <c:set var="versionMetadata" value="${dataset.viewInfo.version.metadata}"/> 
                    <c:set var="datasetLocations" value="${dataset.viewInfo.locations}"/>
                    <c:forEach var="location" items="${datasetLocations}" varStatus="status"> --%>
                        <%-- We actually need to do a tiny bit of processing to find the master location --%>
                        <%--
                       <c:if test="${location.isMaster().booleanValue()}">
                            <c:set var="masterLocation" value="${location}" />
                        </c:if>
                    </c:forEach>
                    <tr>
                        <td>${dataset.name}</td>
                        <td>${dataset.path}</td>
                        <td>${masterLocation.site}</td>
                    </tr>
                
            </tbody>
        </table> --%>
                        
                        <%--
                        
                         <c:if test="${fn:length(listOfnames) > 0}">
                            <c:choose>
                                <c:when test="${ntype=='f' || ntype == 'b'}">
                                     <sql:query var="lcaInfo" dataSource="jdbc/config-prod">
                                       select description, specification, scope from lca128 where specid = ?
                                     <sql:param value="${specInfo}"/>
                                     </sql:query>
                                     <c:set var="dbtable" value="FloatResultHarnessed"/>
                                      
                                     <%-- results returned as a list so loop over it to get the actual values --%>
                                    <%--
                                     <c:set var="resultsFloat" value="${portal:getSummaryResults(pageContext.session, prname, parentActivityId, dbtable, fn:split(listOfnames, ','))}"/>  
                                     <c:forEach var="r" items="${resultsFloat}">
                                         <c:out value="${r.schemaInstance} ${r.value} ${prname}"/><br/>
                                     </c:forEach> --%>
                                     
                                     <%--
                                     <c:forEach var="r" items="${resultsFloat}">
                                         <c:forEach var="na" items="${listOfnames}">
                                             <sql:query var="specInfo" dataSource="jdbc/config-prod">
                                                 select s.specid specid, l.description description from summary_md s join lca128 l on s.specid = l.specid where s.namelist = ?
                                                 <sql:param value="${na}"/>
                                             </sql:query>
                                         <tr>
                                             <td>${prname}</td> <td>${specInfo.rows[0].specid}</td> <td>${specInfo.rows[0].description}</td> <td></td> <td></td> <td>${dbtable}</td>
                                         </tr>
                                          </c:forEach>
                                     </c:forEach>
                                         
                                     <c:set var="dbtable" value="IntResultHarnessed"/> 
                                     <c:set var="resultsInt" value="${portal:getSummaryResults(pageContext.session, prname, parentActivityId, dbtable, fn:split(listOfnames, ','))}"/>  
                                     
                                     <c:forEach var="r" items="${resultsInt}">
                                         <c:forEach var="na" items="${listOfnames}">
                                             <sql:query var="specInfo" dataSource="jdbc/config-prod">
                                                 select s.specid specid, l.description description from summary_md s join lca128 l on s.specid = l.specid where s.namelist = ?
                                                 <sql:param value="${na}"/>
                                             </sql:query>
                                         <tr>
                                             <td>${prname}</td> <td>${specInfo.rows[0].specid}</td> <td>${specInfo.rows[0].description}</td> <td></td> <td></td> <td>${dbtable}</td>
                                         </tr>
                                          </c:forEach>
                                     </c:forEach>
                                     --%>
                                     
                                    <%--
                                    <display:table class="datatable" name="${resultsFloat}" id="sRow">
                                    </display:table> --%>
                                        <%--
                                </c:when>
                                <c:when test="${ntype =='i' || ntype == 'b'}">
                                     <sql:query var="lcaInfo" dataSource="jdbc/config-prod">
                                       select description, specification, scope from lca128 where specid = ?
                                     <sql:param value="${specInfo}"/>
                                     </sql:query>
                                    <c:set var="dbtable" value="IntResultHarnessed"/>
                                    <c:set var="resultsInt" value="${portal:getSummaryResults(pageContext.session, prname, parentActivityId, dbtable, fn:split(listOfnames, ','))}"/>  
                                    <c:out value="${dbtable}"/>
                                  ####  <display:table class="datatable" name="${resultsInt}" id="sRow">
                                    </display:table>  
                                </c:when>
                                        
                                <c:when test="${ntype == 's'}">
                                     <sql:query var="lcaInfo" dataSource="jdbc/config-prod">
                                       select description, specification, scope from lca128 where specid = ?
                                       <sql:param value="${specInfo}"/>
                                     </sql:query>
                                    <c:set var="dbtable" value="StringResultHarnessed"/>
                                    <c:set var="resultsStr" value="${portal:getSummaryResults(pageContext.session, prname, parentActivityId, dbtable, fn:split(listOfnames, ','))}"/>  
                                    <c:out value="${dbtable}"/>
                                  ### <display:table class="datatable" name="${resultsStr}" id="sRow">
                                    </display:table> ###
                                </c:when>        
                            </c:choose>
                        </c:if>
                        --%>
    </body>
</html>



