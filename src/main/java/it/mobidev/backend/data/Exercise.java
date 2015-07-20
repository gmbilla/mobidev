package it.mobidev.backend.data;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import com.googlecode.objectify.annotation.Subclass;
import lombok.Data;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import static com.googlecode.objectify.ObjectifyService.ofy;

/**
 * Class representing an exercise
 */
@Subclass(index = true)
@Data
public class Exercise extends Entry {

    private static final Logger Log = Logger.getLogger("Exercise");

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

        List<Exercise> inserted = ofy().load().type(Exercise.class).list();
        Log.info(inserted.size() + " exercise inserted");
    }

}
