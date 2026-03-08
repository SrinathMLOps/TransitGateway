# How to Execute the Cleanup Script - Step by Step

## 🎯 Overview

This guide shows you exactly how to run the cleanup script to delete all AWS Transit Gateway lab resources.

**Time Required**: 15-20 minutes  
**Cost Savings**: ~$58/month  
**Difficulty**: Easy

---

## 📋 Prerequisites

Before running the cleanup script, ensure you have:

- ✅ AWS account access
- ✅ Completed the Transit Gateway lab
- ✅ Resources still exist in your AWS account

---

## 🚀 METHOD 1: AWS CloudShell (Recommended - Easiest)

**Best for**: Quick cleanup without any local setup

### Step 1: Log into AWS Console

1. Open your web browser
2. Go to: https://console.aws.amazon.com/
3. Sign in with your AWS credentials
4. Ensure you're in the correct region (us-east-1 or your lab region)

### Step 2: Open CloudShell

1. Look at the top navigation bar in AWS Console
2. Click the **CloudShell icon** (looks like >_) next to the search bar
3. Wait 30-60 seconds for CloudShell to initialize

**You'll see**:
```
[cloudshell-user@ip-xxx-xxx-xxx-xxx ~]$
```

### Step 3: Download the Cleanup Script

Copy and paste this command into CloudShell:

```bash
curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/cleanup-script.sh
```

**Expected output**:
```
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  8234  100  8234    0     0  41170      0 --:--:-- --:--:-- --:--:-- 41170
```

### Step 4: Make the Script Executable

```bash
chmod +x cleanup-script.sh
```

**No output means success** ✅

### Step 5: Verify the Script Downloaded

```bash
ls -lh cleanup-script.sh
```

**Expected output**:
```
-rwxr-xr-x 1 cloudshell-user cloudshell-user 8.1K Mar  8 10:30 cleanup-script.sh
```

### Step 6: Run the Cleanup Script

```bash
./cleanup-script.sh
```

### Step 7: Confirm Execution

You'll see this prompt:

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

Do you want to continue? (yes/no):
```

**Type**: `yes` and press Enter

### Step 8: Wait for Completion

The script will now run through all cleanup steps. You'll see progress like:

```
========================================
STEP 1: Terminating EC2 Instances
========================================

ℹ️  Looking for EC2-VPC1 instance...
ℹ️  Terminating EC2-VPC1 (i-0abc123def456789)...
✅ EC2-VPC1 termination initiated
⏳ Waiting for instances to terminate (60 seconds)............
✅ EC2 instances terminated

========================================
STEP 2: Deleting Transit Gateway Attachments
========================================

ℹ️  Looking for Transit Gateway...
✅ Found Transit Gateway: tgw-0123456789abcdef0
ℹ️  Looking for Transit Gateway attachments...
ℹ️  Deleting attachment: tgw-attach-xxx...
✅ Attachment deletion initiated: tgw-attach-xxx
⏳ Waiting for attachments to delete (90 seconds)...........
✅ Transit Gateway attachments deleted

[... continues through all 7 steps ...]
```

### Step 9: Verify Completion

At the end, you'll see:

```
========================================
STEP 7: Final Verification
========================================

ℹ️  Checking EC2 instances...
✅ No lab EC2 instances running
ℹ️  Checking Transit Gateway...
✅ Transit Gateway deleted
ℹ️  Checking VPCs...
✅ VPC1 deleted
✅ VPC2 deleted

✅ CLEANUP COMPLETED SUCCESSFULLY!
✅ All Transit Gateway lab resources have been deleted.
✅ Expected cost: ~$0.05-$0.07 (for lab duration)
✅ Ongoing monthly cost: $0.00

========================================
CLEANUP COMPLETE
========================================

ℹ️  Check your AWS Billing Dashboard in 24 hours to verify no ongoing charges.
ℹ️  Script execution completed at: Sat Mar  8 10:45:23 UTC 2026
```

### Step 10: Close CloudShell

You can now close the CloudShell window. Your cleanup is complete! ✅

---

## 💻 METHOD 2: Local Terminal (Mac/Linux)

**Best for**: Users who prefer running scripts locally

### Prerequisites:
- AWS CLI installed
- AWS credentials configured

### Step 1: Check AWS CLI Installation

```bash
aws --version
```

**Expected output**:
```
aws-cli/2.x.x Python/3.x.x ...
```

**If not installed**:
```bash
# Mac
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Step 2: Configure AWS CLI (if not already done)

```bash
aws configure
```

**Enter**:
- AWS Access Key ID: [Your access key]
- AWS Secret Access Key: [Your secret key]
- Default region name: us-east-1
- Default output format: json

### Step 3: Download the Script

```bash
cd ~/Desktop
curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/cleanup-script.sh
```

### Step 4: Make Executable

```bash
chmod +x cleanup-script.sh
```

### Step 5: Run the Script

```bash
./cleanup-script.sh
```

### Step 6: Confirm and Wait

Type `yes` when prompted and wait 15-20 minutes for completion.

---

## 🪟 METHOD 3: Windows PowerShell

**Best for**: Windows users

### Prerequisites:
- AWS CLI installed
- PowerShell 5.1 or later

### Step 1: Check AWS CLI

Open PowerShell and run:

```powershell
aws --version
```

**If not installed**, download from: https://aws.amazon.com/cli/

### Step 2: Configure AWS CLI

```powershell
aws configure
```

Enter your credentials as prompted.

### Step 3: Download the PowerShell Script

```powershell
cd $HOME\Desktop
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/cleanup-script.ps1" -OutFile "cleanup-script.ps1"
```

### Step 4: Allow Script Execution

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Type `Y` when prompted.

### Step 5: Run the Script

```powershell
.\cleanup-script.ps1
```

### Step 6: Confirm and Wait

Type `yes` when prompted and wait for completion.

---

## 📊 What Happens During Cleanup

### Timeline:

```
Minute 0-2:   Terminating EC2 instances
Minute 2-4:   Deleting Transit Gateway attachments
Minute 4-14:  Deleting Transit Gateway (longest step)
Minute 14-16: Deleting VPC2 and resources
Minute 16-18: Deleting VPC1 and resources
Minute 18-19: Deleting key pair
Minute 19-20: Final verification
```

### Resources Deleted:

```
✅ EC2 Instances
   - EC2-VPC1 (i-xxxxx)
   - EC2-VPC2 (i-yyyyy)

✅ Transit Gateway
   - My-Transit-Gateway (tgw-xxxxx)
   - VPC1-TGW-Attachment
   - VPC2-TGW-Attachment

✅ VPC1 Resources
   - VPC1 (vpc-xxxxx)
   - VPC1-Public-Subnet
   - VPC1-IGW (Internet Gateway)
   - VPC1-Public-RT (Route Table)
   - VPC1-Public-SG (Security Group)

✅ VPC2 Resources
   - VPC2 (vpc-yyyyy)
   - VPC2-Private-Subnet
   - VPC2-Private-RT (Route Table)
   - VPC2-Private-SG (Security Group)

✅ Key Pair
   - TransitGatewayKey
```

---

## ✅ Verification After Cleanup

### Method 1: AWS Console (Visual)

**Check EC2 Instances**:
1. Go to: EC2 → Instances
2. Verify: Only "Terminated" instances (or none)

**Check Transit Gateway**:
1. Go to: VPC → Transit Gateways
2. Verify: No transit gateways listed

**Check VPCs**:
1. Go to: VPC → Your VPCs
2. Verify: Only default VPC remains

**Check Security Groups**:
1. Go to: EC2 → Security Groups
2. Verify: Only default security groups

### Method 2: AWS CLI (Command Line)

```bash
# Check EC2 instances
aws ec2 describe-instances --region us-east-1 \
  --filters "Name=instance-state-name,Values=running,stopped" \
  --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0]]'

# Check Transit Gateways
aws ec2 describe-transit-gateways --region us-east-1

# Check VPCs
aws ec2 describe-vpcs --region us-east-1 \
  --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value|[0]]'
```

**Expected**: Empty results or only default resources

---

## 🐛 Troubleshooting

### Issue 1: "Permission denied" Error

**Mac/Linux**:
```bash
chmod +x cleanup-script.sh
```

**Windows PowerShell**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue 2: "Command not found: aws"

**Solution**: Install AWS CLI
- Mac: `brew install awscli`
- Linux: Follow AWS CLI installation guide
- Windows: Download from aws.amazon.com/cli

### Issue 3: "Unable to locate credentials"

**Solution**: Configure AWS CLI
```bash
aws configure
```

Enter your Access Key ID and Secret Access Key.

### Issue 4: Script Fails Midway

**Solution**: Run the script again
```bash
./cleanup-script.sh
```

The script will skip already-deleted resources and continue.

### Issue 5: Resources Still Exist After Script

**Solution**: Wait 5 minutes and verify again
- Transit Gateway can take up to 15 minutes to fully delete
- Check AWS Console to see if resources are in "deleting" state

### Issue 6: Different Resource Names

**Solution**: Edit the script variables

Open the script:
```bash
nano cleanup-script.sh
```

Edit these lines at the top:
```bash
EC2_VPC1_NAME="EC2-VPC1"        # Change to your name
EC2_VPC2_NAME="EC2-VPC2"        # Change to your name
VPC1_NAME="VPC1"                # Change to your name
VPC2_NAME="VPC2"                # Change to your name
TGW_NAME="My-Transit-Gateway"   # Change to your name
REGION="us-east-1"              # Change to your region
```

Save (Ctrl+X, Y, Enter) and run again.

---

## 💰 Cost Verification

### 24 Hours After Cleanup:

1. Go to: AWS Console → Billing Dashboard
2. Click: "Bills"
3. Select: Current month
4. Review charges

**Expected charges**:
```
Transit Gateway: ~$0.05 (for lab duration)
EC2 t2.micro: $0.00 (free tier) or ~$0.02
Data Transfer: ~$0.00
─────────────────────────────
Total: ~$0.05-$0.07 ✅
```

**If you see ongoing charges**:
- Check for resources in other regions
- Review the verification steps above
- Contact AWS Support if needed

---

## 📝 Post-Cleanup Checklist

```
□ Script completed successfully
□ Verified in AWS Console:
  □ No running/stopped EC2 instances
  □ No Transit Gateways
  □ Only default VPC remains
  □ Only default security groups
□ Deleted local key file:
  □ Mac/Linux: rm ~/.ssh/TransitGatewayKey.pem
  □ Windows: Delete .ppk file
□ Set billing alert for future labs
□ Documented lessons learned
□ Checked billing dashboard (after 24 hours)
```

---

## 🎓 Best Practices

### Before Running Cleanup:

1. ✅ Take screenshots of your working configuration
2. ✅ Document any custom settings
3. ✅ Export any important data
4. ✅ Verify you're in the correct AWS region

### During Cleanup:

1. ✅ Don't interrupt the script
2. ✅ Let it complete all steps
3. ✅ Monitor the progress output
4. ✅ Note any errors for troubleshooting

### After Cleanup:

1. ✅ Verify all resources deleted
2. ✅ Check billing dashboard after 24 hours
3. ✅ Delete local key files
4. ✅ Set up billing alerts for future

---

## 📞 Need Help?

### Resources:

- **Manual Cleanup Guide**: [CLEANUP-GUIDE.md](./CLEANUP-GUIDE.md)
- **Script Documentation**: [CLEANUP-SCRIPTS-README.md](./CLEANUP-SCRIPTS-README.md)
- **Quick Start**: [QUICK-START-CLEANUP.md](./QUICK-START-CLEANUP.md)

### Support:

- **AWS Support**: Open a support ticket
- **GitHub Issues**: Report problems on the repository
- **AWS Documentation**: docs.aws.amazon.com

---

## ⚠️ Important Reminders

1. **Backup First**: Take screenshots before cleanup
2. **Correct Region**: Ensure you're in the right AWS region
3. **Don't Interrupt**: Let the script complete all steps
4. **Verify After**: Always check AWS Console after cleanup
5. **Check Billing**: Review charges 24 hours later

---

## 🎉 Success!

If you see this message, cleanup is complete:

```
✅ CLEANUP COMPLETED SUCCESSFULLY!
✅ All Transit Gateway lab resources have been deleted.
✅ Expected cost: ~$0.05-$0.07 (for lab duration)
✅ Ongoing monthly cost: $0.00
```

**You've successfully cleaned up your AWS Transit Gateway lab!**

**Cost saved**: ~$58/month ✅

---

*Execution Guide Version: 1.0*  
*Last Updated: March 2026*  
*Estimated Execution Time: 15-20 minutes*
