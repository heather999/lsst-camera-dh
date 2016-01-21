<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>

<%@taglib prefix="portal" uri="WEB-INF/portal.tld" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="display" uri="http://displaytag.sf.net" %>
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
        
    
    <sql:query var="hwID">
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
    --%>
    <%--
      <table>
            <tbody>
                <c:forEach var="dataset" items="${datasets}"> --%>
                    <%-- A dataset's metadata and it's locations are in a viewInfo object. 
                         We can set the var datasetLocations to the locations we found for convenience.
                    --%>
                  <%--  <c:set var="versionMetadata" value="${dataset.viewInfo.version.metadata}"/> 
                    <c:set var="datasetLocations" value="${dataset.viewInfo.locations}"/>
                    <c:forEach var="location" items="${datasetLocations}" varStatus="status"> --%>
                        <%-- We actually need to do a tiny bit of processing to find the master location --%>
                   <%--     <c:if test="${location.isMaster().booleanValue()}">
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
        </table> --%>
    </body>
</html>



