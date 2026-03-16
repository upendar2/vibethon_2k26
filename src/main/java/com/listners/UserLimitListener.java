package com.listners;

import jakarta.servlet.annotation.WebListener;
import jakarta.servlet.http.HttpSessionEvent;
import jakarta.servlet.http.HttpSessionListener;
import java.util.concurrent.atomic.AtomicInteger;

@WebListener
public class UserLimitListener implements HttpSessionListener {

    // AtomicInteger is thread-safe for high-traffic sites
    private static final AtomicInteger activeSessions = new AtomicInteger(0);
    private static final int MAX_USERS = 7;

    @Override
    public void sessionCreated(HttpSessionEvent se) {
        activeSessions.incrementAndGet();
        System.out.println("Session Created. Active Users: " + activeSessions.get());
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        activeSessions.decrementAndGet();
        System.out.println("Session Destroyed. Active Users: " + activeSessions.get());
    }

    public static boolean isServerBusy() {
        return activeSessions.get() > MAX_USERS;
    }

    public static int getActiveCount() {
        return activeSessions.get();
    }
}