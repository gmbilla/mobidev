package it.mobidev.backend.data;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import lombok.Data;

import java.util.HashMap;
import java.util.Map;

import static com.googlecode.objectify.ObjectifyService.ofy;

/**
 * Entry for a single exercise.
 */
@Entity
@Data
public class Exercise {

    @Id String name;
    String description;

    /**
     * Stub method to store some test exercises.
     */
    public static void storeTestExercises() {
        Map<String, String> stubExercises = new HashMap<>();
        stubExercises.put("Test Push Up", "Push it up from the ground man!");
        stubExercises.put("Test Jumping jack", "Jump bitch");
        stubExercises.put("Test Crunch", "For your 6pack");

        for (String name : stubExercises.keySet()) {
            Exercise e = new Exercise();
            e.setName(name);
            e.setDescription(stubExercises.get(name));

            ofy().save().entity(e).now();
        }

    }

}
