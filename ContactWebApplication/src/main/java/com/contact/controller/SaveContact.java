package com.contact.controller;

import java.io.IOException;

import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.contact.model.Contact;
import com.contact.DAO.ContactDAO;

//@WebServlet("/ProcessContact")
public class SaveContact extends HttpServlet {

	private ContactDAO dao = new ContactDAO();
	
	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		// read and populate the parameters
		Contact contact = new Contact();
		String userAction = request.getParameter("userAction");
		contact.setFirstName(request.getParameter("firstName"));
		contact.setLastName(request.getParameter("lastName"));
		contact.setAddress(request.getParameter("address"));
		contact.setCompanyName(request.getParameter("companyName"));
		contact.setPhoneNumber(request.getParameter("phoneNumber"));
		contact.setExtension(request.getParameter("extension"));
		contact.setEmail(request.getParameter("email"));
		// addContact(contact, request, response);
		if ("add".equalsIgnoreCase(userAction)) {
			addOrUpdateContact(contact, request, response);
		} else if ("search".equalsIgnoreCase(userAction)) {
			searchContact(contact, request, response);
		} else if ("get".equalsIgnoreCase(userAction)) {
			Integer contactId = Integer.parseInt(request
					.getParameter("contactId"));
			getContact(contactId, request, response);
		} else if ("update".equalsIgnoreCase(userAction)) {
			Integer contactId = Integer.parseInt(request
					.getParameter("contactId"));
			contact.setContactId(contactId);
			addOrUpdateContact(contact, request, response);
		} else if ("remove".equalsIgnoreCase(userAction)) {
			Integer contactId = Integer.parseInt(request
					.getParameter("contactId"));
			contact.setContactId(contactId);
			deleteContact(contact, request, response);
		} else {
			
			RequestDispatcher rd = request.getRequestDispatcher("Contact.jsp");
			rd.forward(request, response);
		}

		

	}
	/**
	 * This method is used to get the contact and redirect to Contact.jsp.
	 * @param contactId
	 * @param request
	 * @param response
	 * @throws IOException
	 * @throws ServletException
	 */
	private void getContact(Integer contactId, HttpServletRequest request,
			HttpServletResponse response) throws IOException, ServletException {
		Contact contact = dao.getContact(contactId);
		request.setAttribute("updContact", contact);
		RequestDispatcher rd = request.getRequestDispatcher("Contact.jsp");
		rd.forward(request, response);
	}
	/**
	 * This method is used to delete the contact and redirect to contact.jsp.
	 * @param contact
	 * @param request
	 * @param response
	 * @throws IOException
	 * @throws ServletException
	 */
	private void deleteContact(Contact contact, HttpServletRequest request,
			HttpServletResponse response) throws IOException, ServletException {
		dao.deleteContact(contact.getContactId());
		request.setAttribute("actionMsg", " Deleted the following contact"
				+ contact.getLastName() + ", " + contact.getFirstName());
		RequestDispatcher rd = request.getRequestDispatcher("Contact.jsp");
		rd.forward(request, response);
	}
	/**
	 * This method is used to Search the Contact from the database.
	 * @param contact
	 * @param request
	 * @param response
	 * @throws IOException
	 * @throws ServletException
	 */
	private void searchContact(Contact contact, HttpServletRequest request,
			HttpServletResponse response) throws IOException, ServletException {

		// Pass the user passed contact information for search and get the list
		// of matching contacts
		List<Contact> contactList = dao.searchContact(contact);
		// Once we have the list of contacts based on the search we need to pass
		// this to the results page
		request.setAttribute("contactList", contactList);
		RequestDispatcher rd = request.getRequestDispatcher("Contact.jsp");
		rd.forward(request, response);
	}
	/**
	 * This method is used to add or update contact.
	 * @param contact
	 * @param request
	 * @param response
	 * @throws ServletException
	 * @throws IOException
	 */
	public void addOrUpdateContact(Contact contact, HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		boolean result = saveContact(contact);
		if (result == true) {

			request.setAttribute("actionMsg", "Successfully persisted contact "
					+ contact.getLastName() + ", " + contact.getFirstName());
			RequestDispatcher rd = request.getRequestDispatcher("Contact.jsp");
			rd.forward(request, response);

		} else {
			response.getWriter()
					.write("<h1>Error occurred, sorry we could not process the contact</h1>");

		}
	}
	/**
	 * Used to save the contact
	 * @param contact
	 * @return
	 */
	private boolean saveContact(Contact contact) {
		

		return dao.saveContact(contact);

	}

}
