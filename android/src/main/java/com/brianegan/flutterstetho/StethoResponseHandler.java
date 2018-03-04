package com.brianegan.flutterstetho;

import com.facebook.stetho.inspector.network.NetworkEventReporter;
import com.facebook.stetho.inspector.network.ResponseHandler;

import java.io.IOException;

public class StethoResponseHandler implements ResponseHandler {
    private final NetworkEventReporter mEventReporter;
    private final String mRequestId;

    private int mBytesRead = 0;
    private int mDecodedBytesRead = -1;

    public StethoResponseHandler(NetworkEventReporter eventReporter, String requestId) {
        mEventReporter = eventReporter;
        mRequestId = requestId;
    }

    @Override
    public void onRead(int numBytes) {
        System.out.println("onRead: " + numBytes);
        mBytesRead += numBytes;
    }

    @Override
    public void onReadDecoded(int numBytes) {
        System.out.println("onReadDecoded: " + numBytes);
        if (mDecodedBytesRead == -1) {
            mDecodedBytesRead = 0;
        }
        mDecodedBytesRead += numBytes;
    }

    public void onEOF() {
        System.out.println("onEOF");
        reportDataReceived();
        mEventReporter.responseReadFinished(mRequestId);
    }

    public void onError(IOException e) {
        System.out.println("onError");
        reportDataReceived();
        mEventReporter.responseReadFailed(mRequestId, e.toString());
    }

    private void reportDataReceived() {
        mEventReporter.dataReceived(
                mRequestId,
                mBytesRead,
                mDecodedBytesRead >= 0 ? mDecodedBytesRead : mBytesRead);
    }
}