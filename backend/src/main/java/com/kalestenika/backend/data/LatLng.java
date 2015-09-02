package com.kalestenika.backend.data;

/**
 * Simple wrapper class to present a latitude, longitude couple
 */
public class LatLng {

    private static final String SEPARATOR = ",";

    double latitude;
    double longitude;

    public static LatLng fromString(String latLng) {
        String[] segments = latLng.split(SEPARATOR);
        LatLng ll = new LatLng();

        if (segments.length == 2) {
            ll.latitude = Double.parseDouble(segments[0]);
            ll.longitude = Double.parseDouble(segments[1]);
        }

        return ll;
    }

    public String toString() {
        return String.format("%s,%s", latitude, longitude);
    }

}
