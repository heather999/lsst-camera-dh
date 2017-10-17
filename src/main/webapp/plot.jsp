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
        <script src="js/plotly-1.30.1-min.js"></script>

    </head>

    <body>
        <div id="rawdata" style="width:600px;height:250px;"></div>
        <div id="test1" style="width:600px;height:250px;"></div>
        <div id="test2" style="width:600px;height:250px;"></div>
        
        <c:set var="tempPlot2" value="${plotutils:getSensorArrival('ITL-CCD',appVariables.dataSourceMode)}"/>

        <script>
             var resp = ${tempPlot2};
             var myfig = JSON.parse(resp);
        Plotly.newPlot('rawdata', myfig.data, myfig.layout);
            
            TESTER = document.getElementById('test1';
            Plotly.plot(TESTER, [{
                    x: [1, 2, 3, 4, 5],
                    y: [1, 2, 4, 8, 16]}], {
                margin: {t: 0}});


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

            Plotly.newPlot('test2', data);
        </script>


</body>
</html>
