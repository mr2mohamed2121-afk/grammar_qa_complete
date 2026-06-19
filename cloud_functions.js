
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

// ============================================
// SECURITY MIDDLEWARE
// ============================================

// Validate admin claims
async function verifyAdmin(uid) {
  const userDoc = await db.collection('users').doc(uid).get();
  if (!userDoc.exists || !userDoc.data().isAdmin) {
    throw new Error('Unauthorized: Admin access required');
  }
  return true;
}

// Validate user ownership
async function verifyOwnership(uid, resourceUserId) {
  if (uid !== resourceUserId) {
    await verifyAdmin(uid);
  }
  return true;
}

// ============================================
// POINTS SYSTEM
// ============================================

// Award points for watching ads
exports.awardAdPoints = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const userId = context.auth.uid;
  const { adType, multiplier = 1 } = data;

  // Points configuration
  const pointsConfig = {
    'banner': 5,
    'interstitial': 15,
    'rewarded': 30,
    'native': 10
  };

  const basePoints = pointsConfig[adType] || 0;
  const totalPoints = basePoints * multiplier;

  // Update user points
  const userPointsRef = db.collection('user_points').doc(userId);

  await db.runTransaction(async (transaction) => {
    const doc = await transaction.get(userPointsRef);

    if (!doc.exists) {
      transaction.set(userPointsRef, {
        userId: userId,
        totalPoints: totalPoints,
        lifetimePoints: totalPoints,
        streakDays: 1,
        lastStudyDate: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      });
    } else {
      const currentData = doc.data();
      const newTotal = (currentData.totalPoints || 0) + totalPoints;
      const newLifetime = (currentData.lifetimePoints || 0) + totalPoints;

      transaction.update(userPointsRef, {
        totalPoints: newTotal,
        lifetimePoints: newLifetime,
        updatedAt: admin.firestore.Timestamp.now()
      });
    }
  });

  // Log for admin
  await db.collection('admin_logs').add({
    type: 'points_awarded',
    userId: userId,
    adType: adType,
    points: totalPoints,
    timestamp: admin.firestore.Timestamp.now()
  });

  return { success: true, pointsAwarded: totalPoints };
});

// Redeem points for rewards
exports.redeemPoints = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const userId = context.auth.uid;
  const { rewardType } = data;

  // Rewards configuration
  const rewardsConfig = {
    '5_flashcards': { points: 100, value: 0.50 },
    'remove_ads_day': { points: 500, value: 1.00 },
    'premium_month': { points: 1000, value: 4.99 },
    'premium_year': { points: 5000, value: 49.99 },
    'unlimited_cards': { points: 10000, value: 99.99 }
  };

  const reward = rewardsConfig[rewardType];
  if (!reward) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid reward type');
  }

  const userPointsRef = db.collection('user_points').doc(userId);

  return await db.runTransaction(async (transaction) => {
    const doc = await transaction.get(userPointsRef);

    if (!doc.exists || (doc.data().totalPoints || 0) < reward.points) {
      throw new functions.https.HttpsError('failed-precondition', 'Insufficient points');
    }

    const currentPoints = doc.data().totalPoints;

    // Deduct points
    transaction.update(userPointsRef, {
      totalPoints: currentPoints - reward.points,
      updatedAt: admin.firestore.Timestamp.now()
    });

    // Create reward record
    const rewardRef = db.collection('user_rewards').doc();
    transaction.set(rewardRef, {
      userId: userId,
      rewardType: rewardType,
      pointsSpent: reward.points,
      value: reward.value,
      status: 'active',
      createdAt: admin.firestore.Timestamp.now(),
      expiresAt: rewardType.includes('month') 
        ? admin.firestore.Timestamp.fromDate(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000))
        : rewardType.includes('year')
        ? admin.firestore.Timestamp.fromDate(new Date(Date.now() + 365 * 24 * 60 * 60 * 1000))
        : null
    });

    return { success: true, remainingPoints: currentPoints - reward.points };
  });
});

// ============================================
// STREAK SYSTEM
// ============================================

// Update study streak
exports.updateStreak = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const userId = context.auth.uid;
  const userPointsRef = db.collection('user_points').doc(userId);

  const now = admin.firestore.Timestamp.now();
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  return await db.runTransaction(async (transaction) => {
    const doc = await transaction.get(userPointsRef);

    if (!doc.exists) {
      transaction.set(userPointsRef, {
        userId: userId,
        totalPoints: 0,
        lifetimePoints: 0,
        streakDays: 1,
        lastStudyDate: now,
        longestStreak: 1,
        updatedAt: now
      });
      return { streak: 1, isNewDay: true };
    }

    const data = doc.data();
    const lastStudy = data.lastStudyDate?.toDate() || new Date(0);
    const lastStudyDay = new Date(lastStudy);
    lastStudyDay.setHours(0, 0, 0, 0);

    const diffTime = today - lastStudyDay;
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

    let newStreak = data.streakDays || 0;
    let isNewDay = false;

    if (diffDays === 1) {
      // Consecutive day
      newStreak += 1;
      isNewDay = true;
    } else if (diffDays > 1) {
      // Streak broken
      newStreak = 1;
      isNewDay = true;
    }
    // diffDays === 0 means same day, no change

    const longestStreak = Math.max(newStreak, data.longestStreak || 0);

    transaction.update(userPointsRef, {
      streakDays: newStreak,
      lastStudyDate: now,
      longestStreak: longestStreak,
      updatedAt: now
    });

    return { streak: newStreak, isNewDay: isNewDay, longestStreak: longestStreak };
  });
});

// Reset streak warning (called when user tries to exit without completing daily goal)
exports.checkStreakWarning = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const userId = context.auth.uid;
  const userPointsRef = db.collection('user_points').doc(userId);
  const doc = await userPointsRef.get();

  if (!doc.exists) return { showWarning: false };

  const data = doc.data();
  const lastStudy = data.lastStudyDate?.toDate() || new Date(0);
  const lastStudyDay = new Date(lastStudy);
  lastStudyDay.setHours(0, 0, 0, 0);

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const diffTime = today - lastStudyDay;
  const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

  // Show warning if streak is active and user hasn't studied today
  const showWarning = data.streakDays > 0 && diffDays >= 1;

  return { 
    showWarning: showWarning, 
    currentStreak: data.streakDays,
    daysMissed: diffDays 
  };
});

// ============================================
// LEADERBOARD
// ============================================

// Update leaderboard
exports.updateLeaderboard = functions.firestore
  .document('quiz_results/{resultId}')
  .onCreate(async (snap, context) => {
    const result = snap.data();
    const userId = result.userId;

    // Get user info
    const userDoc = await db.collection('users').doc(userId).get();
    const userData = userDoc.exists ? userDoc.data() : {};

    // Calculate total score for user
    const resultsSnapshot = await db.collection('quiz_results')
      .where('userId', '==', userId)
      .get();

    let totalScore = 0;
    let totalCorrect = 0;
    let totalQuestions = 0;

    resultsSnapshot.forEach(doc => {
      const data = doc.data();
      totalScore += data.score || 0;
      totalCorrect += data.correctAnswers || 0;
      totalQuestions += data.totalQuestions || 0;
    });

    const accuracy = totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0;

    // Update or create leaderboard entry
    const leaderboardRef = db.collection('leaderboard').doc(userId);
    await leaderboardRef.set({
      userId: userId,
      name: userData.name || 'Unknown',
      photoUrl: userData.photoUrl || null,
      totalScore: totalScore,
      totalQuizzes: resultsSnapshot.size,
      accuracy: Math.round(accuracy * 100) / 100,
      streakDays: userData.streakDays || 0,
      updatedAt: admin.firestore.Timestamp.now()
    }, { merge: true });

    return null;
  });

// Get top 10 leaderboard
exports.getLeaderboard = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const leaderboardSnapshot = await db.collection('leaderboard')
    .orderBy('totalScore', 'desc')
    .limit(10)
    .get();

  const leaderboard = leaderboardSnapshot.docs.map((doc, index) => ({
    rank: index + 1,
    ...doc.data()
  }));

  return { leaderboard: leaderboard };
});

// ============================================
// PAYMENT WEBHOOKS
// ============================================

// Paymob webhook
exports.paymobWebhook = functions.https.onRequest(async (req, res) => {
  try {
    const { order, payment_token, success, userId, planType } = req.body;

    if (!success) {
      res.status(400).json({ error: 'Payment failed' });
      return;
    }

    // Verify payment with Paymob (in production, add HMAC verification)

    // Create payment record
    const paymentRef = db.collection('payments').doc();
    await paymentRef.set({
      userId: userId,
      provider: 'paymob',
      orderId: order.id,
      amount: order.amount_cents / 100,
      currency: 'EGP',
      planType: planType,
      status: 'completed',
      createdAt: admin.firestore.Timestamp.now()
    });

    // Activate subscription
    const subscriptionRef = db.collection('subscriptions').doc();
    const now = admin.firestore.Timestamp.now();
    const expiresAt = planType === 'monthly' 
      ? admin.firestore.Timestamp.fromDate(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000))
      : planType === 'yearly'
      ? admin.firestore.Timestamp.fromDate(new Date(Date.now() + 365 * 24 * 60 * 60 * 1000))
      : null;

    await subscriptionRef.set({
      userId: userId,
      planType: planType,
      paymentId: paymentRef.id,
      status: 'active',
      startedAt: now,
      expiresAt: expiresAt,
      createdAt: now
    });

    // Update user to premium
    await db.collection('users').doc(userId).update({
      isPremium: true,
      premiumPlan: planType,
      premiumExpiresAt: expiresAt
    });

    res.status(200).json({ success: true });
  } catch (error) {
    console.error('Paymob webhook error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// In-App Purchase webhook (Google Play / App Store)
exports.inAppPurchaseWebhook = functions.https.onRequest(async (req, res) => {
  try {
    const { userId, productId, purchaseToken, platform } = req.body;

    // Verify purchase with Google/Apple (in production)

    const planType = productId.includes('monthly') ? 'monthly' : 
                     productId.includes('yearly') ? 'yearly' : 'cards';

    // Create payment record
    const paymentRef = db.collection('payments').doc();
    await paymentRef.set({
      userId: userId,
      provider: platform,
      productId: productId,
      purchaseToken: purchaseToken,
      planType: planType,
      status: 'completed',
      createdAt: admin.firestore.Timestamp.now()
    });

    if (planType === 'cards') {
      // Add cards to user account
      const cardCount = productId.includes('50') ? 50 : 100;
      const userRef = db.collection('users').doc(userId);
      await userRef.update({
        availableCards: admin.firestore.FieldValue.increment(cardCount)
      });
    } else {
      // Activate subscription
      const now = admin.firestore.Timestamp.now();
      const expiresAt = planType === 'monthly' 
        ? admin.firestore.Timestamp.fromDate(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000))
        : admin.firestore.Timestamp.fromDate(new Date(Date.now() + 365 * 24 * 60 * 60 * 1000));

      const subscriptionRef = db.collection('subscriptions').doc();
      await subscriptionRef.set({
        userId: userId,
        planType: planType,
        paymentId: paymentRef.id,
        status: 'active',
        startedAt: now,
        expiresAt: expiresAt,
        createdAt: now
      });

      await db.collection('users').doc(userId).update({
        isPremium: true,
        premiumPlan: planType,
        premiumExpiresAt: expiresAt
      });
    }

    res.status(200).json({ success: true });
  } catch (error) {
    console.error('IAP webhook error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ============================================
// ADMIN FUNCTIONS
// ============================================

// Get admin dashboard stats
exports.getAdminStats = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  await verifyAdmin(context.auth.uid);

  const [usersSnap, questionsSnap, resultsSnap, paymentsSnap] = await Promise.all([
    db.collection('users').count().get(),
    db.collection('questions').count().get(),
    db.collection('quiz_results').count().get(),
    db.collection('payments').where('status', '==', 'completed').get()
  ]);

  const totalRevenue = paymentsSnap.docs.reduce((sum, doc) => sum + (doc.data().amount || 0), 0);

  return {
    totalUsers: usersSnap.data().count,
    totalQuestions: questionsSnap.data().count,
    totalQuizzes: resultsSnap.data().count,
    totalRevenue: totalRevenue,
    totalPayments: paymentsSnap.size
  };
});

// Admin: Create question
exports.adminCreateQuestion = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  await verifyAdmin(context.auth.uid);

  const questionRef = db.collection('questions').doc();
  await questionRef.set({
    ...data,
    id: questionRef.id,
    createdAt: admin.firestore.Timestamp.now(),
    createdBy: context.auth.uid
  });

  // Log admin action
  await db.collection('admin_logs').add({
    type: 'question_created',
    adminId: context.auth.uid,
    questionId: questionRef.id,
    timestamp: admin.firestore.Timestamp.now()
  });

  return { success: true, questionId: questionRef.id };
});

// Admin: Update question
exports.adminUpdateQuestion = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  await verifyAdmin(context.auth.uid);

  const { questionId, ...updates } = data;

  await db.collection('questions').doc(questionId).update({
    ...updates,
    updatedAt: admin.firestore.Timestamp.now(),
    updatedBy: context.auth.uid
  });

  await db.collection('admin_logs').add({
    type: 'question_updated',
    adminId: context.auth.uid,
    questionId: questionId,
    timestamp: admin.firestore.Timestamp.now()
  });

  return { success: true };
});

// Admin: Delete question
exports.adminDeleteQuestion = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  await verifyAdmin(context.auth.uid);

  const { questionId } = data;

  await db.collection('questions').doc(questionId).delete();

  await db.collection('admin_logs').add({
    type: 'question_deleted',
    adminId: context.auth.uid,
    questionId: questionId,
    timestamp: admin.firestore.Timestamp.now()
  });

  return { success: true };
});

// Admin: Get all users
exports.adminGetUsers = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  await verifyAdmin(context.auth.uid);

  const { limit = 50, offset = 0 } = data;

  const usersSnapshot = await db.collection('users')
    .orderBy('createdAt', 'desc')
    .limit(limit)
    .offset(offset)
    .get();

  const users = usersSnapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));

  return { users: users };
});

// Admin: Get user details
exports.adminGetUserDetails = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  await verifyAdmin(context.auth.uid);

  const { userId } = data;

  const [userDoc, resultsSnap, pointsDoc] = await Promise.all([
    db.collection('users').doc(userId).get(),
    db.collection('quiz_results').where('userId', '==', userId).get(),
    db.collection('user_points').doc(userId).get()
  ]);

  return {
    user: userDoc.exists ? { id: userDoc.id, ...userDoc.data() } : null,
    quizResults: resultsSnap.docs.map(doc => ({ id: doc.id, ...doc.data() })),
    points: pointsDoc.exists ? pointsDoc.data() : null
  };
});

// Admin: Toggle user premium
exports.adminTogglePremium = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  await verifyAdmin(context.auth.uid);

  const { userId, isPremium, planType } = data;

  await db.collection('users').doc(userId).update({
    isPremium: isPremium,
    premiumPlan: isPremium ? planType : null,
    premiumExpiresAt: isPremium 
      ? admin.firestore.Timestamp.fromDate(new Date(Date.now() + 365 * 24 * 60 * 60 * 1000))
      : null
  });

  await db.collection('admin_logs').add({
    type: 'premium_toggled',
    adminId: context.auth.uid,
    userId: userId,
    isPremium: isPremium,
    timestamp: admin.firestore.Timestamp.now()
  });

  return { success: true };
});
