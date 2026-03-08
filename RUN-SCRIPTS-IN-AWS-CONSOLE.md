# How to Run Scripts in AWS Console CloudShell - Complete Guide

## 🎯 Overview

This guide shows you **exactly** how to run any of our scripts directly in the AWS Console using CloudShell.

**No installation required!** CloudShell has everything pre-configured.

**Time Required**: 2-3 minutes to get started

---

## 📋 Available Scripts

| Script | Purpose | Time | Safety |
|--------|---------|------|--------|
| `cleanup-script.sh` | Delete Transit Gateway lab resources | 15-20 min | ⚠️ Deletes lab resources |
| `verify-no-billing.sh` | Check for billable resources | 2-3 min | ✅ Safe (read-only) |
| `aws-resource-scanner.sh` | Scan/delete ALL resources | 5-30 min | ❌ DANGEROUS (can delete everything) |

---

## 🚀 STEP-BY-STEP: Running Scripts in AWS Console

### STEP 1: Log into AWS Console

1. Open your web browser
2. Go to: **https://console.aws.amazon.com/**
3. Sign in with your AWS credentials
4. You'll see the AWS Management Console homepage

**Screenshot location**: Top of the page shows your account name

---

### STEP 2: Select the Correct Region

**⚠️ CRITICAL**: Make sure you're in the region where your resources exist!

1. Look at the **top-right corner** of the AWS Console
2. You'll see a region name (e.g., "N. Virginia" or "us-east-1")
3. Click on it to open the region dropdown
4. Select your region:
   - **US East (N. Virginia)** = us-east-1 (most common)
   - **US West (Oregon)** = us-west-2
   - **Europe (Ireland)** = eu-west-1
   - etc.

**Visual Guide**:
```
┌─────────────────────────────────────────────────────┐
│ AWS Console                    [Your Name] [Region]▼│
│                                                      │
│ Click here ──────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

**Why this matters**: Scripts only work in the region you select!

---

### STEP 3: Open AWS CloudShell

**Method 1: Using the Icon (Easiest)**

1. Look at the **top navigation bar** (black bar at the top)
2. Find the **CloudShell icon** (looks like `>_` or a terminal window)
3. It's usually next to the search bar
4. Click on it

**Visual Guide**:
```
┌─────────────────────────────────────────────────────┐
│ AWS  [Search]  [>_]  [🔔]  [?]  [Your Name] [Region]│
│                 ↑                                    │
│          Click here (CloudShell icon)               │
└─────────────────────────────────────────────────────┘
```

**Method 2: Using Search**

1. Click the **search bar** at the top
2. Type: `CloudShell`
3. Click on **CloudShell** in the results

**Method 3: Using Services Menu**

1. Click **Services** in the top-left
2. Scroll down to **Developer Tools**
3. Click **CloudShell**

---

### STEP 4: Wait for CloudShell to Initialize

After clicking CloudShell:

1. A new panel will open at the bottom of your screen
2. You'll see a message: **"Preparing your terminal..."**
3. Wait **30-60 seconds** for initialization
4. When ready, you'll see a command prompt:

```bash
[cloudshell-user@ip-xxx-xxx-xxx-xxx ~]$
```

**This means CloudShell is ready!** ✅

**Visual Guide**:
```
┌─────────────────────────────────────────────────────┐
│ AWS Console (top part)                              │
├─────────────────────────────────────────────────────┤
│ CloudShell (bottom panel)                           │
│                                                     │
│ [cloudshell-user@ip-xxx-xxx-xxx-xxx ~]$ _          │
│                                         ↑           │
│                                   Cursor here       │
└─────────────────────────────────────────────────────┘
```

---

### STEP 5: Download the Script

Now you'll download the script you want to run. Choose one:

#### **Option A: Transit Gateway Cleanup Script**

```bash
curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/cleanup-script.sh
```

#### **Option B: Billing Verification Script**

```bash
curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/verify-no-billing.sh
```

#### **Option C: Resource Scanner Script**

```bash
curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/aws-resource-scanner.sh
```

**How to execute**:
1. **Copy** the command above (Ctrl+C or Cmd+C)
2. **Click** in the CloudShell terminal
3. **Paste** the command (Right-click → Paste, or Ctrl+Shift+V)
4. **Press Enter**

**Expected Output**:
```
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  8234  100  8234    0     0  41170      0 --:--:-- --:--:-- --:--:-- 41170
```

**This means the script downloaded successfully!** ✅

---

### STEP 6: Make the Script Executable

Before running, you need to make the script executable:

```bash
chmod +x cleanup-script.sh
```

Or for other scripts:
```bash
chmod +x verify-no-billing.sh
# OR
chmod +x aws-resource-scanner.sh
```

**How to execute**:
1. Copy the command
2. Paste in CloudShell
3. Press Enter

**Expected Output**: No output means success! ✅

---

### STEP 7: Verify the Script Downloaded

Check that the script is there:

```bash
ls -lh *.sh
```

**Expected Output**:
```
-rwxr-xr-x 1 cloudshell-user cloudshell-user 8.1K Mar  8 10:30 cleanup-script.sh
```

**What this shows**:
- `-rwxr-xr-x` = File permissions (executable)
- `8.1K` = File size
- `cleanup-script.sh` = File name

**If you see this, you're ready to run!** ✅

---

### STEP 8: Run the Script

Now execute the script:

#### **For Cleanup Script**:
```bash
./cleanup-script.sh
```

#### **For Verification Script**:
```bash
./verify-no-billing.sh
```

#### **For Resource Scanner** (choose mode):

**Scan only (safe)**:
```bash
./aws-resource-scanner.sh --scan
```

**Interactive (asks for confirmation)**:
```bash
./aws-resource-scanner.sh --interactive
```

**Auto-delete (DANGEROUS!)**:
```bash
./aws-resource-scanner.sh --delete
```

**How to execute**:
1. Copy the command
2. Paste in CloudShell
3. Press Enter

---

### STEP 9: Follow the Script Prompts

Depending on the script, you'll see different prompts:

#### **Cleanup Script Prompt**:
```
Do you want to continue? (yes/no):
```
**Type**: `yes` and press Enter

#### **Resource Scanner Interactive Prompt**:
```
Do you want to DELETE all these resources? (yes/no):
```
**Type**: `yes` (to delete) or `no` (to cancel)

---

### STEP 10: Wait for Completion

The script will now run. You'll see progress like:

```
========================================
STEP 1: Terminating EC2 Instances
========================================

ℹ️  Looking for EC2-VPC1 instance...
✅ EC2-VPC1 termination initiated
⏳ Waiting for instances to terminate (60 seconds)............
✅ EC2 instances terminated

========================================
STEP 2: Deleting Transit Gateway Attachments
========================================
...
```

**Do NOT close CloudShell while the script is running!**

**Estimated time**:
- Cleanup script: 15-20 minutes
- Verification script: 2-3 minutes
- Resource scanner: 5-30 minutes

---

### STEP 11: Review the Results

When complete, you'll see a final message:

#### **Success Message (Cleanup)**:
```
✅ CLEANUP COMPLETED SUCCESSFULLY!
✅ All Transit Gateway lab resources have been deleted.
✅ Expected cost: ~$0.05-$0.07 (for lab duration)
✅ Ongoing monthly cost: $0.00
```

#### **Success Message (Verification)**:
```
╔════════════════════════════════════════════════════════════════╗
║              NO BILLABLE RESOURCES DETECTED                    ║
║  ✅ Monthly cost: $0.00                                        ║
╚════════════════════════════════════════════════════════════════╝
```

#### **Warning Message (Resources Found)**:
```
╔════════════════════════════════════════════════════════════════╗
║              BILLABLE RESOURCES DETECTED                       ║
║  ❌ These resources are costing you money right now!           ║
╚════════════════════════════════════════════════════════════════╝
```

---

### STEP 12: Close CloudShell (Optional)

When done:

1. Click the **X** button in the top-right of the CloudShell panel
2. Or click the CloudShell icon again to minimize it

**Your work is saved!** You can reopen CloudShell anytime.

---

## 📸 Visual Walkthrough

### Finding CloudShell Icon:

```
AWS Console Top Bar:
┌──────────────────────────────────────────────────────────┐
│ AWS  [🔍 Search]  [>_]  [🔔]  [?]  [User ▼]  [Region ▼] │
│                    ↑                                      │
│              CloudShell Icon                             │
└──────────────────────────────────────────────────────────┘
```

### CloudShell Panel Layout:

```
┌──────────────────────────────────────────────────────────┐
│ AWS Console (main area)                                  │
│                                                          │
│ Your AWS services and resources appear here             │
│                                                          │
├──────────────────────────────────────────────────────────┤
│ CloudShell Panel (bottom)                                │
│ ┌────────────────────────────────────────────────────┐   │
│ │ [cloudshell-user@ip-xxx ~]$ ./cleanup-script.sh   │   │
│ │                                                    │   │
│ │ ✅ EC2 instances terminated                        │   │
│ │ ✅ Transit Gateway deleted                         │   │
│ │                                                    │   │
│ └────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
```

---

## 🎬 Complete Example Session

Here's a complete example of running the cleanup script:

```bash
# Step 1: Download script
[cloudshell-user@ip-xxx ~]$ curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/cleanup-script.sh
  % Total    % Received
100  8234  100  8234

# Step 2: Make executable
[cloudshell-user@ip-xxx ~]$ chmod +x cleanup-script.sh

# Step 3: Verify download
[cloudshell-user@ip-xxx ~]$ ls -lh cleanup-script.sh
-rwxr-xr-x 1 cloudshell-user cloudshell-user 8.1K Mar  8 10:30 cleanup-script.sh

# Step 4: Run script
[cloudshell-user@ip-xxx ~]$ ./cleanup-script.sh

╔════════════════════════════════════════════════════════════╗
║     AWS Transit Gateway Lab - Automated Cleanup            ║
╚════════════════════════════════════════════════════════════╝

Do you want to continue? (yes/no): yes

========================================
STEP 1: Terminating EC2 Instances
========================================
✅ EC2 instances terminated

[... script continues ...]

✅ CLEANUP COMPLETED SUCCESSFULLY!
```

---

## 🔄 Running Multiple Scripts

You can run multiple scripts in sequence:

```bash
# Step 1: Run cleanup
./cleanup-script.sh

# Step 2: Wait for completion (15-20 minutes)

# Step 3: Verify no billing
./verify-no-billing.sh

# Step 4: Check results
```

---

## 💡 Pro Tips

### Tip 1: Copy-Paste in CloudShell

**To paste in CloudShell**:
- **Windows**: Right-click → Paste, or Ctrl+Shift+V
- **Mac**: Cmd+V or Right-click → Paste
- **Linux**: Ctrl+Shift+V or Right-click → Paste

**Regular Ctrl+V doesn't work in CloudShell!**

### Tip 2: View Previous Commands

Press **Up Arrow** to see previous commands

### Tip 3: Clear Screen

Type `clear` and press Enter to clear the screen

### Tip 4: Stop a Running Script

Press **Ctrl+C** to stop a script (use with caution!)

### Tip 5: Check Current Region

```bash
aws configure get region
```

### Tip 6: Change Region

```bash
export AWS_DEFAULT_REGION=us-west-2
```

### Tip 7: View Script Output Later

Save output to a file:
```bash
./cleanup-script.sh > cleanup-log.txt 2>&1
```

View the log:
```bash
cat cleanup-log.txt
```

### Tip 8: Run Script in Background

```bash
nohup ./cleanup-script.sh > cleanup.log 2>&1 &
```

Check progress:
```bash
tail -f cleanup.log
```

---

## 🐛 Troubleshooting

### Issue 1: "Permission denied"

**Error**:
```
bash: ./cleanup-script.sh: Permission denied
```

**Solution**:
```bash
chmod +x cleanup-script.sh
```

### Issue 2: "No such file or directory"

**Error**:
```
bash: ./cleanup-script.sh: No such file or directory
```

**Solution**: Download the script again
```bash
curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/cleanup-script.sh
```

### Issue 3: CloudShell Won't Open

**Solutions**:
1. Refresh the browser page
2. Try a different browser (Chrome, Firefox, Edge)
3. Clear browser cache
4. Check if CloudShell is available in your region

### Issue 4: Script Hangs or Freezes

**Solution**:
1. Wait 5 minutes (some operations take time)
2. If still frozen, press Ctrl+C
3. Run the script again

### Issue 5: "curl: command not found"

**This shouldn't happen in CloudShell**, but if it does:
```bash
wget https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/cleanup-script.sh
```

### Issue 6: Wrong Region

**Check current region**:
```bash
aws configure get region
```

**Change region**:
```bash
export AWS_DEFAULT_REGION=us-east-1
```

---

## ✅ Verification Checklist

After running scripts, verify:

```
□ Script completed without errors
□ Saw success message at the end
□ No error messages in red
□ CloudShell still responsive
□ Can run verification script
□ AWS Console shows resources deleted
```

---

## 📞 Need Help?

### If Scripts Don't Work:

1. **Check the script output** for error messages
2. **Verify you're in the correct region**
3. **Try running the script again**
4. **Check AWS Console** to see resource status
5. **Contact AWS Support** if resources won't delete

### Useful Commands:

```bash
# Check AWS CLI version
aws --version

# Check current user
aws sts get-caller-identity

# Check region
aws configure get region

# List files
ls -lh

# View file contents
cat cleanup-script.sh
```

---

## 🎓 Summary

**To run any script in AWS Console**:

1. ✅ Log into AWS Console
2. ✅ Select correct region
3. ✅ Open CloudShell (click >_ icon)
4. ✅ Download script: `curl -O [script-url]`
5. ✅ Make executable: `chmod +x [script-name]`
6. ✅ Run script: `./[script-name]`
7. ✅ Follow prompts
8. ✅ Wait for completion
9. ✅ Verify results

**That's it!** No installation, no configuration needed. CloudShell has everything ready.

---

## 🔗 Quick Reference

### Script URLs:

**Cleanup Script**:
```
https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/cleanup-script.sh
```

**Verification Script**:
```
https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/verify-no-billing.sh
```

**Resource Scanner**:
```
https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/aws-resource-scanner.sh
```

### One-Line Commands:

**Run Cleanup**:
```bash
curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/cleanup-script.sh && chmod +x cleanup-script.sh && ./cleanup-script.sh
```

**Run Verification**:
```bash
curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/verify-no-billing.sh && chmod +x verify-no-billing.sh && ./verify-no-billing.sh
```

**Run Scanner (scan only)**:
```bash
curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/aws-resource-scanner.sh && chmod +x aws-resource-scanner.sh && ./aws-resource-scanner.sh --scan
```

---

*AWS Console Guide Version: 1.0*  
*Last Updated: March 2026*  
*Works with all AWS regions*
