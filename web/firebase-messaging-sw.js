/* eslint-disable no-undef */
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyDcheU0C1Mz4wII_94ZIw01UiQ8o7RykUo",
    authDomain: "loyalty-card-e5c91.firebaseapp.com",
    projectId: "loyalty-card-e5c91",
    storageBucket: "loyalty-card-e5c91.firebasestorage.app",
    messagingSenderId: "33204887292",
    appId: "1:33204887292:web:308813feeeef68bda1c179",
    measurementId: "G-3568043V0T"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    // Customize notification here
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/icons/Icon-192.png'
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});
