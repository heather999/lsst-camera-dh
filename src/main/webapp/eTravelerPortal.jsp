<%-- 
    Document   : eTravelerPortal
    Created on : May 14, 2015, 5:12:21 PM
    Author     : heather
--%>
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="display" uri="http://displaytag.sf.net" %>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>
<%@page import="java.util.ArrayList" %>


    <head>
        <title>eTraveler Portal</title>
    </head>
     
        <h1>eTraveler Portal</h1>


        <form method=POST action="http://lsst-camera.slac.stanford.edu/eTraveler/exp/LSST-CAMERA/selectHardwareType.jsp?target=registerHardware.jsp">
            <input type="submit" value="Register CCD">
        </form>

        
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

        Request parameters : ${param}<br>
        Selected LSST Id: ${selectedLsstId}<br>

        <%-- Selected HdwType: ${ccdHdwTypeId} --%>

        <%-- List of CCD ids --%>
        <%--
        <c:set var="lsstIdQuery" value="${portal:getComponentIds(pageContext.session, ccdHdwTypeId)}" scope="page"/>
        --%>

        <%-- Retrieve full list of current hardware status and location for all CCDs --%>
        <%-- This function has been updated - need to fix this call --%>
        <%--
        <c:set var="hdwStatLocTable" value="${portal:getHdwStatLocTable(pageContext.session,ccdHdwTypeId)}" scope="page"/>
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
                    
                    <section>
                        <h2>All Possible Travelers</h2>
                        <%-- Retrieve HardwareTypeId for this CCD and use it to find all possible groups --%>
                        
                        
                        
                    </section>
            </c:otherwise>
        </c:choose>


        <br>
        <br>
        <br>
        <br>
        <br>
        <br>
        <br>
        <br>
        <a href="http://lsst-camera.slac.stanford.edu/eTraveler/exp/LSST-CAMERA/welcome.jsp" title "eTraveler Front End" style=""><strong>Go To eTraveler Front End</strong></a>

    

