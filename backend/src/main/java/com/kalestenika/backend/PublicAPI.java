package com.kalestenika.backend;

import com.google.api.server.spi.config.*;
import com.google.api.server.spi.response.ConflictException;
import com.google.api.server.spi.response.ForbiddenException;
import com.google.api.server.spi.response.NotFoundException;
import com.googlecode.objectify.Key;
import com.kalestenika.backend.data.*;

import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.List;

import static com.googlecode.objectify.ObjectifyService.ofy;

/**
 * <p>Class holding all exposed methods of public API.</p>
 */
@Api(
    name = "kalestenika",
    version = "v1",
    scopes = {Constants.EMAIL_SCOPE}
)
@ApiClass(
    clientIds = {Constants.WEB_CLIENT_ID, Constants.ANDROID_CLIENT_ID,
            Constants.IOS_CLIENT_ID},
    audiences = {Constants.ANDROID_AUDIENCE}
)
public class PublicAPI {

    private static final String CANT_TOUCH_THIS = "U Can't Touch This!";

    //==========================================================================
    // GET methods
    //==========================================================================

    /**
     * <p>List all the stored exercise.</p>
     *
     * @return a list of {@link com.kalestenika.backend.data.Exercise}
     */
    @ApiMethod(
        name = "exercise.list",
        path = "exercise/list",
        httpMethod = ApiMethod.HttpMethod.GET
    )
    public List<Exercise> getExerciseList() {
        return ofy().load().type(Exercise.class).list();
    }

    /**
     * <p>Fetch all workout created by the given user.</p>
     *
     * @param userId    ID of the user
     * @return a list of {@link com.kalestenika.backend.data.Workout}, if any has
     * been stored for the given user
     */
    @ApiMethod(
        name = "workout.list",
        path = "workout/{user}",
        httpMethod = ApiMethod.HttpMethod.GET
    )
    public List<Workout> getUserWorkouts(@Named("user") String userId)
            throws NotFoundException {
        if (!userExists(userId))
            throw new NotFoundException("User " + userId + " not found");

        return ofy().load().type(Workout.class).filter("creatorId", userId)
                .list();
    }

    /**
     * <p>Fetch all the session stored by the given user.</p>
     *
     * @param userId    ID of the user
     * @return a list of {@link com.kalestenika.backend.data.Session}, if any has
     * been stored for the given user
     */
    @ApiMethod(
        name = "session.list",
        path = "session/{user}",
        httpMethod = ApiMethod.HttpMethod.GET
    )
    public List<Session> getUserSessions(@Named("user") String userId)
            throws NotFoundException {
        if (!userExists(userId))
            throw new NotFoundException("User " + userId + " not found");

        return ofy().load().type(Session.class).filter("userId", userId).list();
    }

    //==========================================================================
    // POST methods
    //==========================================================================

    /**
     * <p>Register a new user.</p>
     *
     * @param id           the user ID, from the chosen SNS
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
    public void createUser(@Named("id") String id,
                           @Named("sns") User.Social sns,
                           @Named("first_name") String firstName,
                           @Named("last_name") String lastName,
                           @Named("image_url") String imageUrl)
            throws ConflictException {
        if (userExists(id))
            throw new ConflictException("User already registered");

        User user = new User();
        user.setId(id);
        user.setSignUpSns(sns);
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
                               @Named("description") String description)
            throws ConflictException {
        if (ofy().load().type(Exercise.class).id(name) != null)
            throw new ConflictException("Exercise '" + name + "' already exists");

        Exercise e = new Exercise();
        e.setName(name);
        e.setDescription(description);

        ofy().save().entity(e).now();
        // Clear Objectify cache
        ofy().clear();
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
                              @Named("exercises") Record[] exercises,
                              @Named("schedule") boolean[] scheduledOnDays)
            throws ConflictException, NotFoundException {
        // Check if user exists
        if (!userExists(userId))
            throw new NotFoundException("User " + userId + " not found");

        // Check if current user already have a workout with the given name
        if (ofy().load().type(Workout.class).filter("creatorId", userId)
                .filter("name", name).count() > 0)
            throw new ConflictException("User already has a workout named '"
                    + name + "'");

        // Check that given schedule is for 7 days
        if (scheduledOnDays.length != 7)
            throw new ConflictException(String.format("Schedule expected to " +
                    "be week based, only %d days given", scheduledOnDays.length));

        Workout workout = new Workout();
        workout.setCreatorId(userId);
        workout.setName(name);
        workout.setDateCreated(new Date());
        workout.setExerciseList(Arrays.asList(exercises));
        workout.setScheduledOnDays(scheduledOnDays);

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
    public Workout createEmptyWorkout(@Named("user") String userId,
                                      @Named("name") String name)
            throws ConflictException, NotFoundException {
        // Check if user exists
        if (!userExists(userId))
            throw new NotFoundException("User " + userId + " not found");

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

        return workout;
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
            throws NotFoundException, ForbiddenException {
        // Check if given workout exists, otherwise raise a 404 error.
        Workout workout = getWorkout(workoutId);
        if (workout == null)
            throw new NotFoundException("Workout " + workoutId + " not found!");

        // Check if user if creator of the workout
        if (!workout.getCreatorId().equals(userId))
            throw new ForbiddenException(CANT_TOUCH_THIS);

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

    @ApiMethod(
            name = "workout.schedule",
            path = "workout/{id}/schedule",
            httpMethod = ApiMethod.HttpMethod.POST
    )
    public void setScheduleForWorkout(@Named("user") String userId,
                                      @Named("id") Long workoutId,
                                      @Named("schedule") boolean[] days)
            throws NotFoundException, ForbiddenException {
        // Check if given workout exists, otherwise raise a 404 error.
        Workout workout = getWorkout(workoutId);
        if (workout == null)
            throw new NotFoundException("Workout " + workoutId + " not found!");

        // Check if user if creator of the workout
        if (!workout.getCreatorId().equals(userId))
            throw new ForbiddenException(CANT_TOUCH_THIS);

        workout.setScheduledOnDays(days);

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
    public Session storeSession(@Named("user") String userId,
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

        if (where != null &&
                ofy().load().type(Place.class).id(where).now() == null)
            throw new NotFoundException("Place " + where + " not found!");

        session.setWhere(where);
        session.setVote(userVote);

        ofy().save().entity(session).now();

        return session;
    }

    //==========================================================================
    // DELETE methods
    //==========================================================================

    @ApiMethod(
        name = "exercise.delete",
        path = "exercise/{name}/delete",
        httpMethod = ApiMethod.HttpMethod.DELETE
    )
    public void removeExercise(@Named("name") String name)
            throws NotFoundException {
        Exercise e = ofy().load().type(Exercise.class).id(name).now();
        if (e == null)
            throw new NotFoundException("Exercise '" + name + "' not found");

        ofy().delete().entity(e).now();
        // Clear Objectify cache
        ofy().clear();
    }

    /**
     * <p>Allow a user to delete one of her workout.</p>
     *
     * @param userId       user ID -- creator of the workout
     * @param workoutId    ID of the workout
     * @throws NotFoundException
     * @throws ForbiddenException
     */
    @ApiMethod(
        name = "workout.delete",
        path = "workout/{workoutId}/delete",
        httpMethod = ApiMethod.HttpMethod.DELETE
    )
    public void removeWorkout(@Named("user") String userId,
                              @Named("workout") Long workoutId)
            throws NotFoundException, ForbiddenException {
        // Check if workout exists
        Workout workout = getWorkout(workoutId);
        if (workout == null)
            throw new NotFoundException("Workout " + workoutId + " not found");

        // Check if workout creator is the current user
        if (!workout.getCreatorId().equals(userId))
            throw new ForbiddenException(CANT_TOUCH_THIS);

        // Check if current workout is referenced by any session
        if (ofy().load().type(Session.class).filter("workoutId", workoutId)
                .count() > 0)
            throw new ForbiddenException("Workout is referenced by a session");

        ofy().delete().entity(workout).now();
        // Clear Objectify cache
        ofy().clear();
    }

    /**
     * <p>Allow a user to delete one of her sessions.</p>
     *
     * @param userId       user ID -- creator of the session
     * @param sessionId    ID of the session
     * @throws NotFoundException
     * @throws ForbiddenException
     */
    @ApiMethod(
        name = "session.delete",
        path = "session/{sessionId}/delete",
        httpMethod = ApiMethod.HttpMethod.DELETE
    )
    public void removeSession(@Named("user") String userId,
                              @Named("session") Long sessionId)
            throws NotFoundException, ForbiddenException {
        // Check if the session exists
        Session session = ofy().load().type(Session.class).id(sessionId).now();
        if (session == null)
            throw new NotFoundException("Session " + sessionId + " not found");

        // Check is user is the creator of the session
        if (!session.getUserId().equals(userId))
            throw new ForbiddenException(CANT_TOUCH_THIS);

        ofy().delete().entity(session).now();
        // Clear Objectify cache
        ofy().clear();
    }

    //==========================================================================
    // Helpers
    //==========================================================================

    /**
     * <p>Fetch from datastore the user with the
     * given ID.</p>
     *
     * @param userId    user ID
     * @return a {@link com.kalestenika.backend.data.User} instance if exists,
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

    private boolean userExists(String userId) {
        return ofy().load().type(User.class).id(userId).now() != null;
    }

    /**
     * <p>Check if given workout ID exists in datastore.</p>
     *
     * @param workoutId    workout ID
     * @return true if workout actually exists, false otherwise
     */
    private boolean workoutExists(Long workoutId) {
        return ofy().load().type(Workout.class)
                .filterKey(Key.create(Workout.class, workoutId)).count() > 0;
    }

}
