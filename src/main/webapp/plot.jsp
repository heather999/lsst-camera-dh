<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="aida" uri="http://aida.freehep.org/jsp20" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<html>

    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>PlotMain</title>
    </head>
    <body>


        <%
            hep.aida.IAnalysisFactory af = hep.aida.IAnalysisFactory.create();
            hep.aida.IHistogramFactory hf = af.createHistogramFactory(null);
            hep.aida.IHistogram1D h = hf.createHistogram1D("test", 50,-10, 10);
            
            java.util.Random r = new java.util.Random();
            
            for ( int i = 0; i < 1000; i++ ) {
                h.fill(r.nextGaussian());                
            }
            
            pageContext.setAttribute("somePlot", h);

            %>
        <aida:plotter width="600" height="400"
                      allowDownload="true" createImageMap="false">
            <aida:region var="region"
                         title="Some Title" >
                <aida:style>
                    <aida:style
                        type="statisticsBox">
                    </aida:style>
                    <aida:style type="data">
                        <aida:style type="fill">
                            <aida:attribute name="isVisible" value="false"/>
                            <aida:attribute name="color" value="blue"/>
                        </aida:style>
                        <aida:style type="line">
                            <aida:attribute name="isVisible" value="false"/>
                            <aida:attribute name="color" value="blue"/>
                        </aida:style>
                        <aida:style type="marker">
                            <aida:attribute name="isVisible" value="true"/>
                            <aida:attribute name="color" value="blue"/>
                        </aida:style>
                    </aida:style>
                    <aida:style type="xAxis">
                        <aida:style type="label">
                            <aida:attribute name="bold" value="true"/>
                        </aida:style>
                    </aida:style>
                    <aida:style type="title">
                        <aida:style type="text">
                            <aida:attribute name="bold" value="true"/>
                        </aida:style>
                    </aida:style>
                </aida:style>


                <aida:plot var="somePlot"/>
            </aida:region>
        </aida:plotter>

    </body>
</html>