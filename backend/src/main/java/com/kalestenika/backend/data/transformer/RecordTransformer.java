package com.kalestenika.backend.data.transformer;

import com.google.api.server.spi.config.Transformer;
import com.google.gson.Gson;
import com.kalestenika.backend.data.Record;

/**
 * <p>Class implementing {@link com.google.api.server.spi.config.Transformer} to
 * allow to/from string (JSON) serialization.</p>
 *
 * <p><b>N.B.</b> {@link com.kalestenika.backend.data.Record} cannot be used as a
 * return type for an API method, but can be used as a parameter.</p>
 */
public class RecordTransformer implements Transformer<Record, String> {

    @Override
    public String transformTo(Record record) {
        return new Gson().toJson(record);
    }

    @Override
    public Record transformFrom(String json) {
        return new Gson().fromJson(json, Record.class);
    }

}
