const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const cors = require("cors")({origin: true});

admin.initializeApp();

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: functions.config().gmail.email,
    pass: functions.config().gmail.password,
  },
});

exports.sendEmail = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    const {to, subject, html} = req.body;

    const mailOptions = {
      from: "Your Name <your-email@gmail.com>",
      to,
      subject,
      html,
    };

    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        return res.status(500).send(error.toString());
      }
      return res.status(200).send("Email sent: " + info.response);
    });
  });
});

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
