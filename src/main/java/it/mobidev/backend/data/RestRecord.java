package it.mobidev.backend.data;

import com.googlecode.objectify.Key;

import java.util.Arrays;
import java.util.List;
import java.util.Random;

import static com.googlecode.objectify.ObjectifyService.ofy;

/**
 * Workout record for rest
 */
public class RestRecord extends Record {

    public RestRecord() {
        this(0);
    }

    public RestRecord(int duration) {
        exercise = Key.create(Rest.class, Rest.KEY_ID);
        this.duration = duration;
    }

    public static void storeTestRestRecords() {
        List<Integer> stubDurations = Arrays.asList(0, 10, 30, 60, 90, 120);
        int i = ofy().load().type(Record.class).count() - 1;
        Random rand = new Random();

        for (int j = 0; j < i; j++) {
            RestRecord r = new RestRecord(stubDurations.get(rand.nextInt(stubDurations.size())));
            ofy().save().entity(r).now();
        }
    }

}
