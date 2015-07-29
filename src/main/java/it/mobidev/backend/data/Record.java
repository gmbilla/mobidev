package it.mobidev.backend.data;

import com.google.api.server.spi.response.ConflictException;
import lombok.Data;

import java.util.logging.Logger;

/**
 * Exercise record inside a workout
 */
@Data
public class Record {

    protected static final Logger Log = Logger.getLogger("Record");

    /** Exercise entry for this record */
    private String exercise;
    /** Duration in second of the exercise in each rep */
    private int duration = 0;
    /** How many times should the exercise be done in each rep */
    private int hitsPerRep = 0;

    public static Record recordForExercise(String exerciseName,
                                                   int duration, int hitsPerRep)
            throws ConflictException {
        if (duration != 0 && hitsPerRep != 0)
            throw new ConflictException("An exercise can either have a " +
                    "duration value or number of hit per reps.");

        Record record = new Record();
        record.setExercise(exerciseName);
        if (duration != 0)
            record.setDuration(duration);
        else
            record.setHitsPerRep(hitsPerRep);

        return record;
    }

    public static Record recordForRest(int duration) {
        Record record = new Record();
        record.setExercise(Rest.KEY_ID);
        record.setDuration(duration);

        return record;
    }

    @Override
    public String toString() {
        return exercise + " " +
                (duration != 0 ? duration + "s" : "x" + hitsPerRep);
    }

}
