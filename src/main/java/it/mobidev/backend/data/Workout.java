package it.mobidev.backend.data;

import com.google.api.server.spi.response.ConflictException;
import com.google.common.base.Joiner;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import com.googlecode.objectify.annotation.Index;
import it.mobidev.backend.Constants.Rank;
import lombok.Data;

import java.util.*;
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
    @Index String creatorId;
    /** Workout name */
    @Index String name;
    Date dateCreated = null;
    List<Record> exerciseList = new ArrayList();

    // TODO remove stub method
    public static void storeTestWorkout() {
        Workout w = new Workout();
        w.setName("My test workout");
        w.setCreatorId(User.TEST_USER_EMAIL);
        w.setDateCreated(new Date());

        // Create test exercise list
        List<Exercise> exercises = Arrays.asList(
                new Exercise("Test Push Up", "Push it up from the ground man!"),
                new Exercise("Test Jumping jack", "Jump bitch"),
                new Exercise("Test Crunch", "For your 6pack")
        );
        Log.info("Sample exercises: " + Joiner.on('\n').join(exercises));
        int[] sampleRests = new int[] {0, 10, 30};

        List<Record> recordList = new ArrayList<>();
        int[] rests = new int[exercises.size()];
        // Populate record list
        Record r;
        Random rand = new Random();
        int index = 0;
        for (Exercise e : exercises) {
            ofy().save().entity(e).now();

            r = new Record();
            r.setExercise(e.getName());
            // "Randomly" create an exercise of one type or another
            if (rand.nextInt(10) % 2 == 0)
                r.setHitsPerRep(rand.nextInt(20) + 1);
            else
                r.setDuration((rand.nextBoolean() ? 30 : 20));

            recordList.add(r);
            rests[index++] = sampleRests[rand.nextInt(sampleRests.length)];
        }
        String recordToString = "";
        for (int i = 0; i < recordList.size(); i++)
            recordToString += recordList.get(i).toString() + " - rest sec " +
                    rests[i] + "\n";
        Log.info("Sample superset:\n" + recordToString);

        try {
            // Insert created superset
            Log.info("Inserting superset with a list of exercise");
            w.addSuperSet(recordList, rests);

            // Insert the same exercised but as single one with multiple reps
            for (Exercise e : exercises) {
                int duration = 0, hitsPerRep = 0;
                // Randomly choose # of reps
                int reps = rand.nextInt(5) + 1;
                int rest = sampleRests[rand.nextInt(sampleRests.length)];
                // Chose number of seconds or hits for current exercise
                if (rand.nextInt(10) % 2 == 0)
                    hitsPerRep = rand.nextInt(20) + 1;
                else
                    duration = rand.nextBoolean() ? 30 : 20;
                Log.info(String.format("Adding %d reps for '%s' with %ds rest" +
                        " - duration = %d, hitsPerRep = %d", reps, e.getName(),
                        rest, duration, hitsPerRep));

                w.addRepsForExercise(
                        e,
                        reps,
                        duration,
                        hitsPerRep,
                        rest
                );
            }
        } catch (ConflictException e) {
            Log.severe("Error adding exercise set: " + e.getMessage());
        }

        Log.info("Exercise list:\n" + Joiner.on('\n').join(w.exerciseList));

        ofy().save().entity(w).now();

        // Add test Session for this workout
        Session session = new Session();
        session.setUserId(User.TEST_USER_EMAIL);
        session.setWorkoutId(w.getId());
        session.setVote(Rank.NORMAL);

        ofy().save().entity(session).now();
    }

    //==========================================================================
    // Helpers
    //==========================================================================

    /**
     * <p>Add given exercise to exercise list.</p>
     *
     * @param ex a {@link it.mobidev.backend.data.Record} describing the
     *           exercise to be added to the list
     */
    public void addExercise(Record ex) {
        exerciseList.add(ex);
    }

    /**
     * <p>Add to exercise list a rest period of the given duration.</p>
     *
     * @param duration duration, in seconds, of rest period
     */
    public void addRest(int duration) {
        exerciseList.add(Record.recordForRest(duration));
    }

    /**
     * <p>Helper method to create a number of copies of the given exercise,
     * interleaved with pauses, based on the given number of reps.</p>
     *
     * @param exercise      the exercise to be inserted
     * @param reps          number of reps for given exercise
     * @param duration      duration of a single rep (if hitsPerRep not given)
     * @param hitsPerRep    number of hits for each rep (if duration not given)
     * @param restDuration  seconds of rest between each rep
     * @throws ConflictException
     */
    public void addRepsForExercise(Exercise exercise, int reps, int duration,
                                   int hitsPerRep, int restDuration)
            throws ConflictException {
        for (int i = 0; i < reps; i++) {
            addExercise(Record.recordForExercise(exercise.getName(),
                    duration, hitsPerRep));
            if (restDuration > 0)
                addRest(restDuration);
        }
    }

    /**
     * <p>Helper method to create a <i>superset</i> of exercises,
     * potentially interleaved with rest periods, from the given exercise
     * list.</p>
     *
     * @param exerciseList  list of exercises to add to the exercise list
     * @param rests         list of rests duration -- pauses with a duration
     *                      of 0 are skipped
     * @throws ConflictException
     */
    public void addSuperSet(List<Record> exerciseList, int[] rests)
            throws ConflictException {
        if (exerciseList.size() != rests.length)
            throw new ConflictException(String.format("Wrong rest time list " +
                            "size: %d expected, got %d", exerciseList.size(),
                    rests.length));

        int index = 0;
        for (Record record : exerciseList) {
            addExercise(record);
            if (rests[index] != 0)
                addRest(rests[index]);
            index++;
        }

    }

}
