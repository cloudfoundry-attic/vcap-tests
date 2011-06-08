package org.cloudfoundry.canonical.apps;

import org.hibernate.SessionFactory;
import org.springframework.orm.hibernate3.HibernateTemplate;

public class ReferenceDataRepository {
		
	private HibernateTemplate hibernateTemplate;

    public void setSessionFactory(SessionFactory sessionFactory) {
        this.hibernateTemplate = new HibernateTemplate(sessionFactory);
    }

	public void save(DataValue dataValue){
        this.hibernateTemplate.saveOrUpdate(dataValue);
    }
 
    public DataValue find(String id){
        return (DataValue) hibernateTemplate.find("from DataValue where id='"+id+"'").get(0);
    }
}
