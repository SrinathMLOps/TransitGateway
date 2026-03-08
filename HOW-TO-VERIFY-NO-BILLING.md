# How to Verify No Billable Resources - Complete Guide

## 🎯 Overview

This guide shows you how to verify that all billable AWS resources have been deleted and you're not incurring any charges.

**Time Required**: 2-3 minutes  
**Purpose**: Confirm $0.00 monthly cost  
**When to Run**: After cleanup or anytime you want to check for charges

---

## 🚀 METHOD 1: AWS CloudShell (Easiest - Recommended)

### Step 1: Open CloudShell

1. Log into AWS Console
2. Click the **CloudShell icon** (>_) in the top navigation
3. Wait for CloudShell to initialize

### Step 2: Download Verification Script

```bash
curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/verify-no-billing.sh
```

### Step 3: Make Executable

```bash
chmod +x verify-no-billing.sh
```

### Step 4: Run the Script

```bash
./verify-no-billing.sh
```

### Step 5: Review Results

The script will check all billable resources and display one of two messages:

---

## ✅ SUCCESS MESSAGE (No Billable Resources)

If everything is clean, you'll see:

```
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║                    🎉 EXCELLENT NEWS! 🎉                       ║
║                                                                ║
║              NO BILLABLE RESOURCES DETECTED                    ║
║                                                                ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  ✅ Your AWS account is clean in region: us-east-1             ║
║  ✅ No resources are currently incurring charges               ║
║  ✅ Monthly cost: $0.00                                        ║
║  ✅ You can safely close this verification                     ║
║                                                                ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  📊 Recommendation:                                            ║
║     • Check your AWS Billing Dashboard in 24 hours            ║
║     • Verify charges are $0.00 or minimal                     ║
║     • Set up billing alerts for future labs                   ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

🎊 Congratulations! Your cleanup was successful! 🎊
```

**This means**: You're all set! No ongoing charges. ✅

---

## ⚠️ WARNING MESSAGE (Billable Resources Found)

If billable resources are detected, you'll see:

```
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║                    ⚠️  WARNING! ⚠️                             ║
║                                                                ║
║              BILLABLE RESOURCES DETECTED                       ║
║                                                                ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  ❌ Your AWS account has resources incurring charges           ║
║  ❌ Region: us-east-1                                          ║
║  ❌ These resources are costing you money right now!           ║
║                                                                ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  🔧 Action Required:                                           ║
║     1. Review the resources listed above                      ║
║     2. Delete unnecessary resources immediately               ║
║     3. Run cleanup script if lab resources remain             ║
║     4. Re-run this verification script after cleanup          ║
║                                                                ║
║  💰 Estimated Monthly Cost:                                    ║
║     • Transit Gateway: ~$36/month each                        ║
║     • NAT Gateway: ~$32/month each                            ║
║     • EC2 Instance: ~$8.50/month (t2.micro)                   ║
║     • Load Balancer: ~$16-22/month each                       ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

⚡ Take action now to avoid unnecessary charges! ⚡
```

**This means**: You have billable resources! Run cleanup immediately. ⚠️

---

## 💻 METHOD 2: Local Terminal (Mac/Linux)

### Prerequisites:
- AWS CLI installed and configured

### Steps:

```bash
# Download script
cd ~/Desktop
curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/verify-no-billing.sh

# Make executable
chmod +x verify-no-billing.sh

# Run script
./verify-no-billing.sh
```

---

## 🪟 METHOD 3: Windows PowerShell

### Prerequisites:
- AWS CLI installed and configured
- PowerShell 5.1 or later

### Steps:

```powershell
# Download script
cd $HOME\Desktop
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/verify-no-billing.ps1" -OutFile "verify-no-billing.ps1"

# Allow execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run script
.\verify-no-billing.ps1
```

---

## 🔍 What the Script Checks

### High-Cost Resources (Critical):
```
✅ EC2 Instances (running/stopped)
   Cost: ~$8.50/month per t2.micro

✅ Transit Gateways
   Cost: ~$36/month each

✅ NAT Gateways
   Cost: ~$32/month each

✅ VPN Connections
   Cost: ~$36/month each

✅ Load Balancers (ALB/NLB/Classic)
   Cost: ~$16-22/month each

✅ RDS Instances
   Cost: Varies by instance type
```

### Medium-Cost Resources:
```
✅ VPC Endpoints (Interface type)
   Cost: ~$7.20/month each

✅ Elastic IPs (unattached)
   Cost: ~$3.60/month each

✅ EBS Volumes (unattached)
   Cost: ~$0.10/GB/month
```

### Low-Cost/Usage-Based Resources:
```
ℹ️  Lambda Functions (pay per invocation)
ℹ️  S3 Buckets (pay per storage/requests)
```

---

## 📊 Sample Output

### Checking Process:

```
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║        AWS Billable Resources Verification Script              ║
║                                                                ║
║     Checking for resources that may incur charges              ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

ℹ️  Current AWS Region: us-east-1
ℹ️  Scan started at: Sat Mar  8 11:30:45 UTC 2026

========================================
Checking High-Cost Resources
========================================

🔍 Checking EC2 Instances...
✅ No running or stopped EC2 instances

🔍 Checking Transit Gateways...
✅ No Transit Gateways

🔍 Checking NAT Gateways...
✅ No NAT Gateways

🔍 Checking VPN Connections...
✅ No VPN connections

🔍 Checking Load Balancers...
✅ No Load Balancers

🔍 Checking RDS Instances...
✅ No RDS instances

========================================
Checking Medium-Cost Resources
========================================

🔍 Checking VPC Endpoints (Interface type)...
✅ No Interface VPC Endpoints

🔍 Checking Elastic IPs (unattached)...
✅ No unattached Elastic IPs

🔍 Checking EBS Volumes...
✅ No unattached EBS volumes

========================================
Checking Low-Cost/Usage-Based Resources
========================================

🔍 Checking Lambda Functions...
✅ No Lambda functions

🔍 Checking S3 Buckets...
✅ No S3 buckets
```

---

## 🔄 When to Run This Script

### Recommended Times:

1. **Immediately After Cleanup**
   - Verify cleanup script worked correctly
   - Confirm all resources deleted

2. **Before Closing AWS Console**
   - Final check before ending your session
   - Peace of mind that nothing is running

3. **Next Day**
   - Verify no resources were missed
   - Check before reviewing billing

4. **Weekly/Monthly**
   - Regular audit of your AWS account
   - Catch any forgotten resources

5. **Before Important Dates**
   - Before billing cycle ends
   - Before presenting AWS bill to manager

---

## 💰 Cost Verification Workflow

### Complete Verification Process:

```
Step 1: Run Verification Script
   ↓
   ├─ No billable resources? → ✅ SUCCESS
   │                            ↓
   │                         Step 2: Check Billing Dashboard (24 hours later)
   │                            ↓
   │                         Step 3: Verify $0.00 charges
   │                            ↓
   │                         ✅ COMPLETE
   │
   └─ Billable resources found? → ⚠️ ACTION NEEDED
                                   ↓
                                Step 2: Run Cleanup Script
                                   ↓
                                Step 3: Re-run Verification
                                   ↓
                                Step 4: Repeat until clean
```

---

## 🐛 Troubleshooting

### Issue 1: "Command not found: aws"

**Solution**: Install AWS CLI or use CloudShell (AWS CLI pre-installed)

### Issue 2: "Permission denied"

**Mac/Linux**:
```bash
chmod +x verify-no-billing.sh
```

**Windows**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue 3: "Unable to locate credentials"

**Solution**: Configure AWS CLI
```bash
aws configure
```

### Issue 4: Script shows resources but you deleted them

**Solution**: 
- Wait 5 minutes (resources may be in "deleting" state)
- Check AWS Console to verify status
- Some resources take 10-15 minutes to fully delete

### Issue 5: Wrong region being checked

**Solution**: Set your region
```bash
aws configure set region us-east-1
```

Or specify region in script:
```bash
export AWS_DEFAULT_REGION=us-east-1
./verify-no-billing.sh
```

---

## 📋 Post-Verification Checklist

After running the verification script:

```
□ Script completed successfully
□ Received "NO BILLABLE RESOURCES" message
□ Checked AWS Billing Dashboard
□ Set up billing alerts (if not already done)
□ Documented verification date and time
□ Saved screenshot of clean verification (optional)
□ Scheduled next verification check
```

---

## 🎓 Best Practices

### Regular Verification:

1. **After Every Lab**
   - Always verify after completing any AWS lab
   - Don't assume cleanup worked

2. **Weekly Audits**
   - Run verification every week
   - Catch any forgotten resources early

3. **Before Billing Cycle**
   - Check 1-2 days before month end
   - Avoid surprise charges

4. **Set Reminders**
   - Calendar reminder to run verification
   - Automate if possible

### Billing Alerts:

Set up AWS Budgets:
```
1. AWS Console → Billing Dashboard → Budgets
2. Create budget
3. Set threshold: $1.00
4. Add email notification
5. Save
```

---

## 📞 Need Help?

### If Verification Shows Billable Resources:

1. **Run Cleanup Script**:
   ```bash
   curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/cleanup-script.sh
   chmod +x cleanup-script.sh
   ./cleanup-script.sh
   ```

2. **Manual Cleanup**: See [CLEANUP-GUIDE.md](./CLEANUP-GUIDE.md)

3. **AWS Support**: Open a support ticket if resources won't delete

### Resources:

- **Cleanup Guide**: [CLEANUP-GUIDE.md](./CLEANUP-GUIDE.md)
- **Cleanup Execution**: [HOW-TO-RUN-CLEANUP.md](./HOW-TO-RUN-CLEANUP.md)
- **AWS Billing**: https://console.aws.amazon.com/billing/

---

## ⚠️ Important Reminders

1. **Check All Regions**: This script checks current region only
2. **Wait for Deletion**: Some resources take 10-15 minutes to delete
3. **Verify in Console**: Always double-check in AWS Console
4. **Check Billing**: Review billing dashboard 24 hours later
5. **Set Alerts**: Prevent future surprise charges

---

## 🎉 Success Criteria

Verification is successful when:

✅ Script shows "NO BILLABLE RESOURCES DETECTED"  
✅ AWS Console shows no running resources  
✅ Billing Dashboard shows $0.00 (after 24 hours)  
✅ No billing alerts triggered  
✅ Peace of mind achieved  

---

*Verification Guide Version: 1.0*  
*Last Updated: March 2026*  
*Execution Time: 2-3 minutes*
