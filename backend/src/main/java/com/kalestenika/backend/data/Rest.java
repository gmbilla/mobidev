package com.kalestenika.backend.data;

import com.googlecode.objectify.annotation.Subclass;

/**
 * Custom version of an {@link com.kalestenika.backend.data.Entry} to represent
 * the pause between two {@link com.kalestenika.backend.data.Exercise}.
 */
@Subclass(index=true)
public class Rest extends Entry {

    public static final String KEY_ID = "Rest";

    public Rest() {
        this.name = KEY_ID;
    }

}
