const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendTaskNotification = functions.firestore
  .document("users/{userId}/tasks/{taskId}")
  .onCreate(async (snap, context) => {
    const task = snap.data();

    if (!task || !task.title) {
      console.warn("⚠️ No task title found in the document");
      return null;
    }

    const title = task.title;

    const message = {
      notification: {
        title: "🆕 New Task",
        body: title,
      },
      topic: "tasks", // Clients must subscribe to this topic
    };

    try {
      const response = await admin.messaging().send(message);
      console.log("✅ Notification sent successfully:", response);
    } catch (error) {
      console.error("❌ Error sending notification:", error);
    }

    return null; // Firebase Functions require returning a Promise or null
  });
