package com.brianegan.flutterstetho;

import com.facebook.stetho.inspector.network.NetworkEventReporter;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.annotation.Nullable;

class FlutterStethoInspectorResponse implements NetworkEventReporter.InspectorResponse {
    private final Map<String, Object> map;

    FlutterStethoInspectorResponse(Map<String, Object> map) {
        this.map = map;
    }

    @Override
    public String url() {
        return ((String) map.get("url"));
    }

    @Override
    public boolean connectionReused() {
        return ((boolean) map.get("connectionReused"));
    }

    @Override
    public int connectionId() {
        return ((int) map.get("connectionId"));
    }

    @Override
    public boolean fromDiskCache() {
        return ((boolean) map.get("fromDiskCache"));
    }

    @Override
    public String requestId() {
        return ((String) map.get("requestId"));
    }

    @Override
    public int statusCode() {
        return ((int) map.get("statusCode"));
    }

    @Override
    public String reasonPhrase() {
        return ((String) map.get("reasonPhrase"));
    }

    @Override
    public int headerCount() {
        return getHeaders().size();
    }

    @Override
    public String headerName(int index) {
        final List<String> list = new ArrayList<>(getHeaders().keySet());

        return list.get(index);
    }

    @Override
    public String headerValue(int index) {
        final List<String> list = new ArrayList<>(getHeaders().values());

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
