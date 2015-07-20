package it.mobidev.backend.data;

import com.googlecode.objectify.annotation.Subclass;
import lombok.Data;

import java.util.List;
import java.util.Random;

import static com.googlecode.objectify.ObjectifyService.ofy;

/**
 * Exercise record inside a workout
 */
@Subclass(index = true)
@Data
public class ExerciseRecord extends Record {

//    Key<? extends Exercise> exercise;
    /** The number of total repetitions that should be done to complete the
     * exercise set */
    int numberOfReps;
    /** How many times should the exercise be done in each rep */
    int hitPerRep;
    /** Rest between each series. Note: may be 0 */
    int rest;

    /**
     * Stub methoed to store some "random" records of exercises
     */
    public static void storeTestRecords() {
        // Fetch defined exercises
        Iterable<Exercise> exercises = ofy().load().type(Exercise.class)
                .list();
        Random rand = new Random();
        long recordId = 1;

        for (Exercise e : exercises) {
            Log.info("Inserting record for exercise " + e.getName());

            ExerciseRecord r = new ExerciseRecord();
            // Fake the record ID
            r.setId(recordId);
            r.setExercise(e);
            r.setNumberOfReps(rand.nextInt(5) + 1);
            // "Randomly" create an exercise of one type or another
            if (rand.nextInt(10) % 2 == 0)
                r.setHitPerRep(rand.nextInt(20) + 1);
            else
                r.setDuration((rand.nextBoolean() ? 30 : 20));
            if (r.getNumberOfReps() > 1)
                r.setRest(rand.nextBoolean() ? 10: 20);
            // Store exercise record
            ofy().save().entity(r).now();

            recordId++;
        }

        List<ExerciseRecord> insertedRecords = ofy().load()
                .type(ExerciseRecord.class).list();
        Log.info(insertedRecords.size() + " exercise records inserted");
    }

}
