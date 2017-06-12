<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>
<%@taglib prefix="etapiclient" uri="http://camera.lsst.org/etapiclient" %>
<%@taglib prefix="sensorutils" uri="http://camera.lsst.org/sensorutils" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Sensor Summary Table</title>
    </head>
    <body>
        <h1>Sensor Summary Table</h1>

        <%--
        <c:set var="callrest" value="${etapiclient:getRunInfo(appVariables.dataSourceMode, false)}"/>
        
    <display:table name="${callrest.entrySet()}" id="callrest"/>

        --%>
    <%--
         <c:set var="manuapi" value="${etapiclient:getManufacturerId(appVariables.dataSourceMode,false)}"/>
    <display:table name="${manuapi.entrySet()}" id="manuapi"/>  

    
     <c:set var="schemaapi" value="${etapiclient:getRunSchemaResults(appVariables.dataSourceMode,false)}"/>
    <display:table name="${schemaapi.entrySet()}" id="schemaapi"/>  

     <c:set var="jhapi" value="${etapiclient:getResultsJH(appVariables.dataSourceMode,false)}"/>
    <display:table name="${jhapi.entrySet()}" id="jhapi"/> 
    --%>
  <%--
     <c:set var="jhschemaapi" value="${etapiclient:getResultsJH_schema(appVariables.dataSourceMode,false,'SR-EOT-1','ITL-CCD','read_noise','read_noise','ITL-3800C-021')}"/> 

    <display:table name="${jhschemaapi.entrySet()}" id="jhschemaapi"/> 
  --%>
    
  
  <c:set var="sensorSummaryTable" value="${sensorutils:getSensorSummaryTable(pageContext.session,appVariables.dataSourceMode)}"/>
  <display:table name="${sensorSummaryTable}" id="curSensor" defaultsort="1" class="datatable" export="true" >
      <display:column title="LSST_NUM" sortable="true" sortProperty="lsstId" >
          <c:url var="hdwLink" value="http://lsst-camera.slac.stanford.edu/eTraveler/exp/LSST-CAMERA/displayHardware.jsp">
              <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
              <c:param name="hardwareId" value="${curSensor.hardwareId}"/>
          </c:url>
          <a href="${hdwLink}" target="_blank"><c:out value="${curSensor.lsstId}"/></a>
      </display:column>
      <display:column title="Num of Tests<br>Passed" sortable="true" >${curSensor.numTestsPassed}</display:column>
      <display:column title="Percent Defects" >${curSensor.percentDefects}</display:column>
      <display:column title="HCTI Worst<br>Channel" >${curSensor.worstHCTIChannel}</display:column>
      <display:column title="VCTI Worst<br>Channel" >${curSensor.worstVCTIChannel}</display:column>
      <display:column title="Max Read Noise" sortable="true" >${curSensor.maxReadNoise}</display:column>
      <display:column title="Max Read Noise<br/>Channel" sortable="true" >${curSensor.maxReadNoiseChannel}</display:column>
      <display:column title="Sensor Acceptance<br>Link" > 
          <c:url var="acceptanceLink" value="SensorAcceptanceReport.jsp">
              <c:param name="dataSourceMode" value="${appVariables.dataSourceMode}"/>
              <c:param name="lsstId" value="${curSensor.lsstId}"/>
          </c:url>
          <a href="${acceptanceLink}" target="_blank"><c:out value="link"/></a>
      </display:column>

  </display:table>





    </body>
</html>

 