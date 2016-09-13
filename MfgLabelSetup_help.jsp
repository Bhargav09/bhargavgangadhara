<!--.........................................................................
: DESCRIPTION:
: OPUS Submission
:
: AUTHORS:
: @author Vellachi (vpalani@cisco.com)
: @author Raju Ruddaraju (rruddara@cisco.com)
:
: Copyright (c) 2004 by Cisco Systems, Inc.
: All rights reserved.
:.........................................................................-->

<!--
    WARNING: This example makes use of a dummy form.  Do *not* embed/include
    this help file inside another form otherwise your browsers may get very
    confused!
-->

      <form name="__no_name">
      <font class="help_title">
	Instructions:
      </font>
      <font class="help_contents">
        This restricts the part numbers users can enter.
	Specify valid part number prefixes for each label.
	You can specify one or more numbers <b>separated by
	commas</b>.  e.g.<br /><br />

        <blockquote>
	  <input type="text" width="15" name="example" value="57, 79"
	      onclick="alert('This is just an example.');this.blur();" />
        </blockquote>

	All part numbers users enter must begin with one of those numbers:
	<br /><br />

        <blockquote>
          <table border="0" cellpadding="0" cellspacing="0">
          <tr>
            <td align="left">
  	      <input type="text" width="15" name="example"
  	          onclick="alert('This is just an example.');this.blur();"
  	          value="57-1242-83" />
	    </td>
	    <td>&nbsp;&nbsp;&nbsp;</td>
            <td align="left">
	      <font color="#00a000"><b>OK</b></font>
	    </td>
	  </tr>
          <tr>
            <td align="left">
  	      <input type="text" width="15" name="example"
	          onclick="alert('This is just an example.');this.blur();"
  	          value="79-3464-17" />
	    </td>
	    <td></td>
            <td align="left">
	      <font color="#00a000"><b>OK</b></font>
	    </td>
	  </tr>
          <tr>
            <td align="left">
  	      <input type="text" width="15" name="example"
  	          value="85-2738-52" />
	    </td>
	    <td></td>
            <td align="left">
	      <font color="#ff0000"><b>Invalid</b></font>
	    </td>
	  </tr>
	  </table>
        </blockquote>

        Leaving the field <b>blank</b> will allow users to enter any part
        number.
      </font>
      </form>

<!-- end -->
