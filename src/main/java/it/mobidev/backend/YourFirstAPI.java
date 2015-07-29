package it.mobidev.backend;

import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiMethod;
import com.google.api.server.spi.config.Named;
import com.google.api.server.spi.response.ConflictException;
import it.mobidev.backend.data.*;

import java.util.Date;
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

    //==========================================================================
    // Admin methods
    //==========================================================================

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

    /**
     * <p>List all registered sessions.</p>
     *
     * @return
     */
    @ApiMethod(httpMethod = ApiMethod.HttpMethod.GET, path = "session/all")
    public List<Session> getSessions() {
        return ofy().load().type(Session.class).list();
    }

    //==========================================================================
    // Post methods
    //==========================================================================

    /**
     * <p>Insert fake entries to test.</p>
     */
    // TODO remove me
    public void insertTestRecords() {
        // TODO Not the right place!!
        Rest rest = new Rest();
        ofy().save().entity(rest).now();

        // Store test user
        User.storeTestUser();

        Log.info("Inserting test records");
        Workout.storeTestWorkout();
    }

    public void createUser(@Named("token") String token,
                           @Named("email") String email,
                           @Named("sns") short sns,
                           @Named("first_name") String firstName,
                           @Named("last_name") String lastName,
                           @Named("image_url") String imageUrl) {
        User user = new User();
        user.setToken(token);
        user.setSignUpSns(sns);
        user.setEmail(email);
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setImageUrl(imageUrl);

        ofy().save().entity(user).now();
    }

    /**
     * <p>Create a new exercise.</p>
     *
     * @param name           exercise name
     * @param description    exercise description
     */
    @ApiMethod(path = "exercise/add")
    public void insertExercise(@Named("name") String name,
                               @Named("description") String description) {
        Exercise e = new Exercise();
        e.setName(name);
        e.setDescription(description);
        ofy().save().entity(e).now();
    }

    @ApiMethod(
            name = "workout.new",
            path = "workout/new",
            httpMethod = ApiMethod.HttpMethod.POST
    )
    public void createWorkout(@Named("user") String userId,
                              @Named("name") String name,
                              @Named("exercises") List<Record> exerciseList)
            throws ConflictException {
        if (ofy().load().type(Workout.class).filter("name", name)
                .filter("creatorId", userId).count() > 0) {
            throw new ConflictException("Workout " + name + " already exists " +
                    "for user " + userId);
        }

        Workout workout = new Workout();
        workout.setCreatorId(userId);
        workout.setName(name);
        workout.setDateCreated(new Date());
        workout.setExerciseList(exerciseList);

        ofy().save().entity(workout).now();
    }

    @ApiMethod(
        name = "workoud.new",
        path = "workout/new",
        httpMethod = ApiMethod.HttpMethod.POST
    )
    public void createEmptyWorkout(@Named("user") String userId,
                                   @Named("name") String name) {
        Workout workout = new Workout();
        workout.setCreatorId(userId);
        workout.setName(name);
        workout.setDateCreated(new Date());

        ofy().save().entity(workout).now();
    }

    //==========================================================================
    // Put methods
    //==========================================================================

    @ApiMethod(
        name = "workout.add",
        path = "workout/{id}/add",
        httpMethod = ApiMethod.HttpMethod.PUT
    )
    public void addExerciseToWorkout(@Named("id") String workoutId,
                                     @Named("exercise") Record exercise) {
        Workout workout = ofy().load().type(Workout.class).id(workoutId).now();

        workout.addExercise(exercise);

        ofy().save().entity(workout).now();
    }

}
