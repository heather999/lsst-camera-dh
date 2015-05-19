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
        <c:set var="hdwStatLocTable" value="${portal:getHdwStatLocTable(pageContext.session,ccdHdwTypeId)}"/>

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
                <sql:query  var="hdwData"  >
                    select  Hardware.manufacturer,Hardware.model, Hardware.manufactureDate, Hardware.creationTS from Hardware where Hardware.lsstId=? and (Hardware.hardwareTypeId=? OR Hardware.hardwareTypeId=? OR Hardware.hardwareTypeId=?) 
                    <sql:param value="${selectedLsstId}"/>
                    <sql:param value="${ccdHdwTypeId}"/>
                    <sql:param value="${ccdHdwTypeITL}"/>
                    <sql:param value="${ccdHdwTypeE2V}"/>
                </sql:query>

                <section>
                    <%-- searches list of CCDs to locate the status/loc record for this lsstId --%>
                    <c:forEach items="${hdwStatLocTable}" var="ccd">
                        <c:if test="${ccd.lsstId == selectedLsstId}">

                            <h2>Current Status and Location</h2>
                            <table style="width:50%">
                                <%-- <caption><b>Current Status and Location</b></caption> --%>
                                <tr>
                                    <td>LsstId</td>
                                    <td>Status</td>
                                    <td>Site</td>
                                    <td>Location</td>
                                </tr>
                                <tr>
                                    <td>${ccd.lsstId}</td>
                                    <td>${ccd.status}</td>
                                    <td>${ccd.site}</td>
                                    <td>${ccd.location}</td>
                                </tr>
                            </table>

                        </c:if>
                    </c:forEach>
                </section>

                <display:table name="${hdwData.rows}" class="datatable"/> 


                <section>

                    <sql:query var="activityQuery">
                        SELECT A.id, H.lsstId, concat(P.name,'') as process, A.processId, A.inNCR,
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

                    <h2>Travelers</h2>

                    <table style="width:50%">
                        <tr>
                            <td>LsstId</td>
                            <td>Name</td>
                            <td>Status</td>
                            <td>In NCR</td>
                        </tr>

                        <c:forEach items="${activityQuery.rows}" var="actRow">
                            <sql:query var="tQuery">
                                SELECT * FROM TravelerType 
                                where TravelerType.rootProcessId="${actRow.processId}"
                            </sql:query>
                            <c:if test="${tQuery.rowCount>0}" >
                                <tr>
                                    <td>${actRow.lsstId}</td>
                                    <td>${actRow.Process}</td>
                                    <td>${actRow.Status}</td>
                                    <td>${actRow.inNCR}</td>
                                </tr>
                            </c:if>
                        </c:forEach>
                    </table>

                    <h2>All Processes</h2>
                    <%-- <display:table name="${activityQuery.rows}" export="true" class="datatable"/> --%>

                    <display:table name="${activityQuery.rows}" export="true" class="datatable" id="processes"> 
                        <display:column title="LsstId" sortable="true"> <c:out value="${processes.lsstId}"/> </display:column> 
                        <display:column title="Process" sortable="true"> <c:out value="${processes.Process}"/> </display:column> 
                        <display:column title="Version" sortable="true"> <c:out value="${processes.version}"/> </display:column> 
                        <display:column title="Status" sortable="true"> <c:out value="${processes.Status}"/> </display:column> 
                        <display:column title="Start Time" sortable="true"> <c:out value="${processes.begin}"/> </display:column>
                        <display:column title="End Time" sortable="true"> <c:out value="${processes.end}"/> </display:column>
                        <display:column title="inNCR" sortable="true"> <c:out value="${processes.inNCR}"/> </display:column>
                    </display:table>

                </section>

                <h2>Output Files</h2>
                <c:forEach items="${activityQuery.rows}" var="actRow">
                    <sql:query var="outQuery">
                        SELECT creationTS, virtualPath, value from FilepathResultHarnessed 
                        where ${actRow.id}=FilepathResultHarnessed.activityId ORDER BY creationTS
                    </sql:query>
                    <c:if test="${outQuery.rowCount>0}" >
                        <display:table name="${outQuery.rows}" export="true" class="datatable"/> 
                    </c:if>
                </c:forEach>
            </c:otherwise>
        </c:choose>



    </body>
</html>
