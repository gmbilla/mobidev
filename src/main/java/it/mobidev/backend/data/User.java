package it.mobidev.backend.data;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

/**
 * <p>Entity representing a user that logged in with a SNS.</p>
 */
@Entity
@Data
public class User {

    @Id String email;
    String firstName;
    String lastName;
    String imageUrl;
    /** Which SNS the user used to sign up */
    Social signUpSns = Social.NONE;
    List<Long> createdPlaces = new ArrayList<>();

    /**
     * Enum representing the list of possible Social network sites a user can
     * use to register
     */
    public enum Social {
        NONE, FACEBOOK, GOOGLE_PLUS
    }

}
