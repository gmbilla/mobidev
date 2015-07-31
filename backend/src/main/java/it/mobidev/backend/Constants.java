package it.mobidev.backend;

/**
 * Contains the client IDs and scopes for allowed clients consuming your API.
 */
public class Constants {

    public static final String WEB_CLIENT_ID = "750859415890-gtb3anfc7255kv9t2lthne981hinkjcr.apps.googleusercontent.com";
    public static final String ANDROID_CLIENT_ID = "replace this with your Android client ID";
    public static final String IOS_CLIENT_ID = "replace this with your iOS client ID";
    public static final String ANDROID_AUDIENCE = WEB_CLIENT_ID;

    public static final String EMAIL_SCOPE = "https://www.googleapis.com/auth/userinfo.email";

    public enum Rank {
    VERY_BAD, BAD, NORMAL, GOOD, VERY_GOOD
    }

}
