package it.mobidev.backend.data;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import lombok.Data;

import java.util.logging.Logger;

/**
 * Record of an exercise/rest inside a workout
 */
@Entity
@Data
public abstract class Record {

    protected static final Logger Log = Logger.getLogger("Record");

    @Id Long id;
    /** Exercise entry for this record */
    Entry exercise;
    /** Duration in second of the exercise in each rep */
    int duration;

}
