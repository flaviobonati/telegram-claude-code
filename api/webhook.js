// Vercel serverless function — receives Telegram webhook updates
// Writes message to a file on the VPS via SSH and notifies Claude Code
// via tmux send-keys with a safe pointer to the file (avoids escape issues)
//
// Environment variables (set in Vercel dashboard):
//   SSH_HOST           — your VPS IP or hostname
//   SSH_PORT           — SSH port (default: 22)
//   SSH_USER           — SSH username (default: root)
//   SSH_PRIVATE_KEY    — full SSH private key content
//   TELEGRAM_ALLOWED_USER — Telegram user ID to accept messages from
//   TMUX_SESSION       — tmux session name where Claude Code runs (default: main)
//   MSG_DIR            — directory on VPS to store message files (default: /tmp/telegram_msgs)

import { Client } from 'ssh2';

const SSH_HOST = process.env.SSH_HOST;
const SSH_PORT = parseInt(process.env.SSH_PORT || '22');
const SSH_USER = process.env.SSH_USER || 'root';
const SSH_KEY = process.env.SSH_PRIVATE_KEY;
const ALLOWED_USER = process.env.TELEGRAM_ALLOWED_USER;
const TMUX_SESSION = process.env.TMUX_SESSION || 'main';
const MSG_DIR = process.env.MSG_DIR || '/tmp/telegram_msgs';

function sshExec(command) {
  return new Promise((resolve, reject) => {
    const conn = new Client();
    conn.on('ready', () => {
      conn.exec(command, (err, stream) => {
        if (err) { conn.end(); reject(err); return; }
        let output = '';
        stream.on('data', d => output += d);
        stream.on('close', () => { conn.end(); resolve(output); });
      });
    });
    conn.on('error', reject);
    conn.connect({
      host: SSH_HOST,
      port: SSH_PORT,
      username: SSH_USER,
      privateKey: SSH_KEY,
    });
  });
}

// Upload text content to a file on the VPS using base64 to avoid ANY escape issues
function sshWriteFile(path, content) {
  const b64 = Buffer.from(content, 'utf8').toString('base64');
  const cmd = `mkdir -p ${MSG_DIR} && echo '${b64}' | base64 -d > '${path}'`;
  return sshExec(cmd);
}

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(200).json({ ok: true, method: 'GET' });
  }

  try {
    const update = req.body;
    const msg = update?.message;

    if (!msg || !msg.text) {
      return res.status(200).json({ ok: true, skip: 'no text' });
    }

    // Optional: restrict to a single Telegram user
    const fromId = String(msg.from?.id || '');
    const allowed = String(ALLOWED_USER || '');
    if (allowed && fromId !== allowed) {
      return res.status(200).json({ ok: true, skip: 'unauthorized', from: fromId, allowed });
    }

    // Write message text to a file on the VPS (any chars, any length, zero escape risk)
    const msgId = msg.message_id;
    const ts = new Date(msg.date * 1000).toISOString().replace(/[:.]/g, '-');
    const fileName = `msg_${ts}_${msgId}.txt`;
    const filePath = `${MSG_DIR}/${fileName}`;

    await sshWriteFile(filePath, msg.text);

    // Send Claude a safe pointer — no special chars, just a file path reference.
    // Claude will Read the file to get the actual message content.
    const pointer = `ler arquivo ${filePath}`;
    const command = `tmux send-keys -t ${TMUX_SESSION} ${JSON.stringify(pointer)} Enter`;
    await sshExec(command);

    return res.status(200).json({ ok: true, id: msgId, file: fileName });
  } catch (err) {
    console.error('Webhook error:', err.message);
    return res.status(200).json({ ok: true, error: err.message });
  }
}
