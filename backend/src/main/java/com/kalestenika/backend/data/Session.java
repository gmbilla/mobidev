package com.kalestenika.backend.data;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import com.googlecode.objectify.annotation.Index;
import com.kalestenika.backend.Constants.Rank;
import lombok.Data;

import java.util.Date;

/**
 * Entity representing a (completed) session of a particular workout
 */
@Entity
@Data
public class Session {

    @Id Long id;
    /**
     * The user that did the workout
     */
    @Index String userId;
    /**
     * Workout completed in the session.
     */
    @Index Long workoutId;
    /**
     * Date and time when the workout was done.
     */
    Date when = new Date();
    /**
     * Store the ID of the place where the workout was done.
     */
    Long where;
    /**
     * Vote given by the user on her session performances.
     */
    Rank vote;
    /**
     * Duration of session
     */
    Integer duration;
    /**
     * Percentage of completion
     */
    Integer completion;

}
