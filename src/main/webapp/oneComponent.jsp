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
        <title>CCD Explorer</title>
    </head>
    <body> 
        <h1>CCD Explorer</h1>


        <%-- Select CCD as the HardwareType for this page, scope session means all the pages? set scope to page --%>
        <c:set var="ccdHdwTypeId" value="1" scope="page"/>  
        <c:set var="ccdHdwTypeITL" value="9" scope="page"/> 
        <c:set var="ccdHdwTypeE2V" value="10" scope="page"/> 

        <c:if test="${empty selectedLsstId}">
            <c:set var="selectedLsstId" value="" scope="page"/>            
        </c:if>


        <c:if test="${! empty param.lsstIdValue}">
            <c:set var="selectedLsstId" value="${param.lsstIdValue}" scope="page"/>
        </c:if>

        <%--
        Request parameters : ${param}<br>
        Selected LSST Id: ${selectedLsstId}<br>
        --%>

        <%-- Selected HdwType: ${ccdHdwTypeId} --%>

        <%-- List of CCD ids --%>
        <c:set var="lsstIdQuery" value="${portal:getComponentIds(pageContext.session, ccdHdwTypeId)}"/>

        <%-- Retrieve full list of current hardware status and location for all CCDs --%>
        <%--
        <c:set var="hdwStatLocTable" value="${portal:getHdwStatLocTable(pageContext.session,ccdHdwTypeId)}"/>
        --%>

        <%--
                <display:table name="${lsstIdQuery}" export="true" class="datatable"/> 
        --%>

        <br>
        <br>

        <form name="ccdSelection">
            <select name="lsstIdValue">
                <c:forEach items="${lsstIdQuery}" var="hdwRow" >
                    <option value="${hdwRow.value}" <c:if test="${hdwRow.value == selectedLsstId}">selected</c:if> > ${hdwRow.value}</option>
                </c:forEach>
            </select>
            <input type="submit" name="ccdSelection" value="Select CCD"/>
        </form>



        <c:choose>
            <c:when test="${empty selectedLsstId}">
                Please select a LSST Id from the above drop down menu. 
            </c:when>
            <c:otherwise>

                <%-- Extract useful info from Hardware table --%>
                <sql:query  var="hdwData" scope="page" >
                    select  Hardware.id,Hardware.manufacturer,Hardware.model, Hardware.manufactureDate from Hardware where Hardware.lsstId=? and (Hardware.hardwareTypeId=? OR Hardware.hardwareTypeId=? OR Hardware.hardwareTypeId=?) 
                    <sql:param value="${selectedLsstId}"/>
                    <sql:param value="${ccdHdwTypeId}"/>
                    <sql:param value="${ccdHdwTypeITL}"/>
                    <sql:param value="${ccdHdwTypeE2V}"/>
                </sql:query>
                    
                <c:set var="curHdwData" value="${hdwData.rows[0]}"/>

                <section>
                    <%-- Retrieve full list of current hardware status and location this CCD --%>
                    <c:set var="hdwStatLoc" value="${portal:getHdwStatLoc(pageContext.session,selectedLsstId)}" scope="page"/>

                    <display:table name="${hdwStatLoc}" export="true" class="datatable" id="hdl" >
                        <display:column title="LsstId" sortable="true" >${hdl.lsstId}</display:column>
                        <display:column title="Date Registered" sortable="true" >${hdl.creationDate}</display:column>
                        <display:column title="Overall Component Status" sortable="true" >${hdl.status}</display:column>
                        <display:column title="Site" sortable="true" >${hdl.site}</display:column>
                        <display:column title="Location" sortable="true" >${hdl.location}</display:column>
                        <display:column title="Current Traveler" sortable="true" >${hdl.curTravelerName}</display:column>
                        <display:column title="Current Process Step" sortable="true" >${hdl.curActivityProcName}</display:column>
                        <display:column title="Current Process Step Status" sortable="true" >${hdl.curActivityStatus}</display:column>
                        <display:column title="Most Recent Timestamp" sortable="true" >${hdl.curActivityLastTime}</display:column>
                        <display:column title="NCR" sortable="true" >${hdl.inNCR}</display:column>
                    </display:table>



                    <%-- <display:table name="${hdwData.rows}" class="datatable"/>  --%>
                    <display:table name="${hdwData.rows}" export="true" class="datatable" id="hdw"> 
                        <display:column title="Manufacture Date"> <c:out value="${hdw.manufactureDate}"/> </display:column> 
                        <display:column title="Manufacturer"> <c:out value="${hdw.manufacturer}"/> </display:column> 
                        <display:column title="Model"> <c:out value="${hdw.model}"/> </display:column> 
                    </display:table>       
                </section>


                <section>
                   
                    
                    <%-- <c:forEach var="row" items="${hdwData.rows}" begin = "0" end="0" > --%>
                        <c:set var="hdwId" value="${curHdwData.id}" scope="page"/> 
                        <%--
                        <c:set var="travelerList" value="${portal:getTravelerCol(pageContext.session,hdwId)}"/>
                        <display:table name="${travelerList}" export="true" class="datatable" id="trav"> 
                            <display:column title="Traveler" sortable="true" >${trav.name}</display:column>
                            <display:column title="Status" sortable="true" >${trav.statusName}</display:column>
                            <display:column title="Start Time" sortable="true" >${trav.beginTime}</display:column>
                            <display:column title="End Time" sortable="true" >${trav.endTime}</display:column>
                        </display:table>--%>
                   <%-- </c:forEach> --%>
             
        

                    <h2>Summary of Traveler Status</h2>
                    <etraveler:activityList travelersOnly="true" hardwareId="${hdwId}"/>
                </section>
                <section>
                    <%--
                    <c:forEach var="curTraveler" items="${travelerList}"> --%>
                        <%--<h3>${curTraveler.name} ${curTraveler.actId}</h3><br> --%>
                        <%--
                        <c:set var="actList" value="${portal:getActivitiesForTraveler(pageContext.session,curTraveler.actId,hdwId)}"/>

                        <c:forEach var="curAct" items="${actList}" varStatus="status">
                        --%>
                            <%--
                            <c:choose>
                               
                                <c:when test="${status.first}">
                                    <h3><b>Traveler ${curTraveler.name}</b></h3>
                                    <etraveler:expandActivity var="stepList" activityId="${curAct}"/>


                                    <etraveler:findCurrentStep varStepLink="currentStepLink" varStepEPath="currentStepEPath" 
                                                               varStepId="currentStepActivityId" stepList="${stepList}"/>



                                    <display:table id="step" name="${stepList}" class="datatable">
                                        <display:column title="Step">
                                            <c:if test="${! empty step.stepPath}">

                                                <c:out value="${step.stepPath}"/>

                                            </c:if>
                                        </display:column>
                                        <display:column title="Name">
                                            <c:choose>
                                                <c:when test="${! empty currentStepLink && step.edgePath == currentStepEPath && (step.activityId == currentStepActivityId || (currentStepActivityId == -1 && empty step.activityId))}">
                                                    <c:set var="contentLink" value="${currentStepLink}"/>
                                                </c:when>
                                                <c:when test="${! empty step.activityId}">
                                                    <c:url var="contentLink" value="http://lsst-camera.slac.stanford.edu/eTraveler/exp/LSST-CAMERA/activityPane.jsp">
                                                        <c:param name="activityId" value="${step.activityId}"/>
                                                    </c:url>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:url var="contentLink" value="http://lsst-camera.slac.stanford.edu/eTraveler/exp/LSST-CAMERA/processPane.jsp">
                                                        <c:param name="processId" value="${step.processId}"/>
                                                    </c:url>                
                                                </c:otherwise>
                                            </c:choose>
                                            <a href="${contentLink}" target="content">${step.name}</a>
                                        </display:column>

                                        <display:column property="activityId"/>
                                        <display:column property="end"/>
                                        <display:column property="statusName" title="Status"/>

                                    </display:table>
                                </c:when>
                            --%>
                                <%--
                            <c:otherwise>


                                    <sql:query var="floatResults">
                                        SELECT name, value, schemaName, schemaVersion FROM FloatResultHarnessed 
                                        WHERE ${curAct}=FloatResultHarnessed.activityId AND name != "stat"
                                        UNION ALL
                                        SELECT name, value, schemaName, schemaVersion FROM IntResultHarnessed 
                                        WHERE ${curAct}=IntResultHarnessed.activityId AND name != "stat"
                                        UNION ALL
                                        SELECT name, value, schemaName, schemaVersion FROM StringResultHarnessed 
                                        WHERE ${curAct}=StringResultHarnessed.activityId AND name != "stat"
                                    </sql:query>
                                        
                                    <sql:query var="moreProcessInfo" scope="page">
                                        SELECT A.id, concat(P.name,'') as process, A.processId, A.inNCR, A.iteration,
                                        P.version AS version,A.begin,A.end
                                        FROM Process P, Activity A  
                                        WHERE P.id=A.processId AND A.id=${curAct}
                                    </sql:query>
                                        
                                    <c:forEach items="${moreProcessInfo.rows}" var="processRow" begin="0" end="0">
                                        <c:url var="activityLink" value="http://lsst-camera.slac.stanford.edu/eTraveler/exp/LSST-CAMERA/activityPane.jsp">
                                            <c:param name="activityId" value="${curAct}"/>
                                        </c:url>
                                        <h3><a target="_blank" href="${activityLink}">${processRow.process} version ${processRow.version} iteration ${processRow.iteration}</a></h3>
                                    </c:forEach>

                                    <sql:query var="outQuery" scope="page">
                                        SELECT creationTS, virtualPath, value FROM FilepathResultHarnessed 
                                        WHERE ${curAct}=FilepathResultHarnessed.activityId ORDER BY creationTS
                                    </sql:query>
                                    <c:if test="${outQuery.rowCount>0}" >


                                        <c:forEach items="${moreProcessInfo.rows}" var="processRow" begin="0" end="0">
                                            <c:url var="processLink" value="outputFiles.jsp">
                                                <c:param name="activityId" value="${curAct}"/>
                                                <c:param name="processName" value="${processRow.process}"/>
                                                <c:param name="processVersion" value="${processRow.version}"/>
                                            </c:url>
                                            <h4><a href="${processLink}" >${processRow.process} version ${processRow.version} iteration ${processRow.iteration} Output Files</a></h4>
                                            <br>
                                        </c:forEach>

                                    </c:if>
                             
                                    <c:if test="${floatResults.rowCount>0}" >
                                        <display:table name="${floatResults.rows}" export="true" class="datatable"/>
                                    </c:if>
                                </c:otherwise>
                                --%>
                            <%--</c:choose> --%>
                      <%--  </c:forEach>--%> <%-- End Activity Loop --%>
                        <br>
                    <%-- </c:forEach> --%> <%-- End Traveler Loop --%>

                    <sql:query var="activityQuery">
                        SELECT A.id, H.lsstId, concat(P.name,'') as process, A.processId, A.inNCR, A.iteration,
                        P.version AS version,A.begin,A.end,concat(AFS.name,'') as status
                        FROM Hardware H, Process P, 
                        Activity A INNER JOIN ActivityStatusHistory on ActivityStatusHistory.activityId=A.id and 
                        ActivityStatusHistory.id=(select max(id) from ActivityStatusHistory where activityId=A.id)
                        INNER JOIN ActivityFinalStatus AFS on AFS.id=ActivityStatusHistory.activityStatusId
                        WHERE H.id=A.hardwareId AND H.lsstId="${selectedLsstId}" AND 
                        (H.hardwareTypeId="${ccdHdwTypeId}" OR H.hardwareTypeId=${ccdHdwTypeITL} OR H.hardwareTypeId=${ccdHdwTypeE2V}) 
                        AND P.id=A.processId
                        ORDER BY A.id DESC
                    </sql:query>


                    <%--  <h2>All Processes</h2> --%>

                    <%-- <display:table name="${activityQuery.rows}" export="true" class="datatable"/> --%>
                    <%--
                                        <display:table name="${activityQuery.rows}" export="true" class="datatable" id="processes"> 
                                            <display:column title="LsstId" sortable="true"> <c:out value="${processes.lsstId}"/> </display:column> 
                                            <display:column title="Process" sortable="true"> <c:out value="${processes.Process}"/> </display:column> 
                                            <display:column title="Version" sortable="true"> <c:out value="${processes.version}"/> </display:column> 
                                            <display:column title="Status" sortable="true"> <c:out value="${processes.Status}"/> </display:column> 
                                            <display:column title="Start Time" sortable="true"> <c:out value="${processes.begin}"/> </display:column>
                                            <display:column title="End Time" sortable="true"> <c:out value="${processes.end}"/> </display:column>
                                            <display:column title="inNCR" sortable="true"> <c:out value="${processes.inNCR}"/> </display:column>
                                        </display:table>
                                        
                    --%>

                </section>

                <%--
            <h2>Process Steps with Available Output Files</h2>


                <c:forEach items="${activityQuery.rows}" var="actRow">
                    <sql:query var="outQuery" scope="page">
                        SELECT creationTS, virtualPath, value FROM FilepathResultHarnessed 
                        WHERE ${actRow.id}=FilepathResultHarnessed.activityId ORDER BY creationTS
                    </sql:query>
                    <c:if test="${outQuery.rowCount>0}" >
                        <c:url var="processLink" value="outputFiles.jsp">
                            <c:param name="activityId" value="${actRow.id}"/>
                            <c:param name="processName" value="${actRow.process}"/>
                            <c:param name="processVersion" value="${actRow.version}"/>
                        </c:url>
                        <h3><a href="${processLink}" >${actRow.process} version ${actRow.version} iteration ${actRow.iteration}</a></h3>
                        <br>
                    </c:if>
                </c:forEach>
                --%>

            </c:otherwise>
        </c:choose>



    </body>
</html>
