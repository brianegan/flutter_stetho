package com.brianegan.flutterstetho;

import com.facebook.stetho.inspector.network.NetworkEventReporter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.annotation.Nullable;

class FlutterStethoInspectorRequest implements NetworkEventReporter.InspectorRequest {
    private final Map<String, Object> map;

    FlutterStethoInspectorRequest(Map<String, Object> map) {
        this.map = map;
    }

    @Nullable
    @Override
    public Integer friendlyNameExtra() {
        if (map.get("friendlyNameExtra") != null) {
            return ((Integer) map.get("friendlyNameExtra"));
        }

        return null;
    }

    @Override
    public String url() {
        return ((String) map.get("url"));
    }

    @Override
    public String method() {
        return ((String) map.get("method"));
    }

    @Nullable
    @Override
    public byte[] body() throws IOException {
        if (map.get("body") != null) {
            List<Integer> body = ((List<Integer>) map.get("body"));
            byte[] bytes = new byte[body.size()];
            for (int i = 0; i < body.size(); i++) {
                bytes[i] = body.get(i).byteValue();
            }
            return bytes;
        }

        return null;
    }

    @Override
    public String id() {
        return ((String) map.get("id"));
    }

    @Override
    public String friendlyName() {
        return ((String) map.get("friendlyName"));
    }

    @Override
    public int headerCount() {
        return getHeaders().size();
    }

    @Override
    public String headerName(int index) {
        final List<String> list = new ArrayList<String>(getHeaders().keySet());

        return list.get(index);
    }

    @Override
    public String headerValue(int index) {
        final List<String> list = new ArrayList<String>(getHeaders().values());

        return list.get(index);
    }

    @Nullable
    @Override
    public String firstHeaderValue(String name) {
        if (getHeaders().get(name) != null) {
            return getHeaders().get(name);
        }
        return null;
    }

    private Map<String, String> getHeaders() {
        return ((Map<String, String>) map.get("headers"));
    }
}
