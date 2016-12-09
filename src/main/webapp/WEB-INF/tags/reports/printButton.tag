<%-- 
    Document   : printButton
    Created on : Dec 8, 2016, 5:25:45 PM
    Author     : tonyj
--%>

<%@tag description="Add a print button to a report" pageEncoding="UTF-8"%>

<%-- The list of normal or fragment attributes can be specified here: --%>
<%@attribute name="message"%>

<input type="submit" value="${empty message ? 'Print Report' : message}" onClick="window.print()" id="PrintButton"/> 
