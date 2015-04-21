<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="display" uri="http://displaytag.sf.net" %>

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
        Selected LSST Id: ${selectedLsstId}

        <sql:query var="lsstIdQuery"  >
            select  * from Hardware
        </sql:query>


        <form name="ccdSelection">
            <select name="ccdValue">
                <c:forEach items="${lsstIdQuery.rows}" var="hdwRow" >
                    <option value="${hdwRow.lsstId}" <c:if test="${hdwRow.hardwareTypeId == ccdHdwTypeId}">selected</c:if>  >${hdwRow.lsstId}</option>
                </c:forEach>
            </select>
            <input type="submit" name="ccdSelection"/>
        </form>



        <c:choose>
            <c:when test="${empty selectedLsstId}">
                Please select a LSST Id from the above drop down menu.
            </c:when>
            <c:otherwise>

                

            </c:otherwise>
        </c:choose>




    </body>
</html>
