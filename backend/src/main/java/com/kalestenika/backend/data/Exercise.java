package com.kalestenika.backend.data;

import com.googlecode.objectify.annotation.Subclass;
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
    @Getter @Setter String link;
    @Getter @Setter int estDuration;

    public Exercise(String name, String description, String link, int estDuration) {
        this.name = name;
        this.description = description;
        this.link = link;
        this.estDuration = estDuration;
    }

}
