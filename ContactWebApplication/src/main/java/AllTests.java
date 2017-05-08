import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.contact.DAO.ContactDAO;
import com.contact.model.Contact;

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;


public class AllTests extends TestCase {
	
	public void testAdd(){
		Contact contact=new Contact();
		ContactDAO dao=new ContactDAO();
		contact.setFirstName("junitfirst");
		contact.setCompanyName("efolder");
		
		
		assertTrue(dao.saveContact(contact));
	}
	public void testSearch(){
		Contact contact=new Contact();
		ContactDAO dao=new ContactDAO();
		contact.setFirstName("junitfirst");
		contact.setCompanyName("efolder");
		List<Contact> contactList =new ArrayList<Contact>();
		contactList.add(contact);
		assertEquals(dao.searchContact(contact),contactList );
	}
	
	protected void setUp() throws Exception{
		
	}
	protected void tearDown() throws Exception{
		
	}
	
public static void main(String args[]) throws Exception{
	junit.textui.TestRunner.run(new TestSuite(AllTests.class));
}
}
