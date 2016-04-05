<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>
<%@taglib prefix="etraveler" tagdir="/WEB-INF/tags/eTrav"%>
<%@taglib prefix="filter" uri="http://srs.slac.stanford.edu/filter"%>

<html>
    <head>
        <title>CCD Explorer</title>
    </head>
    <body> 
        <h1>CCD Explorer</h1>

        <c:set var="ccdManuString" value="${portal:getCCDHardwareTypes(pageContext.session)}"/>
        <sql:query var="manuQ">
            SELECT DISTINCT manufacturer FROM Hardware, HardwareType where Hardware.hardwareTypeId=HardwareType.id AND HardwareType.id IN ${ccdManuString} ORDER BY manufacturer;
        </sql:query>


    <filter:filterTable>
        <filter:filterInput var="lsst_num" title="LSST_NUM (substring search)"/>
        <filter:filterSelection title="Manufacturer" var="manu" defaultValue="any">
            <filter:filterOption value="any">Any</filter:filterOption>
                <c:forEach var="hdw" items="${manuQ.rows}">
                <filter:filterOption value="${hdw.manufacturer}"><c:out value="${hdw.manufacturer}"/></filter:filterOption>
                </c:forEach>
        </filter:filterSelection>
    </filter:filterTable>
    
        <%-- Select CCD as the HardwareType for this page, scope session means all the pages? set scope to page --%>
        <c:set var="ccdHdwTypeId" value="1" scope="page"/>   

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
        <c:set var="lsstIdQuery" value="${portal:getFilteredComponentIds(pageContext.session, ccdHdwTypeId, lsst_num, manu)}"/>

        <%-- Retrieve full list of current hardware status and location for all CCDs --%>
        <%--
        <c:set var="hdwStatLocTable" value="${portal:getHdwStatLocTable(pageContext.session,ccdHdwTypeId)}"/>
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
                Please select a LSST_NUM from the above drop down menu. 
            </c:when>
            <c:otherwise>

                <%-- Extract useful info from Hardware table --%>
                <c:set var="hdwTypeStr" value="${portal:getCCDHardwareTypes(pageContext.session)}" scope="page"/>
                <sql:query  var="hdwData" scope="page" >
                    select  Hardware.id,Hardware.manufacturer,Hardware.model, Hardware.manufactureDate from Hardware where Hardware.lsstId=? and Hardware.hardwareTypeId IN ${hdwTypeStr}
                    <sql:param value="${selectedLsstId}"/>
                </sql:query>

                <c:set var="curHdwData" value="${hdwData.rows[0]}"/>
                <c:set var="vendor" value="${curHdwData.manufacturer}"/>

                <section>
                    <%-- Retrieve full list of current hardware status and location this CCD --%>
                    <c:set var="hdwStatLoc" value="${portal:getHdwStatLoc(pageContext.session,selectedLsstId)}" scope="page"/>

                    <display:table name="${hdwStatLoc}" class="datatable" id="hdl" >
                        <display:column title="LSST_NUM" sortable="true" >${hdl.lsstId}</display:column>
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
                    <display:table name="${hdwData.rows}" class="datatable" id="hdw"> 
                        <display:column title="Manufacture Date"> <c:out value="${hdw.manufactureDate}"/> </display:column> 
                        <display:column title="Manufacturer"> <c:out value="${hdw.manufacturer}"/> </display:column> 
                        <display:column title="Model"> <c:out value="${hdw.model}"/> </display:column> 
                    </display:table>       
                </section>


                <section>


                    <%-- <c:forEach var="row" items="${hdwData.rows}" begin = "0" end="0" > --%>
                    <c:set var="hdwId" value="${curHdwData.id}" scope="page"/> 


                    <div id=""theFold"/>
                         <table>
                            <tr>
                                <td style="vertical-align:top;">
                                    <h2>Summary of Traveler Status</h2>
                            <etraveler:activityList travelersOnly="true" hardwareId="${hdwId}"/>
                            </td>
                            <td style="vertical-align:top">
                                <c:url var="actResults" value="actResults.jsp">
                                    <c:param name="hdwId" value="${curHdwData.id}"/>
                                    <c:param name="lsstId" value="${selectedLsstId}"/>
                                    <c:param name="vendor" value="${vendor}"/>
                                </c:url>
                                <iframe name="content" src="${actResults}" width="800" height="4000"></iframe>
                            </td>
                            </tr>
                        </table>

                        <br>


                        </section>


                    </c:otherwise>
                </c:choose>



                </body>
                </html>
