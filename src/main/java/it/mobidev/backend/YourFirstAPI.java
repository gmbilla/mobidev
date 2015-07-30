package it.mobidev.backend;

import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiMethod;
import com.google.api.server.spi.config.Named;
import com.google.api.server.spi.config.Nullable;
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
    // GET methods
    //==========================================================================

    /**
     * <p>List all the stored exercise.</p>
     *
     * @return a list of {@link it.mobidev.backend.data.Exercise}
     */
    public List<Exercise> getExerciseList() {
        return ofy().load().type(Exercise.class).list();
    }

    /**
     * <p>Fetch all workout created by the given user.</p>
     *
     * @param userId    ID of the user
     * @return a list of {@link it.mobidev.backend.data.Workout}, if any has
     * been stored for the given user
     */
    public List<Workout> getUserWorkouts(@Named("user") String userId) {
        return ofy().load().type(Workout.class).filter("creatorId", userId)
                .list();
    }

    /**
     * <p>Fetch all the session stored by the given user.</p>
     *
     * @param userId    ID of the user
     * @return a list of {@link it.mobidev.backend.data.Session}, if any has
     * been stored for the given user
     */
    public List<Session> getUserSessions(@Named("user") String userId) {
        return ofy().load().type(Session.class).filter("userId", userId).list();
    }

    //==========================================================================
    // POST methods
    //==========================================================================

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
        path = "user/new",
        httpMethod = ApiMethod.HttpMethod.POST
    )
    public void createUser(@Named("token") String token,
                           @Named("email") String email,
                           @Named("sns") User.Social sns,
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
    @ApiMethod(
        name = "exercise.new",
        path = "exercise/new",
        httpMethod = ApiMethod.HttpMethod.POST
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
    public void addExercisesToWorkout(@Named("user") String userId,
                                      @Named("id") Long workoutId,
                                      @Named("exercises") Collection<Record>
                                              records)
            throws NotFoundException {
        // Check if given workout exists, otherwise raise a 404 error.
        Workout workout = getWorkout(workoutId, userId);
        if (workout == null)
            throw new NotFoundException("Workout " + workoutId + " not found!");

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

    /**
     * <p>Store a new training session for a user on a workout</p>
     * @param userId       user ID
     * @param workoutId    ID of the workout -- may be created by a different
     *                     user
     * @param when         when the session was taken -- new Date() if null
     * @param where        where the session has been taken -- may be null
     * @param userVote     user rank for the session -- may be null
     * @throws NotFoundException
     */
    @ApiMethod(
        name = "session.new",
        path = "session/new",
        httpMethod = ApiMethod.HttpMethod.POST
    )
    public void storeSession(@Named("user") String userId,
                             @Named("workout") Long workoutId,
                             @Named("date") @Nullable Date when,
                             @Named("place") @Nullable Long where,
                             @Named("vote") @Nullable Constants.Rank userVote)
            throws NotFoundException {
        // Check if user exists
        if (!userExists(userId))
            throw new NotFoundException("User " + userId + " not found!");
        // Check if workout exists
        if (!workoutExists(workoutId))
            throw new NotFoundException("Workout " + workoutId + " not found!");

        Session session = new Session();
        session.setUserId(userId);
        session.setWorkoutId(workoutId);
        if (when != null)
            session.setWhen(when);
        else
            session.setWhen(new Date());
        session.setWhere(where);
        session.setVote(userVote);

        ofy().save().entity(session).now();
    }

    //==========================================================================
    // Helpers
    //==========================================================================

    /**
     * <p>Fetch from datastore the user with the
     * given ID.</p>
     *
     * @param userId    user ID
     * @return a {@link it.mobidev.backend.data.User} instance if exists,
     * null otherwise
     */
    private User getUser(String userId) {
        return ofy().load().type(User.class).id(userId).now();
    }

    /**
     * <p>Fetch from datastore the workout with the given ID.</p>
     *
     * @param workoutId    workout ID
     * @return a workout instance if exists, null otherwise
     */
    private Workout getWorkout(Long workoutId) {
        return ofy().load().type(Workout.class).id(workoutId).now();
    }

    /**
     * <p>Fetch from datastore the workout with the given ID.</p>
     *
     * @param workoutId    workout ID
     * @param userId       workout creator user ID
     * @return a workout instance if exists, null otherwise
     */
    private Workout getWorkout(Long workoutId, String userId) {
        return ofy().load().type(Workout.class).filter("creatorId", userId)
                .filter("id", workoutId).first().now();
    }

    private boolean userExists(String userId) {
        return ofy().load().type(User.class).filter("email", userId).keys()
                .first() != null;
    }

    /**
     * <p>Check if given workout ID exists in datastore.</p>
     *
     * @param workoutId    workout ID
     * @return  true if workout actually exists, false otherwise
     */
    private boolean workoutExists(Long workoutId) {
        return ofy().load().type(Workout.class)
                .filterKey("id", workoutId).count() > 0;
    }

    /**
     * <p>Check if given workout ID exists in datastore and was created by
     * the given user.</p>
     *
     * @param workoutId    workout ID
     * @param userId       user ID
     * @return  true if workout actually exists and was created by the
     * current user, false otherwise
     */
    private boolean workoutExists(Long workoutId, String userId) {
        return ofy().load().type(Workout.class).filter("id", workoutId)
                .filter("creatorId", userId).keys().first() != null;
    }

}
