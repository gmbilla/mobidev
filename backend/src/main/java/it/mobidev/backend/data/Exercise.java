package it.mobidev.backend.data;

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

    public Exercise(String name, String description) {
        this.name = name;
        this.description = description;
    }

}
