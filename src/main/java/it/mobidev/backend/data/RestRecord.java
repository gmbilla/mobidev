package it.mobidev.backend.data;

import com.googlecode.objectify.annotation.Subclass;

import java.util.Arrays;
import java.util.List;
import java.util.Random;

import static com.googlecode.objectify.ObjectifyService.ofy;

/**
 * Workout record for rest
 */
@Subclass(index = true)
public class RestRecord extends Record {

    public RestRecord() {
        this(0);
    }

    public RestRecord(int duration) {
        exercise = new Rest();
        this.duration = duration;
    }

    public static void storeTestRestRecords() {
        List<Integer> stubDurations = Arrays.asList(10, 30, 60, 90, 120);
        int i = ofy().load().type(ExerciseRecord.class).count() - 1;
        Random rand = new Random();
        Log.info("Inserting " + i + " rest records");

        for (int j = 0; j < i; j++) {
            RestRecord r = new RestRecord(stubDurations.get(rand.nextInt(stubDurations.size())));
            ofy().save().entity(r).now();
        }

        List<RestRecord> inserted = ofy().load().type(RestRecord.class).list();
        Log.info(inserted.size() + " rest record inserted");
    }

}
