package com.kalestenika.backend.data;

import com.google.api.server.spi.response.ConflictException;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import com.googlecode.objectify.annotation.Index;
import lombok.Data;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.logging.Logger;

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
    String name;
    Date dateCreated = null;
    List<Record> exerciseList = new ArrayList<>();

    //==========================================================================
    // Helpers
    //==========================================================================

    /**
     * <p>Add given exercise to exercise list.</p>
     *
     * @param ex a {@link Record} describing the
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
