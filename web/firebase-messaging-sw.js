
importScripts("https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: 'AIzaSyA45iORcyaB00Gc-bq-Udv-3ZBw6U2sPYw',
    appId: '1:121550341573:web:d7c657c36c4dc672c077ac',
    messagingSenderId: '121550341573',
    projectId: 'laptop-harbor-3c6cd',
    authDomain: 'laptop-harbor-3c6cd.firebaseapp.com',
    storageBucket: 'laptop-harbor-3c6cd.firebasestorage.app',
    measurementId: 'G-LQQ6ZF05SD',
});

const messaging = firebase.messaging();
