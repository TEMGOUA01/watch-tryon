const functions = require("firebase-functions/v2");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Triggered when a new signal document is created.
 * Sends a push notification to all subscribers of the "signals" topic.
 */
exports.onNewSignal = functions.firestore.onDocumentCreated(
  "signals/{signalId}",
  async (event) => {
    const signal = event.data?.data();
    if (!signal) return;

    const type = signal.type ?? "BUY";
    const symbol = signal.symbol ?? "XAUUSD";
    const createdBy = signal.createdBy ?? "Admin";
    const aiTag = createdBy === "AI" ? "🤖 " : "";

    const message = {
      topic: "signals",
      notification: {
        title: `📊 ${aiTag}Nouveau signal ${symbol}`,
        body: `${type} — Entrée: ${signal.entryPrice} | Confiance: ${signal.confidence}%`,
      },
      data: {
        type: type,
        symbol: symbol,
        screen: "signals",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "aureus_signals_channel",
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log("Notification sent:", response);
    } catch (error) {
      console.error("Error sending notification:", error);
    }
  }
);

exports.validateMiningTransaction = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentification requise.");
  }

  const adminEmail = "tem@gmail.com";
  const callerEmail = request.auth.token.email || "";
  if (callerEmail !== adminEmail) {
    throw new HttpsError("permission-denied", "Action reservee a l'admin.");
  }

  const transactionId = request.data?.transactionId;
  const nextStatus = request.data?.status;
  const adminNote = request.data?.adminNote || null;

  if (!transactionId || typeof transactionId !== "string") {
    throw new HttpsError("invalid-argument", "transactionId invalide.");
  }
  if (!["success", "rejected"].includes(nextStatus)) {
    throw new HttpsError("invalid-argument", "status invalide.");
  }

  const db = admin.firestore();
  const txRef = db.collection("transactions").doc(transactionId);

  await db.runTransaction(async (txn) => {
    const txDoc = await txn.get(txRef);
    if (!txDoc.exists) {
      throw new HttpsError("not-found", "Transaction introuvable.");
    }

    const txData = txDoc.data() || {};
    const currentStatus = txData.statut || "pending";
    if (currentStatus === "success") return;
    if (currentStatus !== "pending") {
      throw new HttpsError("failed-precondition", "Transaction non traitable.");
    }

    const machineRef = db.collection("machines").doc(txData.machineId);
    const machineDoc = await txn.get(machineRef);
    if (!machineDoc.exists) {
      throw new HttpsError("not-found", "Machine introuvable.");
    }
    const machineData = machineDoc.data() || {};

    if (nextStatus === "success") {
      const userMachineRef = db
          .collection("users")
          .doc(txData.userId)
          .collection("machines")
          .doc(transactionId);

      txn.set(userMachineRef, {
        machineId: txData.machineId,
        niveau: machineData.niveau || 0,
        dateAchat: admin.firestore.FieldValue.serverTimestamp(),
        statutActif: true,
        sourceTransactionId: transactionId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      }, {merge: true});
    }

    txn.update(txRef, {
      statut: nextStatus,
      adminNote: adminNote,
      validatedBy: request.auth.uid,
      validatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return {ok: true};
});
