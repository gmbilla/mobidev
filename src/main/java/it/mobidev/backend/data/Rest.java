package it.mobidev.backend.data;

import com.googlecode.objectify.annotation.Subclass;

/**
 * Custom version of an {@link it.mobidev.backend.data.Entry} to represent
 * the pause between two {@link it.mobidev.backend.data.Exercise}.
 */
@Subclass(index=true)
public class Rest extends Entry {

    public static final String KEY_ID = "Rest";

    public Rest() {
        this.name = KEY_ID;
    }

}
