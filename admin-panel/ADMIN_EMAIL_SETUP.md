# 🔐 Admin Email Setup Guide

## ✅ What I've Done

I've added all the emails from your Firebase console to the admin list in `src/contexts/AuthContext.js`.

## 📝 Current Admin Emails

The following emails can now access the admin panel:

- `admin@vogueai.com`
- `admin@gmail.com`
- `admin@12gmail.com` ✅ (from your Firebase console)
- `test@example.com`
- `ahsan@gmail.com`
- `abdullah8@gmail.com`
- `ahmed@gmail.com`
- `unaiza100@gmail.com`
- `unaiza1mukhdoom@gmail.com`
- `ali@gmail.com`

## ➕ How to Add Your Own Email

### Step 1: Open the File
```
admin-panel/src/contexts/AuthContext.js
```

### Step 2: Find the ADMIN_EMAILS Array
Look for this section (around line 12-16):

```javascript
const ADMIN_EMAILS = [
  'admin@vogueai.com',
  'admin@gmail.com',
  'admin@12gmail.com',
  // ... other emails
  // Add your email here 👇
];
```

### Step 3: Add Your Email
Add your email address to the list:

```javascript
const ADMIN_EMAILS = [
  'admin@vogueai.com',
  'admin@gmail.com',
  'admin@12gmail.com',
  'your-email@gmail.com',  // 👈 Add your email here
  // ... other emails
];
```

### Step 4: Save and Restart
1. Save the file
2. The admin panel should auto-reload (if running with `npm start`)
3. If not, restart: Press `Ctrl+C` and run `npm start` again

## 🔄 Alternative: Allow All Emails (For Testing Only)

⚠️ **Warning:** Only use this for development/testing, NOT for production!

If you want to allow ALL emails temporarily, you can modify the check:

```javascript
// In AuthContext.js, replace the admin check:
if (!ADMIN_EMAILS.includes(user.email)) {
  // Change to:
  // Allow all emails (REMOVE THIS IN PRODUCTION!)
  console.warn('⚠️ Admin check bypassed - Development mode only!');
  // return userCredential; // Uncomment to allow all
  signOut(auth);
  throw new Error('Access denied...');
}
```

## ✅ Test Login

1. Go to admin panel: `http://localhost:3000`
2. Login with one of the admin emails
3. You should now have access!

## 🐛 Troubleshooting

### Still Getting "Access Denied"?

1. **Check the email exactly matches:**
   - Make sure there are no extra spaces
   - Check capitalization (emails are case-sensitive in the array)
   - Verify the email is in Firebase Authentication

2. **Check Browser Console:**
   - Press `F12` → Console tab
   - Look for: `Admin emails allowed: [...]`
   - Check if your email is in the list

3. **Restart Admin Panel:**
   ```bash
   # Stop the server (Ctrl+C)
   # Then restart:
   npm start
   ```

4. **Clear Browser Cache:**
   - Press `Ctrl+Shift+Delete`
   - Clear cache and cookies
   - Try logging in again

## 📋 Quick Reference

**File to edit:** `admin-panel/src/contexts/AuthContext.js`  
**Line to edit:** Around line 12-16 (ADMIN_EMAILS array)  
**Restart needed:** Yes (or wait for auto-reload)

---

**Your admin emails are now configured!** Try logging in again. 🚀

