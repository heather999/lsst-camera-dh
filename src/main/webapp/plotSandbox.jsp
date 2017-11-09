<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="plotutils" uri="http://camera.lsst.org/plotutils"%>

<html>
    <head>
        <title>Test Plot</title>
        <script src="js/plotly-1.30.1-min.js" type="text/javascript"></script>


    </head>

    <body>
        
        <div id="testJspVar" style="width:600px;height:250px;"></div>
        <div id="badJspVar" style="width:600px;height:250px;"></div>


       <c:set var="tempPlot" value="${plotutils:getSensorArrival('ITL-CCD',appVariables.dataSourceMode)}"/>

    <script>  
        var resp = ${tempPlot};
        var respData = [resp.data];
        Plotly.newPlot('testJspVar', respData, resp.layout);
    </script>
    
    
        <c:set var="badPlot" value="${plotutils:getBadChannels('LCA-11021_RTM',appVariables.dataSourceMode)}"/>
  <script>  
        var resp2 = ${badPlot};
        var respData2 = resp2.data;
        Plotly.newPlot('badJspVar', respData2, resp2.layout);
    </script>

</body>
</html>

