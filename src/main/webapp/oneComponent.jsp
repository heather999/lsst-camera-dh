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


        <c:if test="${empty selectedLsstId}">
            <c:set var="selectedLsstId" value="" scope="page"/>            
        </c:if>


        
        <c:if test="${! empty param.lsstIdValue}">
            <c:set var="selectedLsstId" value="${param.lsstIdValue}" scope="page"/>
        </c:if>

        Request parameters : ${param}<br>
        Selected LSST Id: ${selectedLsstId}<br>

        Selected HdwType: ${ccdHdwTypeId}
        
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
                    <option value="${hdwRow.value}">${hdwRow.value}</option>
                </c:forEach>
            </select>
            <input type="submit" name="ccdSelection"/>
        </form>



        <c:choose>
            <c:when test="${empty selectedLsstId}">
                Please select a LSST Id from the above drop down menu.
            </c:when>
            <c:otherwise>
                <%-- Extract useful info from Hardware table --%>
                <sql:query  var="hdwData"  >
                    select  Hardware.manufacturer,Hardware.model, Hardware.manufactureDate, Hardware.creationTS from Hardware where Hardware.lsstId=? and Hardware.hardwareTypeId=? 
                    <sql:param value="${selectedLsstId}"/>
                    <sql:param value="${ccdHdwTypeId}"/>
                </sql:query>
               
                <section>
                    <%-- searches list of CCDs to locate the status/loc record for this lsstId --%>
                    <c:forEach items="${hdwStatLocTable}" var="ccd">
                        <c:if test="${ccd.lsstId == selectedLsstId}">

                            <table style="width:50%">
                                <caption><b>Current Status and Location</b></caption>
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

            </c:otherwise>
        </c:choose>



    </body>
</html>
