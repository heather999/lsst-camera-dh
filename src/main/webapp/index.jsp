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
        <h1>Sensor Quick Links</h1>
        

         <ul>
                
          
                            
                
                
                
            <li><a href="/DataPortal/ccdStatusWithJava.jsp" title="CCD Status" style=""><strong>Overview All CCDs</strong></a></li>
                
            <li><a href="/DataPortal/oneComponent.jsp" title="CCD Explorer" style=""><strong>CCD Explorer</strong></a></li>
            
            <%-- <li><a href="/DataPortal/eTravelerPortal.jsp" title "eTraveler Portal" style=""><strong>eTraveler Portal</strong></a></li> --%>
            <li> <a href="/DataPortal/reports.jsp" title "Data and Reports" style=""><strong>Data and Reports</strong></a></li>
            
            <li><a href="/DataPortal/activityStatus.jsp" title="Activity Status" style=""><strong>All eTraveler Activity Status</strong></a></li>
           
            </ul>   



    </body>
</html>
