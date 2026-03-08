# Quick Start: Cleanup Your AWS Transit Gateway Lab

## 🚀 Fastest Way to Clean Up (AWS CloudShell)

### Step 1: Open AWS CloudShell
1. Log into your AWS Console
2. Click the **CloudShell icon** (>_) in the top navigation bar
3. Wait for CloudShell to initialize (~30 seconds)

### Step 2: Download the Script
```bash
# Download the cleanup script
curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/cleanup-script.sh

# Make it executable
chmod +x cleanup-script.sh
```

### Step 3: Run the Script
```bash
./cleanup-script.sh
```

### Step 4: Confirm
- When prompted, type: **yes**
- Press Enter
- Wait 15-20 minutes

### Step 5: Verify
The script will automatically verify all resources are deleted.

---

## 📋 What the Script Does

```
✅ Step 1: Terminates EC2 instances (2-3 min)
✅ Step 2: Deletes Transit Gateway attachments (2-3 min)
✅ Step 3: Deletes Transit Gateway (5-10 min)
✅ Step 4: Deletes VPC2 and all resources (1-2 min)
✅ Step 5: Deletes VPC1 and all resources (1-2 min)
✅ Step 6: Deletes key pair (1 min)
✅ Step 7: Verifies cleanup complete (1 min)
```

**Total Time: 15-20 minutes**  
**Cost Savings: ~$58/month**

---

## 💡 Alternative: Copy-Paste Method

If you prefer not to download, you can copy the entire script:

1. Open [cleanup-script.sh](https://github.com/SrinathMLOps/TransitGateway/blob/main/cleanup-script.sh)
2. Click "Raw" button
3. Copy all content (Ctrl+A, Ctrl+C)
4. In CloudShell, create the file:
   ```bash
   nano cleanup-script.sh
   ```
5. Paste the content (Right-click → Paste)
6. Save: Ctrl+X, then Y, then Enter
7. Make executable and run:
   ```bash
   chmod +x cleanup-script.sh
   ./cleanup-script.sh
   ```

---

## 🎯 Expected Output

You'll see color-coded progress:

```
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║     AWS Transit Gateway Lab - Automated Cleanup            ║
║                                                            ║
║     This script will delete all lab resources              ║
║     Estimated time: 15-20 minutes                          ║
║     Cost savings: ~$58/month                               ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

⚠️  This script will delete the following resources:
  - EC2 instances (EC2-VPC1, EC2-VPC2)
  - Transit Gateway and attachments
  - VPCs (VPC1, VPC2) and all associated resources
  - Key pair (optional)

Do you want to continue? (yes/no): yes

ℹ️  Starting cleanup process...
ℹ️  Region: us-east-1

========================================
STEP 1: Terminating EC2 Instances
========================================

ℹ️  Looking for EC2-VPC1 instance...
✅ EC2-VPC1 termination initiated
⏳ Waiting for instances to terminate (60 seconds)...
✅ EC2 instances terminated

[... continues through all steps ...]

========================================
STEP 7: Final Verification
========================================

✅ No lab EC2 instances running
✅ Transit Gateway deleted
✅ VPC1 deleted
✅ VPC2 deleted

✅ CLEANUP COMPLETED SUCCESSFULLY!
✅ All Transit Gateway lab resources have been deleted.
✅ Expected cost: ~$0.05-$0.07 (for lab duration)
✅ Ongoing monthly cost: $0.00
```

---

## ✅ Success Checklist

After script completes, verify in AWS Console:

- [ ] EC2 → Instances: Only "Terminated" instances
- [ ] VPC → Transit Gateways: Empty (no transit gateways)
- [ ] VPC → Your VPCs: Only default VPC remains
- [ ] VPC → Subnets: Only default VPC subnets
- [ ] EC2 → Security Groups: Only default security groups

---

## 🐛 Troubleshooting

### Script says "command not found: aws"
**Solution**: CloudShell has AWS CLI pre-installed. If using local terminal, install AWS CLI first.

### Script fails with "Unable to locate credentials"
**Solution**: In CloudShell, credentials are automatic. If using local terminal, run `aws configure`.

### Some resources still exist after script
**Solution**: Wait 5 minutes and check again. Transit Gateway can take up to 15 minutes to fully delete.

### Script stops with an error
**Solution**: Note the error message and run the script again. It will skip already-deleted resources.

---

## 💰 Cost Verification

24 hours after cleanup, check your AWS Billing Dashboard:

1. AWS Console → Billing Dashboard
2. Click "Bills"
3. Select current month
4. Look for charges

**Expected charges:**
- Transit Gateway: ~$0.05 (for lab duration)
- EC2: $0.00 (if using free tier)
- **Total: ~$0.05-$0.07** ✅

**If you see ongoing charges**, review the verification checklist above.

---

## 📞 Need Help?

- **Detailed Manual Guide**: [CLEANUP-GUIDE.md](./CLEANUP-GUIDE.md)
- **Script Documentation**: [CLEANUP-SCRIPTS-README.md](./CLEANUP-SCRIPTS-README.md)
- **AWS Support**: Open a support ticket if resources won't delete

---

## ⚠️ Important Reminders

1. **Region**: Script defaults to `us-east-1`. Edit if you used a different region.
2. **Resource Names**: Script looks for exact names (VPC1, VPC2, etc.). Edit if you used different names.
3. **Execution Time**: Don't interrupt the script. Let it complete all steps.
4. **Verification**: Always verify in AWS Console after script completes.

---

*Quick Start Guide Version: 1.0*  
*Estimated Time: 15-20 minutes*  
*Cost Savings: ~$58/month*
