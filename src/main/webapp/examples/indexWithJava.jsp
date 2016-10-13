<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="display" uri="http://displaytag.sf.net" %>
<%@taglib prefix="portal" uri="http://camera.lsst.org/portal" %>

<html>
    <head>
        <title>Home</title>
    </head>
    <body> 
        <h1>QUERY in Java</h1>

      
        
        <c:if test="${empty selectedHdwTypeId}">
            <c:set var="selectedHdwTypeId" value="1" scope="session"/>            
        </c:if>


        <c:if test="${! empty param.hdwTypeValue}">
            <c:set var="selectedHdwTypeId" value="${param.hdwTypeValue}" scope="session"/>
        </c:if>

        
        <c:set var="hdwTypeQuery" value="${portal:getHardwareTypes(pageContext.session)}"/>
        
        
        <form name="hwdTypeSelection">
            <select name="hdwTypeValue">
                <c:forEach items="${hdwTypeQuery}" var="hdwRow" >
                    <option value="${hdwRow.key}" <c:if test="${hdwRow.key == selectedHdwTypeId}">selected</c:if>  >${hdwRow.value}</option>
                </c:forEach>
            </select>
            <input type="submit" name="hdwTypeSelection"/>
        </form>

        <c:choose>
            <c:when test="${empty selectedHdwTypeId}">
                Please select a Hardware Type from the above drop down menu.
            </c:when>
            <c:otherwise>

                <sql:query var="processQuery">
                    select  Process.name,Process.version  from Process,HardwareType,TravelerType where Process.hardwareTypeId=HardwareType.id and HardwareType.id=? and Process.id=TravelerType.rootProcessId order by Process.name;                
                    <sql:param value="${selectedHdwTypeId}"/>
                </sql:query>
               
                <c:set var="travelerStatusTable" value="${portal:getTravelerStatusTable(pageContext.session,selectedHdwTypeId)}"/>

                <display:table name="${travelerStatusTable}" export="true" class="datatable" id="tst" >
                        <display:column title="Serial #" >${tst.serialNumber}</display:column>
                        <c:forEach items="${processQuery.rows}" var="process">
                            <display:column title="${process.name} (${process.version})" >
                                <c:set var="travelerUniqueName" value="${process.name}_${process.version}"/>
                                ${portal:getTravelerStatus(tst,travelerUniqueName)}
                            </display:column>                            
                        </c:forEach>                    
                </display:table>

            </c:otherwise>
        </c:choose>
    </body>
</html>
