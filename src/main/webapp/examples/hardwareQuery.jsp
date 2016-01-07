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
        <title>Home</title>
    </head>
    <body> 
        <h1>QUERY</h1>
        
        
        
              
        
        
        <c:if test="${empty selectedHdwTypeId}">
            <c:set var="selectedHdwTypeId" value="1" scope="session"/>            
        </c:if>


        <c:if test="${! empty param.hdwTypeValue}">
            <c:set var="selectedHdwTypeId" value="${param.hdwTypeValue}" scope="session"/>
        </c:if>

        Request parameters : ${param}<br>
        Selected Hardware Type Id: ${selectedHdwTypeId}

        <sql:query var="hdwTypeQuery"  >
            select  * from HardwareType
        </sql:query>


        <form name="hwdTypeSelection">
            <select name="hdwTypeValue">
                <c:forEach items="${hdwTypeQuery.rows}" var="hdwRow" >
                    <option value="${hdwRow.id}" <c:if test="${hdwRow.id == selectedHdwTypeId}">selected</c:if>  >${hdwRow.name}</option>
                </c:forEach>
            </select>
            <input type="submit" name="hdwTypeSelection"/>
        </form>



        <c:choose>
            <c:when test="${empty selectedHdwTypeId}">
                Please select a Hardware Type from the above drop down menu.
            </c:when>
            <c:otherwise>

                <sql:query  var="tests"  >
                    select  Hardware.id,Hardware.lsstId from Hardware,HardwareType where Hardware.hardwareTypeId=HardwareType.id and HardwareType.id=?
                    <sql:param value="${selectedHdwTypeId}"/>
                </sql:query>

                <%-- For each example to loop over query
            Number of selected items: ${tests.rowCount}</br>

        <c:forEach items="${tests.rows}" var="row">
            ${row}</br>
        </c:forEach>
                --%>
                
                
                
                

                <h3>Hardware Ids</h3>
                <display:table name="${tests.rows}" export="true" class="datatable"/>


                <h3>Process Travelers</h3>
                <sql:query var="processQuery">
                    select  Process.name,Process.version  from Process,HardwareType,TravelerType where Process.hardwareTypeId=HardwareType.id and HardwareType.id=? and Process.id=TravelerType.rootProcessId order by Process.name;                
                    <sql:param value="${selectedHdwTypeId}"/>
                </sql:query>

                    <display:table name="${tests.rows}" export="true" class="datatable" id="mainTable">
                        <%--
<display:caption>
<thead>
                        <tr align="center">
                        <td></td>
                        <td align="center" colspan="${processQuery.rowCount}"><b>Process Traveler</b></td>
                    </tr>
</thead>

</display:caption>
                        --%>
                        <display:column title="Serial #" >${mainTable.lsstId}</display:column>
                        <c:forEach items="${processQuery.rows}" var="process">
                            <display:column title="${process.name} (${process.version})" >?</display:column>                            
                        </c:forEach>
                    </display:table>

                <h3>Hardware Activity</h3>
                <sql:query var="activityQuery">
                    select  Hardware.lsstId, Process.name,Process.version,Activity.begin,Activity.end,activityFinalStatusId from Activity,TravelerType,Process,Hardware where Activity.processId=TravelerType.id and Process.id=TravelerType.rootProcessId and Hardware.id=Activity.hardwareId and Hardware.hardwareTypeId=?;
                    <sql:param value="${selectedHdwTypeId}"/>
                </sql:query>

                <display:table name="${activityQuery.rows}" export="true" class="datatable"/>

            </c:otherwise>
        </c:choose>




    </body>
</html>
