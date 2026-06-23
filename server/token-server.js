// Agora Token Server
// token-server.js

const express = require('express');
const { RtcTokenBuilder, RtcRole } = require('agora-access-token');
const app = express();
const PORT = 8080;

const APP_ID = process.env.AGORA_APP_ID;
const APP_CERTIFICATE = process.env.AGORA_APP_CERTIFICATE;

app.use(express.json());

app.get('/getToken', (req, res) => {
  const { channelName, uid, role } = req.query;
  const expirationTimeInSeconds = 3600;
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;
  const userRole = role === 'publisher' ? RtcRole.PUBLISHER : RtcRole.SUBSCRIBER;
  
  const token = RtcTokenBuilder.buildTokenWithUid(
    APP_ID, APP_CERTIFICATE, channelName, parseInt(uid), userRole, privilegeExpiredTs
  );
  res.json({ token });
});

app.listen(PORT, () => console.log(`Token server running on port ${PORT}`));