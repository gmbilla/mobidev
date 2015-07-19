package it.mobidev.backend.data;

/**
 * Custom version of an {@link it.mobidev.backend.data.Exercise} to represent
 * the pause between two exercise.
 */
public class Rest extends Exercise {

    public static final String KEY_ID = "Rest";

    public Rest() {
        this.name = KEY_ID;
        this.description = "";
    }

}
