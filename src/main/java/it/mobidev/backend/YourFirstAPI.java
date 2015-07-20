package it.mobidev.backend;

import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiMethod;
import it.mobidev.backend.data.*;

import java.util.List;
import java.util.logging.Logger;

import static com.googlecode.objectify.ObjectifyService.ofy;

/**
  * Add your first API methods in this class, or you may create another class. In that case, please
  * update your web.xml accordingly.
 **/
@Api(
    name = "testAPI",
    version = "v1"
)
public class YourFirstAPI {

    private static final Logger Log = Logger.getLogger("YourFirstTestApi");

    /**
     * Stub methods
     */

    @ApiMethod(httpMethod = ApiMethod.HttpMethod.DELETE, path = "clear")
    public void deleteAll() {
        ofy().delete().keys(ofy().load().type(Workout.class).keys().list())
                .now();
        ofy().delete().keys(ofy().load().type(User.class).keys().list())
                .now();
        ofy().delete().keys(ofy().load().type(Exercise.class).keys().list())
                .now();
        ofy().delete().keys(ofy().load().type(Rest.class).keys().list())
                .now();
        ofy().delete().keys(ofy().load().type(ExerciseRecord.class).keys().list())
                .now();
        ofy().delete().keys(ofy().load().type(RestRecord.class).keys().list())
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

        Log.info("Inserting test records");
        Workout.storeTestWorkout();
    }

}
