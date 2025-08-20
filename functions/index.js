const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.onOrderStatusChange = functions.firestore
    .document("users/{userId}/orders/{orderId}")
    .onUpdate(async (change, context) => {
      const newValue = change.after.data();
      const previousValue = change.before.data();

      if (newValue.status !== previousValue.status) {
        const userId = context.params.userId;
        const userDoc = await admin.firestore().collection("users").doc(userId).get();
        const fcmToken = userDoc.data().profile.fcmToken;

        if (fcmToken) {
          const payload = {
            notification: {
              title: "Order Status Changed",
              body: `Your order #${context.params.orderId} is now ${newValue.status}`,
            },
          };

          try {
            await admin.messaging().sendToDevice(fcmToken, payload);
            console.log("Notification sent successfully");
          } catch (error) {
            console.log("Error sending notification:", error);
          }
        }
      }
    });
