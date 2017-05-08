<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@page import="java.util.List"%>
<%@page import="com.contact.model.Contact"%>
<HTML>
<HEAD>
<TITLE>Contacts Application</TITLE>
<script>
	function setAction(action) {
		document.getElementById("userAction").value = action;
		if(action=='Add'){
		if(validateForm()){
			if(phonenumber()){
				if(validateEmail())
			document.getElementById("contactform").submit();
			}
		}
	}else{
		document.getElementById("contactform").submit();
	}
	}
	function setRecord(id, action) {
		document.getElementById("userAction").value = action;
		document.getElementById("contactId").value = id;
		document.getElementById("contactform").submit();
		
	}
	function validateForm() {
	    var fstNm = document.getElementById("firstName").value;
	    var lstNm = document.getElementById("lastName").value;
	    var cmpNm = document.getElementById("companyName").value;
	    if (cmpNm="") {
	        alert("Please enter the Company Name");
	        return false;
	    }else if (fstNm == "" && lstNm==""){
	    	alert("Please enter atleast first name or last name");
	    	return false;
	    }
	    return true;
	}
	function phonenumber() {
		var num=document.getElementById("phoneNumber").value;
		  var phoneno = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/;
		 
		  if(num.match(phoneno)) {
		    return true;
		  }
		  else {
		    alert("Please enter the correct format of the phone number");
		    return false;
		  
		  }
		}
	function validateEmail() {
	    var x = document.forms["contactform"]["email"].value;
	    var atpos = x.indexOf("@");
	    var dotpos = x.lastIndexOf(".");
	    if (atpos<1 || dotpos<atpos+2 || dotpos+2>=x.length) {
	        alert("Please enter a valid e-mail address");
	        return false;
	    }return true;
	}
</script>
</HEAD>
<BODY BGCOLOR="#FDF5E6">
	<%
		Contact updContact = (Contact) request.getAttribute("updContact");
		boolean isUpdate = updContact == null ? false : true;
	%>

	<%
		String msg = (String) request.getAttribute("actionMsg");
	%>
	<%
		if (msg != null) {
	%>
	</H2><%=msg%></H2>
	<%
		}
	%>
	<H1 ALIGN="CENTER">Please enter the Contact Details</H1>

	<FORM name="contactform" id="contactform" ACTION="ProcessContact" METHOD="POST">
		First Name: <INPUT TYPE="TEXT" id="firstName" NAME="firstName"
			value='<%=isUpdate ? updContact.getFirstName() : ""%>'><BR>
		Last Name: <INPUT TYPE="TEXT" id="lastName" NAME="lastName"
			value='<%=isUpdate ? updContact.getLastName() : ""%>'><BR>
		Company Name: <INPUT TYPE="TEXT" id="companyName" NAME="companyName"
			value='<%=isUpdate ? updContact.getCompanyName() : ""%>'><BR>
		Phone Number: <INPUT TYPE="TEXT" id="phoneNumber" NAME="phoneNumber"
			value='<%=isUpdate ? updContact.getPhoneNumber() : ""%>'><BR>
		Extension: <INPUT TYPE="TEXT" NAME="extension"
			value='<%=isUpdate ? updContact.getExtension() : ""%>'><BR>

		Address:
		<TEXTAREA NAME="address" ROWS=3 COLS=40
			value='<%=isUpdate ? updContact.getAddress() : ""%>'></TEXTAREA>
		<BR> Email Address:<INPUT TYPE="TEXT" NAME="email"
			value='<%=isUpdate ? updContact.getEmail() : ""%>'><BR>
		<BR> <input id="userAction" type="hidden" name="userAction"
			value="" /> <input id="contactId" type="hidden" name="contactId"
			value=<%=isUpdate ? updContact.getContactId() : ""%> /> <INPUT
			TYPE="Button" VALUE="Add Contact" onClick="setAction('Add')"
			<%=isUpdate ? "disabled" : ""%>> <INPUT TYPE="Button"
			VALUE="Update Contact" onClick="setAction('Update')"
			<%=isUpdate ? "" : "disabled"%>> <input type="Button"
			value="Remove Contact" onClick="setAction('Remove')"
			<%=isUpdate ? "" : "disabled"%>> <input type="Button"
			value="Search Contact" onClick="setAction('Search')"
			<%=isUpdate ? "disabled" : ""%>>

	</FORM>

	<!-- Only display search results if there are search results in the request context -->
	<%
		List<Contact> contactList = (List) request
				.getAttribute("contactList");
	%>
	<%
		if (contactList != null) {
	%>
	<table border="1" cellpadding="5">
		            
		<caption>
			<h2>Search Results</h2>
		</caption>
		            
		<tr>
			                
			<th>ID</th>                 
			<th>FirstName</th>
			<th>LastName</th>
			<th>Address</th>                 
			<th>Email</th>
			<th>Extension</th>                 
			<th>PhoneNumber</th>
			<th>CompanyName</th>            
		</tr>
		            
		<%
				for (Contact contact : contactList) {
			%>
		          
		<tr>
			                    
			<td><input type="radio" name="cntRadio"
				onClick="setRecord(<%=contact.getContactId()%>, 'get')"></td>
			                    
			<td><%=contact.getFirstName()%></td>
			<td><%=contact.getLastName()%></td>
			<td><%=contact.getAddress()%></td>                     
			<td><%=contact.getEmail()%></td>                     
			<td><%=contact.getExtension()%></td>
			<td><%=contact.getPhoneNumber()%></td>
			<td><%=contact.getCompanyName()%></td>                 
		</tr>
		<%
			}
		%>
		        
	</table>

	<%
		}
	%>

</BODY>
</HTML>