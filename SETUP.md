# NetLedger — ISP Client & Payment Manager

Responsive bilingual (English/Arabic RTL) starter application for a small ISP with 100–500 customers. It tracks customer details, monthly subscription prices, client status, payments, payment methods, and separate USD/LBP totals.

## What's included
- `index.html` — responsive app interface, local demo mode, client CRUD, payment entry/history, dashboard, CSV exports, language toggle.
- `schema.sql` — Supabase Postgres tables, indexes and authenticated-user RLS policies.

## Run the demo
Open `index.html` in a modern browser. Choose **Open local demo**. Demo records are stored in that browser's local storage only. They are not cloud-backed and should not contain real customer data.

## Enable online synchronization
1. Create a Supabase project.
2. In Supabase **SQL Editor**, run all of `schema.sql`.
3. In **Authentication → Providers**, enable Email/password. Create the ISP administrator user in **Authentication → Users** (invite/create a user and set a strong password).
4. Host this folder on an HTTPS static host (for example, your own web host or a static hosting provider). `index.html` loads the Supabase JS v2 client from jsDelivr, so internet access is required.
5. Open the hosted app, go to **Settings**, enter the Supabase Project URL and the anon/publishable key, and choose **Connect cloud**. Sign out, then sign in with the administrator email/password.
6. Test with a fake client and payment from two devices before entering real data.

Only use the public anon/publishable key in the browser. **Never put a Supabase service-role/secret key in this app.** The provided RLS policies permit any authenticated account in this project to manage records; keep this Supabase project dedicated to this one ISP and do not create public signups. For a multi-company or staff-role system, replace these broad policies with owner/company membership policies before use.

## Important limitations of this first build
- Cloud mode syncs the `clients` and `payments` tables after sign-in. The starter does not yet implement realtime push subscriptions; it fetches current data on sign-in/refresh. Add Supabase Realtime or periodic refresh for instant updates across already-open devices.
- Monthly invoices, billing-cycle ledger, late fees, WhatsApp reminders, PDF receipts, user roles, audit logs and automated backup scheduling are not implemented yet.
- The current outstanding calculation is a simple estimate: current monthly fee minus payments entered during the current calendar month. It is not a full accounts-receivable ledger and does not roll forward arrears. Do not use it as the authoritative accounting balance until invoice/ledger logic is added and tested.
- USD and LBP are intentionally never combined or auto-converted. Set and verify any exchange rate manually outside this starter if needed.
- Configure Supabase database backups under the project's backup settings and test a restore. Export CSV regularly as an additional operational backup; CSV exports contain customer personal data and must be stored securely.

## Suggested production checklist
- Deploy only over HTTPS and use a strong unique admin password plus MFA where available.
- Disable public user registration; invite only trusted staff.
- Tighten RLS to an explicit allow-list of admin user IDs (or proper company membership table).
- Add realtime sync, invoice periods, partial-payment allocation, arrears, immutable payment audit trail and printable receipts.
- Test exports, backups, restores, Arabic RTL layout and mobile screens with sample data.
