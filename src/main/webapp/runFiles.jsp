<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="file" uri="http://portal.lsst.org/fileutils" %>
<%@taglib uri="http://srs.slac.stanford.edu/filter" prefix="filter"%>

<%-- 
    Document   : runFiles
    Created on : Sep 16, 2016, 2:14:32 PM
    Author     : tonyj
--%>

<html>
    <head>
        <title>Files for run ${param.run}</title>
        <script language="JavaScript" type="text/javascript">
            function ShowAll(set) {
                for (var i = 0; i < document.selectForm.elements.length; i++) {
                    if (document.selectForm.elements[i].type === 'checkbox') {
                        document.selectForm.elements[i].checked = set;
                    }
                }
                CountSelected();
            }
            function ToggleAll() {
                for (var i = 0; i < document.selectForm.elements.length; i++) {
                    if (document.selectForm.elements[i].type === 'checkbox') {
                        document.selectForm.elements[i].checked = !(document.selectForm.elements[i].checked);
                    }
                }
                CountSelected();
            }
            function CountSelected() {
                count = 0;
                for (var i = 0; i < document.selectForm.elements.length; i++) {
                    if (document.selectForm.elements[i].type === 'checkbox') {
                        count += (document.selectForm.elements[i].checked) ? 1 : 0;
                    }
                }
                for (var i = 0; i < document.selectForm.elements.length; i++) {
                    if (document.selectForm.elements[i].type === 'submit') {
                        document.selectForm.elements[i].disabled = (count === 0);
                    }
                }
            }
        </script>
        <style>
            table.datatable td.admin { background-color: pink; padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px; }

            #taglist {
                padding: 0;
                display: inline;
                list-style: none;
            }

            #taglist li {
                display: inline;
            }

            #taglist li + li:before {
                content: ", ";
            }

            #myImg {
                border-radius: 5px;
                cursor: pointer;
                transition: 0.3s;
            }

            #myImg:hover {opacity: 0.7;}

            /* The Modal (background) */
            .modal {
                display: none; /* Hidden by default */
                position: fixed; /* Stay in place */
                z-index: 1; /* Sit on top */
                padding-top: 100px; /* Location of the box */
                left: 0;
                top: 0;
                width: 100%; /* Full width */
                height: 100%; /* Full height */
                overflow: auto; /* Enable scroll if needed */
                background-color: rgb(0,0,0); /* Fallback color */
                background-color: rgba(0,0,0,0.9); /* Black w/ opacity */
            }

            /* Modal Content (image) */
            .modal-content {
                margin: auto;
                display: block;
                width: 80%;
                max-width: 700px;
            }

            /* Caption of Modal Image */
            #caption {
                margin: auto;
                display: block;
                width: 80%;
                max-width: 700px;
                text-align: center;
                color: #ccc;
                padding: 10px 0;
                height: 150px;
            }

            /* Add Animation */
            .modal-content, #caption {
                -webkit-animation-name: zoom;
                -webkit-animation-duration: 0.6s;
                animation-name: zoom;
                animation-duration: 0.6s;
            }

            @-webkit-keyframes zoom {
                from {-webkit-transform:scale(0)}
                to {-webkit-transform:scale(1)}
            }

            @keyframes zoom {
                from {transform:scale(0)}
                to {transform:scale(1)}
            }

            /* The Close Button */
            .close {
                position: absolute;
                top: 15px;
                right: 35px;
                color: #f1f1f1;
                font-size: 40px;
                font-weight: bold;
                transition: 0.3s;
            }

            .close:hover,
            .close:focus {
                color: #bbb;
                text-decoration: none;
                cursor: pointer;
            }

            /* 100% Image Width on Smaller Screens */
            @media only screen and (max-width: 700px){
                .modal-content {
                    width: 100%;
                }
            }
        </style>
    </head>
    <body>
        <h1>Files for run ${param.run}</h1>
        <fmt:setTimeZone value="UTC"/>

        <!-- The Modal -->
        <div id="myModal" class="modal">
            <span class="close">×</span>
            <img class="modal-content" id="img01">
            <div id="caption"></div>
        </div>


        <filter:filterTable>
            <filter:filterInput title="Path filter" var="filter" size="40"/>
            <filter:filterSelection title="Filter Type" var="filterType">
                <filter:filterOption value="contains">Contains</filter:filterOption>
                <filter:filterOption value="regexp">Regular Expression</filter:filterOption>
            </filter:filterSelection>
            <input type="hidden" name="run" value="${param.run}"/>
        </filter:filterTable>
        <sql:query var="files">
            select f.id,f.virtualPath,f.size,f.catalogKey,f.activityId,f.creationTS from Activity a 
            join FilepathResultHarnessed f on (a.id=f.activityId)
            join RunNumber r on (r.rootActivityId=a.rootActivityId)
            WHERE r.RunNumber=?
            <sql:param value="${param.run}"/>
            <c:if test="${!empty filter}">
                <c:choose>
                    <c:when test="${filterType=='regexp'}">
                        and f.virtualPath regexp ?
                        <sql:param value="${filter}"/>
                    </c:when>
                    <c:otherwise>
                        and f.virtualPath like ?
                        <sql:param value="%${filter}%"/>
                    </c:otherwise>
                </c:choose>
            </c:if>
        </sql:query>

        <c:set var="root" value="${file:commonRoot(file:getColumnFromResult(files,'virtualPath'))}"/>
        <c:url var="datacatURL" value="http://srs.slac.stanford.edu/DataCatalog/">
            <%-- Note, this strips off trailing / (rather uglily) --%>
            <c:param name="folderPath" value="${fn:substring(root,0,fn:length(root)-1)}"/>
            <c:param name="experiment" value="LSST-CAMERA"/>
        </c:url>
        <h2>Root Path: ${root} (<a href="${datacatURL}">View in datacat</a>)</h2>
        To download multiple files use checkboxes on left and controls at bottom of table.
        <form id="downloadForm" name="selectForm"  method="post"  action="downloadFiles.jsp" >
            <display:table name="${files.rows}" sort="list" defaultsort="2" defaultorder="ascending" class="datatable" id="file" >
                <display:column title=" " class="admin">
                    <input type="checkbox" name="datasetToDwnld" value="${file.id}" onclick="CountSelected()" />
                </display:column>
                <display:column sortProperty="virtualPath" title="Path" sortable="true" class="leftAligned">
                    ${file:relativize(root,file.virtualPath)}
                </display:column>
                <display:column sortProperty="created" title="Create Date (UTC)" sortable="true">
                    <fmt:formatDate value="${file.creationTS}" pattern="yyyy-MM-dd HH:mm:ss"/>
                </display:column>
                <display:column sortProperty="size" property="size" title="Size" decorator="org.srs.web.base.decorator.ByteColumnDecorator" sortable="true"/>
                <display:column title="Actions" class="leftAligned">
                    <ul id="taglist">
                        <c:url var="downloadURL" value="http://srs.slac.stanford.edu/DataCatalog/get">
                            <c:param name="dataset" value="${file.catalogKey}"/>
                            <c:param name="experiment" value="LSST-CAMERA"/>
                        </c:url>
                        <li><a href="${downloadURL}">Download</a></li>
                            <c:url var="datacatURL" value="http://srs.slac.stanford.edu/DataCatalog/">
                                <c:param name="dataset" value="${file.catalogKey}"/>
                                <c:param name="experiment" value="LSST-CAMERA"/>
                            </c:url>
                        <li><a href="${datacatURL}">Datacat</a></li>
                            <c:if test="${file:fileTypeIn(file.virtualPath, fn:split('png|jpg|jpeg|gif','|'))}">
                            <li><a onclick="preview('${downloadURL}', '${file:relativize(root,file.virtualPath)}')" href="javascript:void(0);">Preview</a></li>
                            </c:if>
                            <c:if test="${fn:endsWith(file.virtualPath, '.fits')}">
                                <c:url var="previewURL" value="/converter" context="/FitsViewer">
                                    <c:param name="file" value="${downloadURL}"/>
                                </c:url>
                            <li><a onclick="preview('${previewURL}', '${file:relativize(root,file.virtualPath)}')" href="javascript:void(0);">Preview</a></li>
                                <c:url var="headerURL" value="/" context="/FitsViewer">
                                    <c:param name="file" value="${downloadURL}"/>
                                </c:url>
                            <li><a href="${headerURL}">Headers</a></li>
                            </c:if>
                    </ul>
                </display:column>
                <display:footer>
                    <tr>
                        <td colspan="20" class="admin">
                            <a href="javascript:void(0)" onClick="ShowAll(true);">Select all</a>&nbsp;.&nbsp;
                            <a href="javascript:void(0)" onClick="ShowAll(false);">Deselect all</a>&nbsp;.&nbsp;
                            <a href="javascript:void(0)" onClick="ToggleAll();">Toggle selection</a>
                            <input type="submit" name="zip" value="Download selected as .zip" disabled/>
                            <input type="hidden" name="run" value="${param.run}"/>
                            <input type="hidden" name="root" value="${root}"/>
                        </td>
                    </tr>
                </display:footer>
            </display:table>
        </form>
        <script>

            var modal = document.getElementById('myModal');
            var modalImg = document.getElementById("img01");
            var captionText = document.getElementById("caption");

            function preview(url, name) {

                modal.style.display = "block";
                modalImg.src = url;
                captionText.innerHTML = name;
                return false;
            }
            var span = document.getElementsByClassName("close")[0];

            // When the user clicks on <span> (x), close the modal
            span.onclick = function () {
                modal.style.display = "none";
            }
        </script>
    </body>
</html>
