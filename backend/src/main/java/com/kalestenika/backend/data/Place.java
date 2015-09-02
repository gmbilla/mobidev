package com.kalestenika.backend.data;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import com.googlecode.objectify.annotation.Index;
import lombok.Data;

/**
 * Entity representing a training place signaled by a user
 */
@Entity
@Data
public class Place {

    @Id Long id;
    String creator;
    @Index String address;
    LatLng position;
    String name;
    // TODO add available facilities (requirements)
    ///** Available structures */
    //List<String> structures;

}
