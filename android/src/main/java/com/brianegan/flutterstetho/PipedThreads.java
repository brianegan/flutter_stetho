package com.brianegan.flutterstetho;

import java.io.IOException;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;

class PipedThreads {
    public static void main(String[] args) throws IOException {
        PipedInputStream pr = new PipedInputStream();
        PipedOutputStream pw = new PipedOutputStream(pr);

        MyThread mt1 = new MyThread("src", pw, pr);
        MyThread mt2 = new MyThread("dst", pw, pr);

        mt2.start();
        mt1.start();
    }
}