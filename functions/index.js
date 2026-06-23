const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.setAdminClaim = functions.https.onCall((data, context) => {
  
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Login required');
  }

  const userId = data.userId;
  
  if (!userId) {
    throw new functions.https.HttpsError('invalid-argument', 'userId required');
  }

  return admin.auth().setCustomUserClaims(userId, { admin: true }).then(() => {
    return { success: true };
  });
});