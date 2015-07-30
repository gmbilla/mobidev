package it.mobidev.backend;

import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiMethod;
import com.google.api.server.spi.config.Named;
import com.google.api.server.spi.response.ConflictException;
import com.google.api.server.spi.response.NotFoundException;
import it.mobidev.backend.data.*;

import java.util.Arrays;
import java.util.Collection;
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

    /**
     * <p>List all registered {@link it.mobidev.backend.data.User}s.</p>
     * @return
     */
    @ApiMethod(
        path = "user/all",
        httpMethod = ApiMethod.HttpMethod.GET
    )
    public List<User> getAllUser() {
        return ofy().load().type(User.class).list();
    }

    /**
     * <p>List all registered {@link it.mobidev.backend.data.Workout}s.</p>
     */
    @ApiMethod(
        path = "workout/all",
        httpMethod = ApiMethod.HttpMethod.GET
    )
    public List<Workout> getAllWorkout() {
        return ofy().load().type(Workout.class).list();
    }

    /**
     * <p>List all registered workout {@link it.mobidev.backend.data.Session}s.
     * </p>
     */
    @ApiMethod(
        path = "session/all",
        httpMethod = ApiMethod.HttpMethod.GET
    )
    public List<Session> getAllSession() {
        return ofy().load().type(Session.class).list();
    }

    /**
     * <p>Delete all stored stuff.</p>
     */
    @ApiMethod(
        path = "clear",
        httpMethod = ApiMethod.HttpMethod.DELETE
    )
    public void deleteAll() {
        ofy().delete().keys(ofy().load().type(User.class).keys().list()).now();
        ofy().delete().keys(ofy().load().type(Place.class).keys().list()).now();
        ofy().delete().keys(ofy().load().type(Entry.class).keys().list()).now();
        ofy().delete().keys(ofy().load().type(Workout.class).keys().list())
                .now();
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

    /**
     * <p>Register a new user.</p>
     *
     * @param token        token generated with SNS oAuth process
     * @param email        user e-mail address
     * @param sns          which SNS the user used to register
     * @param firstName    user first name
     * @param lastName     user last name
     * @param imageUrl     URL of user's profile picture
     */
    @ApiMethod(
        name = "user.new",
        path = "user/new"
    )
    public void createUser(@Named("token") String token,
                           @Named("email") String email,
                           @Named("sns") int sns,
                           @Named("first_name") String firstName,
                           @Named("last_name") String lastName,
                           @Named("image_url") String imageUrl) {
        User user = new User();
        user.setToken(token);
        user.setSignUpSns((short) sns);
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
    @ApiMethod(
        name = "exercise.new",
        path = "exercise/new"
    )
    public void insertExercise(@Named("name") String name,
                               @Named("description") String description) {
        Exercise e = new Exercise();
        e.setName(name);
        e.setDescription(description);
        ofy().save().entity(e).now();
    }

    /**
     * <p>Create a new workout for the given user.</p>
     *
     * @param userId       workout creator ID
     * @param name         workout name
     * @param exercises    list of workout exercise -- single exercise
     *                     entry must already exists in datastore
     * @throws ConflictException
     */
    @ApiMethod(
        name = "workout.new",
        path = "workout/new",
        httpMethod = ApiMethod.HttpMethod.POST
    )
    public void createWorkout(@Named("user") String userId,
                              @Named("name") String name,
                              @Named("exercises") Record[] exercises)
            throws ConflictException {
        // Check if current user already have a workout with the given name
        if (ofy().load().type(Workout.class).filter("creatorId", userId)
                .filter("name", name).count() > 0)
            throw new ConflictException("User already has a workout named '"
                    + name + "'");

        Workout workout = new Workout();
        workout.setCreatorId(userId);
        workout.setName(name);
        workout.setDateCreated(new Date());
        workout.setExerciseList(Arrays.asList(exercises));

        ofy().save().entity(workout).now();
    }

    /**
     * <p>Create a workout with no exercise.</p>
     *
     * @param userId    workout creator ID
     * @param name      workout name
     * @throws ConflictException
     */
    @ApiMethod(
        name = "workout.empty",
        path = "workout/empty",
        httpMethod = ApiMethod.HttpMethod.POST
    )
    public void createEmptyWorkout(@Named("user") String userId,
                                   @Named("name") String name)
            throws ConflictException {
        // Check if current user already have a workout with the given name
        if (ofy().load().type(Workout.class).filter("creatorId", userId)
                .filter("name", name).count() > 0)
            throw new ConflictException("User already has a workout named '"
                    + name + "'");

        Workout workout = new Workout();
        workout.setCreatorId(userId);
        workout.setName(name);
        workout.setDateCreated(new Date());

        ofy().save().entity(workout).now();
    }

    @ApiMethod(
        name = "workout.add",
        path = "workout/{id}/add",
        httpMethod = ApiMethod.HttpMethod.POST
    )
    public void addExercisesToWorkout(@Named("id") String workoutId,
                                      @Named("exercises") Collection<Record>
                                              records)
            throws NotFoundException {
        // Check if given workout exists, otherwise raise a 404 error.
        Workout workout = ofy().load().type(Workout.class).id(workoutId).now();
        if (workout == null)
            throw new NotFoundException("Workout " + workoutId + " not found");

        for (Record r : records) {
            // Check if the exercise in current record exists, otherwise raise
            // a 404 error.
            if (ofy().load().type(Entry.class).id(r.getExercise())
                    .now() == null)
                throw new NotFoundException("Exercise '" + r.getExercise()
                        + "' not found");

            workout.addExercise(r);
        }

        ofy().save().entity(workout).now();
    }

}
