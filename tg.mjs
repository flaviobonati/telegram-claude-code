// Helper to send messages and photos via Telegram Bot API
// Usage: node tg.mjs "message" [file.png]
//
// Setup:
//   1. Create a bot via @BotFather on Telegram — copy the token
//   2. Send any message to your bot, then visit:
//      https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates
//      to find your chat_id
//   3. Replace the placeholders below (or use env vars)

import fs from 'fs';

const TOKEN = process.env.BOT_TOKEN || 'YOUR_BOT_TOKEN';
const CHAT_ID = process.env.CHAT_ID || 'YOUR_CHAT_ID';

const text = process.argv[2];
const file = process.argv[3];

if (!text && !file) {
  console.log('Usage: node tg.mjs "message" [file.png]');
  process.exit(1);
}

if (file && fs.existsSync(file)) {
  // Send photo with caption
  const form = new FormData();
  form.append('chat_id', CHAT_ID);
  if (text) form.append('caption', text);
  form.append('photo', new Blob([fs.readFileSync(file)]), 'photo.png');

  const res = await fetch(`https://api.telegram.org/bot${TOKEN}/sendPhoto`, {
    method: 'POST',
    body: form,
  });
  const data = await res.json();
  console.log(data.ok ? `Sent photo (ID: ${data.result.message_id})` : `Error: ${JSON.stringify(data)}`);
} else {
  // Send text
  const res = await fetch(`https://api.telegram.org/bot${TOKEN}/sendMessage`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ chat_id: CHAT_ID, text }),
  });
  const data = await res.json();
  console.log(data.ok ? `Sent (ID: ${data.result.message_id})` : `Error: ${JSON.stringify(data)}`);
}
