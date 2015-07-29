package it.mobidev.backend;

import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiMethod;
import com.google.api.server.spi.config.Named;
import it.mobidev.backend.data.*;

import java.util.List;
import java.util.logging.Logger;

import static com.googlecode.objectify.ObjectifyService.ofy;

/**
  * Add your first API methods in this class, or you may create another class. In that case, please
  * update your web.xml accordingly.
 **/
@Api(
    name = "test",
    version = "v1"
)
public class YourFirstAPI {

    private static final Logger Log = Logger.getLogger("YourFirstTestApi");

    /**
     * Stub methods
     */

    @ApiMethod(httpMethod = ApiMethod.HttpMethod.DELETE, path = "clear")
    public void deleteAll() {
        ofy().delete().keys(ofy().load().type(User.class).keys().list()).now();
        ofy().delete().keys(ofy().load().type(Place.class).keys().list()).now();
        ofy().delete().keys(ofy().load().type(Entry.class).keys().list()).now();
        ofy().delete().keys(ofy().load().type(Record.class).keys().list())
                .now();
        ofy().delete().keys(ofy().load().type(Workout.class).keys().list())
                .now();
    }

    @ApiMethod(httpMethod = ApiMethod.HttpMethod.GET, path = "workout/all")
    public List<Workout> getWorkouts() {
        return ofy().load().type(Workout.class).list();
    }

    public void insertTestRecords() {
        // TODO Not the right place!!
        Rest rest = new Rest();
        ofy().save().entity(rest).now();

        // Store test user
        User.storeTestUser();

        Log.info("Inserting test records");
        Workout.storeTestWorkout();
    }

    /**
     * POST
     */

    @ApiMethod(path = "exercise/add")
    public void insertExercise(@Named("name") String name,
                               @Named("description") String description) {
        Exercise e = new Exercise();
        e.setName(name);
        e.setDescription(description);
        ofy().save().entity(e).now();
    }

}
