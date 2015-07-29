package it.mobidev.backend.data;

import com.google.api.server.spi.response.ConflictException;
import com.googlecode.objectify.annotation.Subclass;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

/**
 * Exercise record inside a workout
 */
@Subclass(index = true)
@EqualsAndHashCode(callSuper = false)
public class ExerciseRecord extends Record {

    /** How many times should the exercise be done in each rep */
    @Getter @Setter int hitsPerRep;

    public static ExerciseRecord recordForExercise(Exercise exercise,
                                                   int duration, int hitsPerRep)
            throws ConflictException {
        if (duration != 0 && hitsPerRep != 0)
            throw new ConflictException("An exercise can either have a " +
                    "duration value or number of hit per reps.");

        ExerciseRecord record = new ExerciseRecord();
        record.setExercise(exercise);
        if (duration != 0)
            record.setDuration(duration);
        else
            record.setHitsPerRep(hitsPerRep);

        return record;
    }

    @Override
    public String toString() {
        return exercise.getName() + " " +
                (duration != 0 ? duration + "s" : "x" + hitsPerRep);
    }

}
