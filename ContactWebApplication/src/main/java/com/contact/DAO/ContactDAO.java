package com.contact.DAO;

import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import org.hibernate.criterion.Restrictions;
import org.hibernate.service.ServiceRegistry;
import org.hibernate.service.ServiceRegistryBuilder;

import com.contact.model.Contact;

public class ContactDAO {
	/**
	 * Creating Singleton session factory
	 */
	private static SessionFactory sFactory = null;

	private SessionFactory getSessionFactory() {
		if (sFactory == null) {
			sFactory = createSessionFactory();
		}
		return sFactory;
	}
	/**
	 * This method creates Session Factory
	 * @return
	 */
	private static SessionFactory createSessionFactory() {
		Configuration config = new Configuration();
		config.configure();
		config.addAnnotatedClass(Contact.class);
		config.addAnnotatedClass(ContactDAO.class);

		ServiceRegistryBuilder serviceRegistryBuilder = new ServiceRegistryBuilder();
		serviceRegistryBuilder.applySettings(config.getProperties());
		ServiceRegistry serviceRegistry = serviceRegistryBuilder
				.buildServiceRegistry();

		SessionFactory sessionFactory = config
				.buildSessionFactory(serviceRegistry);
		return sessionFactory;
	}
	/**
	 * This method adds the contact to the database.
	 * @param contact
	 * @return
	 */
	public boolean saveContact(Contact contact) {
		Session session = getSessionFactory().openSession();
		session.beginTransaction();
	    session.saveOrUpdate(contact);
		session.getTransaction().commit();
		session.close();
		return true;
	}
	/**
	 * This method fetches the contact from the database.
	 * @param contactId
	 * @return
	 */
	public Contact getContact(Integer contactId) {
		Session session = getSessionFactory().openSession();
		// Query query =
		 //session.createQuery("from Contact ct where ct.companyName=:cmpyname");

		return (Contact) session.get(Contact.class, contactId);
	}
	/**
	 * This method removes contact from the database.
	 * @param contactId
	 */
	public  void deleteContact(Integer contactId) {
		Session session = getSessionFactory().openSession();
		session.beginTransaction();
		session.delete((Contact)getContact(contactId));
		session.getTransaction().commit();
		session.close();
	}
	/**
	 * This method searches for a contact in a database. 
	 * @param contact
	 * @return
	 */
	public List<Contact> searchContact(Contact contact) {
		Session session = getSessionFactory().openSession();
		// Query query =
		// session.createQuery("from Contact ct where ct.companyName=:cmpyname");

		Criteria crit = session.createCriteria(Contact.class);
		if (!StringUtils.isEmpty(contact.getCompanyName()))
			crit.add(Restrictions.eq("companyName", contact.getCompanyName()));
		if (!StringUtils.isEmpty(contact.getFirstName()))
			crit.add(Restrictions.eq("firstName", contact.getFirstName()));
		if (!StringUtils.isEmpty(contact.getLastName()))
			crit.add(Restrictions.eq("lastName", contact.getLastName()));

		List<Contact> results = crit.list();
		return results;

	}

}
