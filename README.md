# TCG Invoicing

A self-contained invoicing and payment tracker for The Casey Group. No build step, no npm, no server, no monthly fee. One HTML file plus a JSON data file. Runs on GitHub Pages or by opening `index.html` locally.

Built to replace Wave. Your data lives in this repo, under your control.

## What it does

- Create, edit, send, and print invoices (print to PDF from the browser)
- Track multiple payments per invoice, with date, amount, method, and note
- Auto-computes status: draft, sent, partial, overdue, paid
- Dashboard: collected by month, outstanding, overdue, top clients, recent activity
- Payments log across all invoices, with YTD and all-time totals
- Import your existing 2025 and 2026 data from Excel with a column-mapping screen
- Export `store.json`, invoices CSV, and payments CSV anytime

## How data works (important)

The single source of truth is `data/store.json`. The app reads it on load.

When you make changes in the app, they are cached in your browser first. A banner and an "Export store.json" button appear. Click it, then commit the downloaded file to `data/store.json` in this repo. Your git history becomes the audit trail.

This pattern keeps the app fully static and self-contained. There is no backend to break or pay for.

```
Edit in app  ->  Export store.json  ->  Commit to data/store.json  ->  Done
```

## First-time setup

1. Push this repo to `github.com/ddonofrio03/TCGInvoices` (you already created the repo).
   ```bash
   cd tcg-invoicing
   git init
   git add .
   git commit -m "Initial TCG invoicing app"
   git branch -M main
   git remote add origin https://github.com/ddonofrio03/TCGInvoices.git
   git push -u origin main
   ```
2. Enable GitHub Pages: repo Settings -> Pages -> Source: `Deploy from a branch` -> Branch: `main` -> folder `/ (root)` -> Save.
3. Wait about a minute, then open `https://ddonofrio03.github.io/TCGInvoices/`.

## Importing your Excel data

1. Open the app, go to **Settings -> Import from Excel**.
2. Upload your `.xlsx`, `.xls`, or `.csv`.
3. The app reads your column headers and tries to auto-match them. You confirm or fix the mapping on screen. It works regardless of what your headers are named.
4. Map at minimum: **Invoice number**, **Client**, and **Invoice total**. Optional: issue date, due date, amount already paid, status, description.
5. If you map "amount already paid," the app creates a matching payment and sets the invoice to paid or partial automatically.
6. Invoice numbers that already exist are skipped, so re-importing will not create duplicates.
7. After import, go to **Settings -> Export store.json** and commit the file.

Tip: one row per invoice is the simplest layout. If your sheet has one row per line item, import still works (each becomes a single-line invoice); you can merge later by editing.

## Data format reference (`data/store.json`)

```json
{
  "settings": {
    "business": { "name": "The Casey Group", "email": "", "phone": "", "website": "", "addressLines": [], "tagline": "" },
    "currency": "USD",
    "invoicePrefix": "TCG-",
    "nextNumber": 1001,
    "defaultTaxRate": 0,
    "paymentTermsDays": 30,
    "notesDefault": ""
  },
  "clients": [
    { "id": "id_abc", "name": "Client Name", "email": "", "company": "" }
  ],
  "invoices": [
    {
      "id": "id_xyz",
      "number": "TCG-1001",
      "clientId": "id_abc",
      "issueDate": "2025-03-01",
      "dueDate": "2025-03-31",
      "status": "sent",
      "lineItems": [ { "description": "Strategic communications retainer", "quantity": 1, "rate": 5000 } ],
      "taxRate": 0,
      "discount": 0,
      "notes": ""
    }
  ],
  "payments": [
    { "id": "id_pay", "invoiceId": "id_xyz", "date": "2025-03-20", "amount": 5000, "method": "Check", "note": "check #1043" }
  ]
}
```

Notes:
- `status` you set is only `draft` or `sent`. Paid, partial, and overdue are computed from payments and the due date.
- Invoice total = sum of (quantity x rate), minus discount, plus tax. Balance = total minus payments.
- IDs can be any unique string. The app generates them; if you hand-edit, just keep them unique.

## Editing without the app

You can edit `data/store.json` directly in any text editor and commit it. The app will pick up the changes on next load.

## Local use

Because the app fetches `data/store.json`, opening `index.html` directly from the file system (file://) may block that fetch in some browsers. Two options:
- Just use the GitHub Pages URL (recommended).
- Or run a tiny local server: `python3 -m http.server` in this folder, then open `http://localhost:8000`.

If the fetch is blocked, the app still works from its local browser cache, and you can load a `store.json` manually under Settings.

## Files

```
index.html        The entire app (HTML + CSS + JS, single file)
data/store.json   Your data (source of truth, commit changes here)
assets/           Optional logo / images
README.md         This file
.gitignore
```

## Dependencies

One CDN script: SheetJS (`xlsx`), used only for reading Excel files on import. Everything else is vanilla. If you ever want zero external calls, you can remove the SheetJS `<script>` tag in `index.html` and lose only the Excel import feature (JSON and CSV still work).
