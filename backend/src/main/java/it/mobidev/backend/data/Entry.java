package it.mobidev.backend.data;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import lombok.Data;

/**
 * Entry for a single exercise or rest period.
 */
@Entity
@Data
public abstract class Entry {

    @Id String name;

}
