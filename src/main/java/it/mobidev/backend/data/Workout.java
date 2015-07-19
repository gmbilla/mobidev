package it.mobidev.backend.data;

import com.google.appengine.api.datastore.QueryResultIterator;
import com.googlecode.objectify.Key;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import com.googlecode.objectify.annotation.Parent;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

import static com.googlecode.objectify.ObjectifyService.ofy;

/**
 * Workout entity containing the list of exercise it's composed of.
 */
@Entity
@Data
public class Workout {

    @Id Long id;
    /** User that created the workout */
//    @Parent Key<User> creator;
    /** Workout name */
    String name;
    /**
     * Store the place where the workout was done.
     * Note: only for completed workouts
     */
    Key<Place> where = null;
    List<Key<? extends Record>> exerciseList = new ArrayList<>();

    public static void storeTestWorkout() {
        // Store other test stuff
        Exercise.storeTestExercises();
        Record.storeTestRecords();
        RestRecord.storeTestRestRecords();
        User.storeTestUser();

        Workout w = new Workout();
        w.setName("My test workout");
//        w.setCreator(ofy().load().type(User.class)
//                .filter("email", User.TEST_USER_EMAIL).keys().first().now());

        // Fetch test records and insert in exercise list
        QueryResultIterator<Key<Record>> records = ofy().load()
                .type(Record.class).keys().iterator();
        Iterable<Key<RestRecord>> restRecords = ofy().load().type(RestRecord
                .class).keys();
        w.exerciseList.add(records.next());

        for (Key<RestRecord> rest : restRecords) {

            w.exerciseList.add(rest);
            w.exerciseList.add(records.next());

        }

        ofy().save().entity(w).now();
    }

}
