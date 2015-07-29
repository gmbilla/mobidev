package it.mobidev.backend.data;

import com.googlecode.objectify.Key;
import com.googlecode.objectify.annotation.Subclass;

/**
 * Workout record for rest
 */
@Subclass(index = true)
public class RestRecord extends Record {

    public RestRecord() {
        this(0);
    }

    public RestRecord(int duration) {
        exercise = Key.create(Rest.class, Rest.KEY_ID);
        this.duration = duration;
    }

    @Override
    public String toString() {
        return "Rest " + duration + "s";
    }
}
