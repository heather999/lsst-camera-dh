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
        <div id="rawdata" style="width:600px;height:250px;"></div>
        <div id="test1" style="width:600px;height:250px;"></div>
        <div id="test2" style="width:600px;height:250px;"></div>
        <div id="testJspVar" style="width:600px;height:250px;"></div>

       <c:set var="tempPlot" value="${plotutils:getSensorArrival('ITL-CCD',appVariables.dataSourceMode)}"/>


        <script type="text/javascript">
            TESTER = document.getElementById('rawdata');
            Plotly.plot(TESTER, [{
                    x: [1, 2, 3, 4, 5],
                    y: [1, 2, 4, 8, 16]}], {
                margin: {t: 0}});

            var tempPlot = ${tempPlot};
 

            var trace1 = {
                x: [1, 2, 3, 4],
                y: [10, 15, 13, 17],
                type: 'scatter'
            };

            var trace2 = {
                x: [1, 2, 3, 4],
                y: [16, 5, 11, 9],
                type: 'scatter'
            };

            var data = [trace1, trace2];

            Plotly.newPlot('test1', data);
            
            TESTER2 = document.getElementById("testJspVar");
            Plotly.newPlot(TESTER2, tempPlot);
            
        </script>


<% String hmk = (String)pageContext.getAttribute("tempPlot"); %> 


  
        figure = JSON.parse("${tempPlot}");
        
        
    <script>  
        var resp = ${tempPlot};
        Plotly.newPlot('testJspVar', figure.data.map(), figure.layout);
    </script>
 

</body>
</html>

