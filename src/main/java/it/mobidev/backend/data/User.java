package it.mobidev.backend.data;

import com.googlecode.objectify.Key;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import com.googlecode.objectify.annotation.Index;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

import static com.googlecode.objectify.ObjectifyService.ofy;

/**
 * Created by gmbilla on 17/07/15.
 */
@Entity
@Data
public class User {

    public static final short SNS_NONE = -1;
    public static final short SNS_FACEBOOK = 0;
    public static final short SNS_GOOGLE_PLUS = 1;
    // TODO remove stub code
    public static final String TEST_USER_EMAIL = "pippo@calippo.com";

    @Id String email;
    @Index String token;
    String firstName;
    String lastName;
    String imageUrl;
    /** Which SNS the user used to sign up */
    short signUpSns = SNS_NONE;
    List<Place> createdPlaces = new ArrayList<>();

    /**
     * Stub method to insert a test user
     */
    public static void storeTestUser() {
        User u = new User();
        u.setEmail(TEST_USER_EMAIL);
        u.setToken("abc123");
        u.setFirstName("Pippo");
        u.setLastName("Calippo");
        u.setImageUrl("http://img2.wikia.nocookie.net/__cb20130521020830/disney/images/3/3f/Stitch_Render.png");

        ofy().save().entity(u).now();
    }

}
