package it.mobidev.backend;

import com.googlecode.objectify.ObjectifyService;
import it.mobidev.backend.data.*;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

/**
 * Entry point for App Engine app
 */
public class ApiInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent servletContextEvent) {
        // This will be invoked as part of a warmup request, or the first user
        // request if no warmup request was invoked.
        ObjectifyService.register(Place.class);
        ObjectifyService.register(User.class);
        ObjectifyService.register(Entry.class);
        ObjectifyService.register(Exercise.class);
        ObjectifyService.register(Rest.class);
        ObjectifyService.register(Workout.class);
        ObjectifyService.register(Session.class);

        // TODO Store an entity for rest
        // Not working!!
        // Rest rest = new Rest();
        // ofy().save().entity(rest).now();
    }

    @Override
    public void contextDestroyed(ServletContextEvent servletContextEvent) {
        // App Engine does not currently invoke this method.
    }

}
