package it.mobidev.backend.data;

import com.googlecode.objectify.Key;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import com.googlecode.objectify.annotation.Index;
import com.googlecode.objectify.annotation.Parent;
import lombok.Data;

import java.util.List;

/**
 * Entity rappresenting a training place signaled by a user
 */
@Entity
@Data
public class Place {

    @Id Long id;
//    @Parent Key<User> creator;
    @Index String address;
    LatLng position;
    String name;
    /** Available structures */
    List<String> structures;

}
