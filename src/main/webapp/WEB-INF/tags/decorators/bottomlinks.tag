<%@tag description="header decorator" pageEncoding="UTF-8"%>
<%@taglib prefix="srs_utils" uri="http://srs.slac.stanford.edu/utils" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<table>
    <tr valign="bottom" align="right">
        <td align="right" valign="bottom">
            Mode: <srs_utils:modeChooser mode="dataSourceMode"/>
        </td>
    </tr>
    <tr valign="bottom" align="right">
        <td align="right" valign="bottom">
            <srs_utils:conditonalLink name="Portal Home" url="index.jsp" iswelcome="true"/> |
            <%--
            <srs_utils:conditonalLink name="Java" url="indexWithJava.jsp" /> |
            <srs_utils:conditonalLink name="Plots" url="plot.jsp" />
            --%>
        </td>
    </tr>
</table>