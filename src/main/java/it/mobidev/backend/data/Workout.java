package it.mobidev.backend.data;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

import static com.googlecode.objectify.ObjectifyService.ofy;

/**
 * Workout entity containing the list of exercise it's composed of.
 */
@Entity
@Data
public class Workout {

    private static final Logger Log = Logger.getLogger("Workout");

    @Id Long id;
    /** User that created the workout */
    User creator;
    /** Workout name */
    String name;
    /**
     * Store the place where the workout was done.
     * Note: only for completed workouts
     */
    Place where = null;
    List<Record> exerciseList = new ArrayList();

    public static void storeTestWorkout() {
        // Store other test stuff
        Exercise.storeTestExercises();
        ExerciseRecord.storeTestRecords();
        RestRecord.storeTestRestRecords();
        User.storeTestUser();

        Workout w = new Workout();
        w.setName("My test workout");
        w.setCreator(ofy().load().type(User.class)
                .id(User.TEST_USER_EMAIL).now());

        // Fetch test records and insert in exercise list
        List<ExerciseRecord> records = ofy().load().type(ExerciseRecord.class)
                .list();
        Iterable<RestRecord> restRecords = ofy().load().type(RestRecord.class)
                .list();
        int index = 0;
        w.exerciseList.add(records.get(index++));

        for (RestRecord rest : restRecords) {

            w.exerciseList.add(rest);
            w.exerciseList.add(records.get(index++));

        }

        Log.info("Exercise List:");
        for (Record r : w.exerciseList) {
            Log.info("\t" + r.getExercise().getName());
        }

        ofy().save().entity(w).now();
    }

}
