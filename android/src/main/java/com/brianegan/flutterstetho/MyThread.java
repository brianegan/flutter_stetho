package com.brianegan.flutterstetho;

import android.util.Log;

import java.io.IOException;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;

class MyThread extends Thread {
    private final String id;
    private PipedInputStream pr;
    private PipedOutputStream pw;
    private byte[] data;

    MyThread(String id, PipedOutputStream pw, PipedInputStream pr) {
        super(id);

        this.id = id;

        this.pr = pr;
        this.pw = pw;
        this.data = data;
    }

    public void run() {
        try {
            if (getName().equals("src")) {
                for (Integer i = 0; i < 15; i++)
                    pw.write(new byte[]{i.byteValue()}); // src writes

                pw.close();
            } else {
                int item;
                while ((item = pr.read()) != -1)
                    Log.wtf(FlutterStethoPlugin.TAG, Integer.valueOf(item).toString());    // dst reads

                pr.close();
            }
        } catch (IOException e) {
        }
    }
}
