<!--.........................................................................
: DESCRIPTION:
:   - Intermediate JavaScript page between calling form to MdfTree.jsp page.
:   - The purpose of this JavaScript page is to retrieve MDF IDs and
:     MDF Names from the calling form and save them to this form.
:     Once the data from calling form is saved into this form, this form
:     gets submitted to MDF Navigator page.
:   - This approach is invented to pass the large volume of associated
:     MDF information from the calling form (i.e., Create Metadata page
:     for CNA) to the MDF Navigator page.
:   - This form will be submitted to MdfTreePost.jsp.
:
: AUTHORS:
: @author Nadia Lee (nadialee@cisco.com)
:
: WRITTEN WHEN:
: October 2005.
:
: Copyright (c) 2005 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<html>
<body>

<%

    final  String THIS_FILE = "[MdfTreeJavaScript.jsp] ";

    String dispFname;
    String dispEname;
    String dispEtype;
    String hiddenFname;
    String hiddenMdfIdEName;
    String hiddenMdfNameEname;
    String swType;
    String mdfIds;
    String mdfNames;

    //-------------------------------------------------------------
    // Values coming as URL parameters
    //  - dispFname           Ex: 'createMetaForm'
    //  - dispEname           ex: 'mdfDiv'
    //  - dispEtype           ex: valid values: 'div', 'textarea'
    //  - hiddenFname         ex: 'hiddenMdfForm'
    //  - hiddenMdfIdEName    ex: 'hiddenMdfId'
    //  - hiddenMdfNameEname  ex: 'hiddenMdfName'
    //  - swType              ex: 'VxWorks'
    //-------------------------------------------------------------
    dispFname           = request.getParameter("dispFname");
    dispEname           = request.getParameter("dispEname");
    dispEtype           = request.getParameter("dispEtype");
    hiddenFname         = request.getParameter("hiddenFname");
    hiddenMdfIdEName    = request.getParameter("hiddenMdfIdEName");
    hiddenMdfNameEname  = request.getParameter("hiddenMdfNameEname");
    swType              = request.getParameter("swType");

    //--------------------------------------------------------------------
    // - mdfIds and mdfNames: have $-delimited MDF IDs and MDF names respectively.
    // - Retrieve these values from the calling form.
    //--------------------------------------------------------------------
//    mdfIds         = request.getParameter("hiddenMdfId");
//    mdfNames       = request.getParameter("hiddenMdfName");


    mdfIds         = request.getParameter(hiddenMdfIdEName);
    mdfNames       = request.getParameter(hiddenMdfNameEname);

/*
    System.out.println( THIS_FILE + "DEBUG 0.\n" +
        "dispFname=" + dispFname +
        ", dispEname=" + dispEname +
        ", dispEtype=" + dispEtype +
        ", hiddenFname=" + hiddenFname +
        ", hiddenMdfIdEName=" + hiddenMdfIdEName +
        ", hiddenMdfNameEname=" + hiddenMdfNameEname +
        ", swType=" + swType + "\n");

    System.out.println( THIS_FILE + "DEBUG 1. mdfIds  =" + mdfIds );
    System.out.println( THIS_FILE + "DEBUG 2. mdfNames=" + mdfNames );
*/

%>

<form name="MdfTreeJavaScriptForm" action="MdfTreePost.jsp" method="post">

<input type="hidden" name="dispFname"           value="<%=dispFname%>">
<input type="hidden" name="dispEname"           value="<%=dispEname%>">
<input type="hidden" name="dispEtype"           value="<%=dispEtype%>">
<input type="hidden" name="hiddenFname"         value="<%=hiddenFname%>">
<input type="hidden" name="hiddenMdfIdEName"    value="<%=hiddenMdfIdEName%>">
<input type="hidden" name="hiddenMdfNameEname"  value="<%=hiddenMdfNameEname%>">
<input type="hidden" name="swType"              value="<%=swType%>">
<input type="hidden" name="hiddenMdfId"         value="<%=mdfIds%>">
<input type="hidden" name="hiddenMdfName"       value="<%=mdfNames%>">


<input type="hidden" name="removescr" value="removeyyy">

</form>

<script type="text/javascript">

    var THIS_FUNC = "[MdfTreeJavaScriptForm.jsp script] ";

    //--------------------------------------------------------------------
    // Values coming as URL parameters and already saved to Input box
    // on this local form.
    //  - hiddenFname
    //  - hiddenMdfIdEName
    //  - hiddenMdfNameEname
    //  - swType
    //--------------------------------------------------------------------
    var mHiddenFname = document.forms['MdfTreeJavaScriptForm'].elements['hiddenFname'].value;

    var mHiddenMdfIdEName =
            document.forms['MdfTreeJavaScriptForm'].elements['hiddenMdfIdEName'].value;

    var mHiddenMdfNameEName =
            document.forms['MdfTreeJavaScriptForm'].elements['hiddenMdfNameEname'].value;

    //--------------------------------------------------------------------
    // - Retrieve $-delimited MDF IDs and $-delimited MDF names from
    //   the calling form, and save them in this local form
    //   ===> input objects: 'hiddenMdfId' and 'hiddenMdfName'.
    //--------------------------------------------------------------------
    var pMdfIdObj   = window.opener.document.forms[mHiddenFname].elements[mHiddenMdfIdEName];

    var pMdfNameObj = window.opener.document.forms[mHiddenFname].elements[mHiddenMdfNameEName];

    var pMdfIdVal   = pMdfIdObj.value;
    var pMdfNameVal = pMdfNameObj.value;

    document.forms['MdfTreeJavaScriptForm'].elements['hiddenMdfId'].value    = pMdfIdVal;
    document.forms['MdfTreeJavaScriptForm'].elements['hiddenMdfName'].value  = pMdfNameVal;

/*
    alert( "[MdfTreeJavaScript.jsp] DEBUG 90a\n" +
           "mHiddenFname=" + mHiddenFname + "\n" +
           "mHiddenMdfIdEName=" + mHiddenMdfIdEName + "\n" +
           "mHiddenMdfNameEName=" + mHiddenMdfNameEName);

    alert( "[MdfTreeJavaScript.jsp] DEBUG 90b\n" +
           "hiddenMdfId.value=" + pMdfIdVal + "\n" + "hiddenMdfName=" + pMdfNameVal);
*/
    //--------------------------------------------------------------------
    // Submit the form with POST method.
    //--------------------------------------------------------------------
    document.forms['MdfTreeJavaScriptForm'].submit();

</script>

</body>
</html>
