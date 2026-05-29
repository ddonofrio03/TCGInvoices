# TCG Invoicing

A single-page invoicing and payment tracker for The Casey Group. One HTML file, no build step, hosted on GitHub Pages. Data lives in a private Supabase project, so creates/edits save instantly and your financials never sit in the public repo.

Built to replace Wave.

## What it does

- Create, edit, send, and download invoices as PDF (styled to match the Wave layout)
- Saved clients auto-fill on every invoice
- Two-line items (bold title + detail line, e.g. Professional Fee / RenUSA Fee)
- Optional logo on the printed invoice
- Track multiple payments per invoice (date, amount, method, note)
- Auto-computes status: draft, sent, partial, overdue, paid
- Dashboard: collected by month, outstanding, overdue, top clients, recent activity
- Payments log across all invoices, with YTD and all-time totals
- Excel import with a column-mapping screen
- CSV export for invoices and payments

## How data works

The app talks directly to a Supabase Postgres database via the Supabase JS client. Every change saves instantly — no JSON files, no commits required.

- **Storage**: tables `clients`, `invoices`, `payments`, `settings` in your Supabase project.
- **Security**: Row Level Security policies require an authenticated user. The app is gated by a Supabase Auth login.
- **Sync**: open the app on any device, sign in, see the same data.

## Setup

1. Create a Supabase project at https://supabase.com (free tier is fine).
2. In the SQL Editor, run [`supabase/schema.sql`](supabase/schema.sql) to create the tables and RLS policies.
3. In **Authentication → Users → Add user**, create your login (email + password, auto-confirm enabled). No public signup is exposed.
4. In **Settings → API**, copy the **Project URL** and the **publishable / anon key**.
5. In [`index.html`](index.html), set `SUPABASE_URL` and `SUPABASE_KEY` at the top of the `<script>` block.
6. Push to your repo, enable **Settings → Pages** (deploy from `main`, `/` root), and open the Pages URL.

The publishable / anon key is safe to commit — it's designed to be public. Security comes from the RLS policies + the login.

## Files

```
index.html           The entire app (HTML + CSS + JS, single file)
supabase/schema.sql  Tables + RLS to run once in the Supabase SQL editor
assets/              Optional logo / images
README.md            This file
```

## Dependencies (all from CDN)

- `@supabase/supabase-js` — database + auth
- `html2pdf.js` — one-click PDF download
- `xlsx` (SheetJS) — Excel import
