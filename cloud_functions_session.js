
// Add to cloud_functions.js

// Create Paymob payment for live session
exports.createPaymobSessionPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { amount, email, phone, bookingId } = data;

  try {
    // Step 1: Authentication
    const authResponse = await axios.post('https://accept.paymob.com/api/auth/tokens', {
      api_key: PAYMOB_API_KEY,
    });

    const authToken = authResponse.data.token;

    // Step 2: Order Registration
    const orderResponse = await axios.post('https://accept.paymob.com/api/ecommerce/orders', {
      auth_token: authToken,
      delivery_needed: false,
      amount_cents: amount * 100,
      currency: 'EGP',
      items: [],
      merchant_order_id: bookingId,
    });

    const orderId = orderResponse.data.id;

    // Step 3: Payment Key
    const paymentKeyResponse = await axios.post('https://accept.paymob.com/api/acceptance/payment_keys', {
      auth_token: authToken,
      amount_cents: amount * 100,
      expiration: 3600,
      order_id: orderId,
      billing_data: {
        apartment: 'NA',
        email: email,
        floor: 'NA',
        first_name: email.split('@')[0],
        street: 'NA',
        building: 'NA',
        phone_number: phone,
        shipping_method: 'NA',
        postal_code: 'NA',
        city: 'Cairo',
        country: 'EG',
        last_name: 'User',
        state: 'Cairo',
      },
      currency: 'EGP',
      integration_id: PAYMOB_INTEGRATION_ID,
      lock_order_when_paid: true,
    });

    const paymentToken = paymentKeyResponse.data.token;
    const paymentUrl = `https://accept.paymob.com/api/acceptance/iframes/${PAYMOB_IFRAME_ID}?payment_token=${paymentToken}`;

    return {
      success: true,
      paymentUrl: paymentUrl,
      orderId: orderId.toString(),
      paymentToken: paymentToken,
    };

  } catch (error) {
    console.error('Paymob session payment error:', error);
    return {
      success: false,
      error: error.message,
    };
  }
});

// Webhook for session payment completion
exports.sessionPaymentWebhook = functions.https.onRequest(async (req, res) => {
  try {
    const { order, success, bookingId } = req.body;

    if (!success) {
      res.status(400).json({ error: 'Payment failed' });
      return;
    }

    // Update booking status
    await db.collection('session_bookings').doc(bookingId).update({
      status: 'confirmed',
      paidAt: admin.firestore.Timestamp.now(),
      paymentId: order.id,
    });

    // Add session package to user
    const booking = await db.collection('session_bookings').doc(bookingId).get();
    const bookingData = booking.data();

    const planId = bookingData.planId;
    const plan = LiveSessionService.sessionPlans[planId];

    if (plan) {
      const packageRef = db.collection('session_packages').doc();
      await packageRef.set({
        userId: bookingData.userId,
        bookingId: bookingId,
        planId: planId,
        totalSessions: plan.sessions,
        remainingSessions: plan.sessions,
        status: 'active',
        createdAt: admin.firestore.Timestamp.now(),
      });
    }

    // Send notification to user
    await sendNotification(
      bookingData.userId,
      'تم تأكيد الحجز!',
      `تم تأكيد حجز حصتك المباشرة مع الأستاذ. الموعد: ${bookingData.slot.startTime}`
    );

    res.status(200).json({ success: true });

  } catch (error) {
    console.error('Session payment webhook error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Send session reminder
exports.sendSessionReminder = functions.pubsub.schedule('0 9 * * *').onRun(async (context) => {
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);

  const bookings = await db.collection('session_bookings')
    .where('status', '==', 'confirmed')
    .where('slot.date', '==', formatDate(tomorrow))
    .get();

  for (const doc of bookings.docs) {
    const data = doc.data();
    await sendNotification(
      data.userId,
      'تذكير بالحصة المباشرة',
      `لديك حصة مباشرة غداً الساعة ${data.slot.startTime}. لا تنسى!`
    );
  }
});
