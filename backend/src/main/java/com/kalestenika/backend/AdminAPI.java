package com.kalestenika.backend;

import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiMethod;
import com.google.api.server.spi.response.UnauthorizedException;
import com.google.appengine.api.oauth.OAuthRequestException;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.kalestenika.backend.data.*;

import java.util.List;

import static com.googlecode.objectify.ObjectifyService.ofy;

/**
 * <p>Class holding API methods exposed only to admin users.</p>
 */
@Api(
    name = "admin",
    version = "v1",
    scopes = {Constants.EMAIL_SCOPE},
    clientIds = {Constants.WEB_CLIENT_ID}
)
public class AdminAPI {

    /**
     * <p>List all registered {@link User}s.</p>
     *
     * @return a list of {@link User}
     */
    @ApiMethod(
        name = "user.all",
        path = "user/all",
        httpMethod = ApiMethod.HttpMethod.GET
    )
    public List<User> getAllUser()
            throws UnauthorizedException {
        UserService userService = UserServiceFactory.getUserService();
        if (!userService.isUserAdmin())
            throw new UnauthorizedException("You shall not pass!");

        return ofy().load().type(User.class).list();
    }

    /**
     * <p>List all registered {@link Workout}s.</p>
     */
    @ApiMethod(
        name = "workout.all",
        path = "workout/all",
        httpMethod = ApiMethod.HttpMethod.GET
    )
    public List<Workout> getAllWorkout()
            throws OAuthRequestException, UnauthorizedException {
        UserService userService = UserServiceFactory.getUserService();
        if (!userService.isUserAdmin())
            throw new UnauthorizedException("You shall not pass!");

        return ofy().load().type(Workout.class).list();
    }

    /**
     * <p>List all registered workout {@link Session}s.
     * </p>
     */
    @ApiMethod(
        name = "session.all",
        path = "session/all",
        httpMethod = ApiMethod.HttpMethod.GET
    )
    public List<Session> getAllSession()
            throws UnauthorizedException {
        UserService userService = UserServiceFactory.getUserService();
        if (!userService.isUserAdmin())
            throw new UnauthorizedException("You shall not pass!");

        return ofy().load().type(Session.class).list();
    }

    /**
     * <p>Delete all stored stuff.</p>
     */
    @ApiMethod(
        name = "clear",
        path = "clear",
        httpMethod = ApiMethod.HttpMethod.DELETE
    )
    public void deleteAll()
            throws UnauthorizedException {
        UserService userService = UserServiceFactory.getUserService();
        if (!userService.isUserAdmin())
            throw new UnauthorizedException("You shall not pass!");

        ofy().delete().keys(ofy().load().type(User.class).keys().list()).now();
        ofy().delete().keys(ofy().load().type(Place.class).keys().list()).now();
        ofy().delete().keys(ofy().load().type(Entry.class).keys().list()).now();
        ofy().delete().keys(ofy().load().type(Workout.class).keys().list())
                .now();
    }

}
