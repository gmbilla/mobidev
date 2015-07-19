package it.mobidev.backend.data;

import com.googlecode.objectify.Key;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import lombok.Data;

import java.util.Random;

import static com.googlecode.objectify.ObjectifyService.ofy;

/**
 * Exercise record inside a workout
 */
@Entity
@Data
public class Record {

    @Id Long id;
    Key<? extends Exercise> exercise;
    /** The number of total repetitions that should be done to complete the
     * exercise set */
    int numberOfReps;
    /** How many times should the exercise be done in each rep */
    int hitPerRep;
    /** Duration in second of the exercise in each rep */
    int duration;
    /** Rest between each series. Note: may be 0 */
    int rest;

    /**
     * Stub methoed to store some "random" records of exercises
     */
    public static void storeTestRecords() {
        // Fetch defined exercises
        Iterable<Key<Exercise>> exercises = ofy().load().type(Exercise.class)
                .keys();
        Random rand = new Random();
        long recordId = 0;

        for (Key<Exercise> e : exercises) {
            Record r = new Record();
            // Fake the record ID
            r.setId(recordId);
            r.setExercise(e);
            r.setNumberOfReps(rand.nextInt(5));
            // "Randomly" create an exercise of one type or another
            if (rand.nextInt(10) % 2 == 0)
                r.setHitPerRep(rand.nextInt(20));
            else
                r.setDuration((rand.nextBoolean() ? 30 : 20));
            r.setRest(rand.nextInt(10) % 2 == 0 ? 10: 0);
            // Store exercise record
            ofy().save().entity(r).now();

            recordId++;
        }
    }

}
