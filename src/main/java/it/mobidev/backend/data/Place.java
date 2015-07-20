package it.mobidev.backend.data;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import com.googlecode.objectify.annotation.Index;
import lombok.Data;

import java.util.List;

/**
 * Entity representing a training place signaled by a user
 */
@Entity
@Data
public class Place {

    @Id Long id;
//    User creator;
    @Index String address;
    LatLng position;
    String name;
    /** Available structures */
    List<String> structures;

}
