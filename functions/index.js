/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendScheduledNotification = functions.pubsub.schedule("0 20 * * *")
    .timeZone("Asia/Seoul") // 시간대 설정
    .onRun((context) => {
      const payload = {
        notification: {
          title: "Daily Reminder",
          body: "This is your daily notification at 8 PM!",
        },
        topic: "daily-notifications",
      };

      return admin.messaging().send(payload)
          .then((response) => {
            console.log("Successfully sent message:", response);
          })
          .catch((error) => {
            console.log("Error sending message:", error);
          });
    });


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
