package com.kalestenika.backend.data;

import com.googlecode.objectify.annotation.Subclass;
import com.kalestenika.backend.Constants;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.logging.Logger;

/**
 * Class representing an exercise
 */
@Subclass(index = true)
@NoArgsConstructor
public class Exercise extends Entry {

    private static final Logger Log = Logger.getLogger("Exercise");

    @Getter @Setter String description;
    @Getter @Setter String videoURL;
    @Getter @Setter int estDuration;
    @Getter @Setter Constants.Requirement requirement;

    public Exercise(String name, String description, String videoURL,
                    int estDuration, Constants.Requirement requirement) {
        this.name = name;
        this.description = description;
        this.videoURL = videoURL;
        this.estDuration = estDuration;
        this.requirement = requirement;
    }

}
