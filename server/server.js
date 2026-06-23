// Stripe Backend Server for Arabic Grammar App
// server.js

const express = require('express');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

const PRICE_IDS = {
  monthly: process.env.STRIPE_PRICE_MONTHLY,
  yearly: process.env.STRIPE_PRICE_YEARLY,
  lifetime: process.env.STRIPE_PRICE_LIFETIME,
};

// Create Payment Intent
app.post('/create-payment-intent', async (req, res) => {
  try {
    const { amount, currency = 'usd', customer_id } = req.body;
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount * 100,
      currency: currency,
      customer: customer_id,
      automatic_payment_methods: { enabled: true },
      metadata: { app: 'arabic_grammar_app', type: 'subscription' },
    });
    res.json({ client_secret: paymentIntent.client_secret, payment_intent_id: paymentIntent.id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create Subscription
app.post('/create-subscription', async (req, res) => {
  try {
    const { plan, customer_id, payment_method_id } = req.body;
    const priceId = PRICE_IDS[plan];
    if (!priceId) return res.status(400).json({ error: 'Invalid plan' });
    
    await stripe.paymentMethods.attach(payment_method_id, { customer: customer_id });
    await stripe.customers.update(customer_id, {
      invoice_settings: { default_payment_method: payment_method_id },
    });
    
    const subscription = await stripe.subscriptions.create({
      customer: customer_id,
      items: [{ price: priceId }],
      payment_settings: {
        payment_method_options: { card: { request_three_d_secure: 'any' } },
        payment_method_types: ['card'],
        save_default_payment_method: 'on_subscription',
      },
      expand: ['latest_invoice.payment_intent'],
    });
    
    res.json({
      subscription_id: subscription.id,
      client_secret: subscription.latest_invoice.payment_intent.client_secret,
      status: subscription.status,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Cancel Subscription
app.post('/cancel-subscription', async (req, res) => {
  try {
    const { subscription_id } = req.body;
    const subscription = await stripe.subscriptions.cancel(subscription_id);
    res.json({ success: true, status: subscription.status, cancel_at: subscription.cancel_at });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get Subscription Status
app.get('/subscription-status/:customer_id', async (req, res) => {
  try {
    const { customer_id } = req.params;
    const subscriptions = await stripe.subscriptions.list({
      customer: customer_id, status: 'all', expand: ['data.default_payment_method'],
    });
    const activeSubscription = subscriptions.data.find(
      sub => sub.status === 'active' || sub.status === 'trialing'
    );
    res.json({
      has_active_subscription: !!activeSubscription,
      subscription: activeSubscription ? {
        id: activeSubscription.id,
        status: activeSubscription.status,
        plan: activeSubscription.items.data[0].price.id,
        current_period_end: activeSubscription.current_period_end,
        cancel_at_period_end: activeSubscription.cancel_at_period_end,
      } : null,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create Customer
app.post('/create-customer', async (req, res) => {
  try {
    const { email, name, user_id } = req.body;
    const customer = await stripe.customers.create({
      email: email,
      name: name,
      metadata: { user_id: user_id, app: 'arabic_grammar_app' },
    });
    res.json({ customer_id: customer.id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Webhook
app.post('/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;
  let event;
  try {
    event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
  } catch (err) {
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }
  switch (event.type) {
    case 'invoice.payment_succeeded':
      console.log('Payment succeeded:', event.data.object);
      break;
    case 'invoice.payment_failed':
      console.log('Payment failed:', event.data.object);
      break;
    case 'customer.subscription.deleted':
      console.log('Subscription cancelled:', event.data.object);
      break;
    case 'customer.subscription.updated':
      console.log('Subscription updated:', event.data.object);
      break;
  }
  res.json({ received: true });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
module.exports = app;