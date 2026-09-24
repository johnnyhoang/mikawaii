const { Client } = require('pg');

const db2 = 'postgresql://postgres.czngbleeeiljsrpbaksg:B1gh13u1977dtnt@aws-1-ap-southeast-1.pooler.supabase.com:5432/postgres';

async function main() {
  const client = new Client({ connectionString: db2, ssl: { rejectUnauthorized: false } });
  await client.connect();

  console.log("=== MKW USERS ===");
  const users = await client.query("SELECT id, email, created_at FROM mkw_users");
  console.log(users.rows);

  console.log("=== MKW PLAYER PROFILES ===");
  const profiles = await client.query("SELECT id, account_id, name, role, created_at FROM mkw_player_profiles");
  console.log(profiles.rows);

  await client.end();
}

main().catch(console.error);
