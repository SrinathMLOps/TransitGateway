# AWS Resource Scanner & Cleanup Tool - Complete Guide

## 🎯 Overview

This is a **powerful generalized script** that scans ALL AWS resources in your current region and provides options to delete them.

**⚠️ WARNING**: This script can delete ALL resources in a region. Use with EXTREME CAUTION!

**Time Required**: 
- Scan only: 5-10 minutes
- Scan + Delete: 20-30 minutes

---

## 🚀 Quick Start

### Method 1: Scan Only (Safe - Recommended First)

```bash
# Download script
curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/aws-resource-scanner.sh

# Make executable
chmod +x aws-resource-scanner.sh

# Run scan (safe - no deletion)
./aws-resource-scanner.sh --scan
```

### Method 2: Interactive Mode (Asks for Confirmation)

```bash
# Run with confirmation prompt
./aws-resource-scanner.sh --interactive
```

### Method 3: Auto-Delete Mode (DANGEROUS!)

```bash
# Deletes everything automatically - USE WITH CAUTION!
./aws-resource-scanner.sh --delete
```

---

## 📋 What Resources Are Scanned

### Compute Resources:
- ✅ EC2 Instances (all states)
- ✅ Lambda Functions
- ✅ EBS Volumes (unattached)

### Networking Resources:
- ✅ VPCs (non-default)
- ✅ Subnets
- ✅ Internet Gateways
- ✅ NAT Gateways
- ✅ Transit Gateways
- ✅ Transit Gateway Attachments
- ✅ Route Tables
- ✅ Security Groups
- ✅ Elastic IPs

### Load Balancing:
- ✅ Application Load Balancers (ALB)
- ✅ Network Load Balancers (NLB)
- ✅ Classic Load Balancers

### Database:
- ✅ RDS Instances

### Storage:
- ✅ S3 Buckets (in current region)

---

## 📊 Sample Output

### Scan Mode Output:

```
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║           AWS Resource Scanner & Cleanup Tool                  ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

ℹ️  Region: us-east-1
ℹ️  Mode: --scan
ℹ️  Scan started: Sat Mar  8 12:00:00 UTC 2026

========================================
Scanning AWS Resources
========================================

ℹ️  Scanning EC2 Instances...
   → EC2 Instance: i-0abc123 running t2.micro EC2-VPC1
   → EC2 Instance: i-0def456 running t2.micro EC2-VPC2

ℹ️  Scanning RDS Instances...
✅ No RDS instances found

ℹ️  Scanning Transit Gateways...
   → Transit Gateway: tgw-0123456 available My-Transit-Gateway (~$36/month)

ℹ️  Scanning Load Balancers...
✅ No Load Balancers found

ℹ️  Scanning VPCs...
   → VPC: vpc-0abc123 10.0.0.0/16 VPC1
   → VPC: vpc-0def456 10.1.0.0/16 VPC2

ℹ️  Scanning Lambda Functions...
✅ No Lambda functions found

ℹ️  Scanning S3 Buckets...
   → S3 Bucket: my-test-bucket-12345

ℹ️  Scanning EBS Volumes...
✅ No unattached EBS volumes found

ℹ️  Scanning Elastic IPs...
✅ No Elastic IPs found

╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║                    SCAN COMPLETE                               ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

⚠️  Found 6 resources in region: us-east-1

ℹ️  Run with --delete flag to remove all resources
❌ WARNING: Deletion is IRREVERSIBLE!
```

---

## 🔄 Usage Modes

### 1. Scan Mode (--scan)

**Purpose**: Check what resources exist without deleting anything

**Usage**:
```bash
./aws-resource-scanner.sh --scan
```

**When to use**:
- First time running the script
- Regular audits of your AWS account
- Before deciding to delete resources
- To understand what you're paying for

**Safe**: ✅ Yes - No deletions

---

### 2. Interactive Mode (--interactive)

**Purpose**: Scan and ask for confirmation before deleting

**Usage**:
```bash
./aws-resource-scanner.sh --interactive
```

**Workflow**:
```
1. Scans all resources
2. Shows what was found
3. Asks: "Do you want to DELETE all these resources? (yes/no)"
4. If yes → Deletes everything
5. If no → Exits safely
```

**When to use**:
- When you want to delete but want one final confirmation
- When you're not 100% sure
- Recommended for most users

**Safe**: ⚠️ Requires confirmation

---

### 3. Auto-Delete Mode (--delete)

**Purpose**: Scan and delete everything automatically

**Usage**:
```bash
./aws-resource-scanner.sh --delete
```

**⚠️ DANGER**: No confirmation! Deletes immediately!

**When to use**:
- When you're absolutely certain
- In automated cleanup scripts
- When you've already verified with --scan

**Safe**: ❌ NO - Deletes immediately!

---

## 🔍 Detailed Deletion Process

### Order of Deletion:

```
1. EC2 Instances (terminate)
   ↓ Wait 10 seconds
   
2. RDS Instances (delete with no snapshot)
   
3. Load Balancers (all types)
   
4. Lambda Functions
   
5. Transit Gateways
   ↓ Wait 30 seconds
   
6. VPCs (with all dependencies)
   - NAT Gateways
   - Internet Gateways
   - Subnets
   - Route Tables
   - Security Groups
   
7. EBS Volumes (unattached)
   
8. Elastic IPs (release)
   
9. S3 Buckets (empty and delete)
```

---

## ⚠️ Important Warnings

### Before Running Delete:

1. **Backup Everything**
   - Export important data
   - Take snapshots if needed
   - Document configurations

2. **Verify Region**
   ```bash
   aws configure get region
   ```
   Make sure you're in the correct region!

3. **Check Default VPC**
   - Script skips default VPC
   - But deletes everything else

4. **S3 Buckets**
   - Script empties buckets before deleting
   - All data will be lost!

5. **RDS Instances**
   - Deleted without final snapshot
   - No way to recover!

---

## 💰 Cost Impact

### Resources That Cost Money When Running:

| Resource | Approximate Cost |
|----------|------------------|
| Transit Gateway | ~$36/month |
| NAT Gateway | ~$32/month |
| EC2 t2.micro | ~$8.50/month |
| RDS db.t3.micro | ~$15/month |
| Load Balancer | ~$16-22/month |
| Elastic IP (unattached) | ~$3.60/month |
| EBS gp3 | ~$0.08/GB/month |
| S3 Standard | ~$0.023/GB/month |

**Running this script can save you hundreds of dollars per month!**

---

## 🐛 Troubleshooting

### Issue 1: "Permission denied"

**Solution**:
```bash
chmod +x aws-resource-scanner.sh
```

### Issue 2: "Command not found: aws"

**Solution**: Use AWS CloudShell or install AWS CLI
```bash
# Mac
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Issue 3: "Unable to locate credentials"

**Solution**:
```bash
aws configure
```

### Issue 4: Some resources won't delete

**Reasons**:
- Resources have dependencies
- Resources are in "deleting" state
- Insufficient permissions

**Solution**:
- Wait 10-15 minutes
- Run script again
- Check AWS Console for errors

### Issue 5: Wrong region

**Solution**: Set region explicitly
```bash
export AWS_DEFAULT_REGION=us-east-1
./aws-resource-scanner.sh --scan
```

---

## 📋 Best Practices

### 1. Always Scan First

```bash
# Step 1: Scan to see what exists
./aws-resource-scanner.sh --scan

# Step 2: Review the output carefully

# Step 3: If you want to delete, use interactive mode
./aws-resource-scanner.sh --interactive
```

### 2. Check Multiple Regions

```bash
# Check us-east-1
export AWS_DEFAULT_REGION=us-east-1
./aws-resource-scanner.sh --scan

# Check us-west-2
export AWS_DEFAULT_REGION=us-west-2
./aws-resource-scanner.sh --scan

# Check eu-west-1
export AWS_DEFAULT_REGION=eu-west-1
./aws-resource-scanner.sh --scan
```

### 3. Regular Audits

Run weekly to catch forgotten resources:
```bash
# Add to crontab for weekly scans
0 9 * * 1 /path/to/aws-resource-scanner.sh --scan > /tmp/aws-scan.log
```

### 4. Save Scan Results

```bash
# Save output to file
./aws-resource-scanner.sh --scan > aws-resources-$(date +%Y%m%d).txt
```

### 5. Verify After Deletion

```bash
# Delete resources
./aws-resource-scanner.sh --delete

# Wait 15 minutes
sleep 900

# Verify everything is gone
./aws-resource-scanner.sh --scan
```

---

## 🔒 Safety Features

### Built-in Protections:

1. **Default VPC Protection**
   - Script skips default VPC
   - Won't delete AWS-managed resources

2. **Region Isolation**
   - Only affects current region
   - Other regions untouched

3. **Scan Before Delete**
   - Always scans first
   - Shows what will be deleted

4. **Interactive Confirmation**
   - Interactive mode asks for confirmation
   - Type "yes" to proceed

5. **Error Handling**
   - Continues even if some deletions fail
   - Doesn't stop on errors

---

## 📊 Use Cases

### 1. Lab Cleanup

After completing AWS labs:
```bash
./aws-resource-scanner.sh --interactive
```

### 2. Cost Optimization

Find and remove unused resources:
```bash
./aws-resource-scanner.sh --scan
# Review output
# Delete manually or use --interactive
```

### 3. Account Audit

Regular checks for forgotten resources:
```bash
# Monthly audit
./aws-resource-scanner.sh --scan > monthly-audit-$(date +%Y%m).txt
```

### 4. Environment Teardown

Completely clean a development environment:
```bash
# Make sure you're in the right region!
aws configure get region
./aws-resource-scanner.sh --delete
```

### 5. Pre-Billing Check

Before month-end, check for billable resources:
```bash
./aws-resource-scanner.sh --scan
```

---

## 🎓 Advanced Usage

### Scan Specific Resource Types

Edit the script to comment out unwanted scans:
```bash
# Comment out S3 scan if you want to keep buckets
# scan_s3_buckets
```

### Custom Region

```bash
# Scan specific region
AWS_DEFAULT_REGION=eu-west-1 ./aws-resource-scanner.sh --scan
```

### Automated Cleanup

```bash
# Automated cleanup (use with caution!)
#!/bin/bash
regions=("us-east-1" "us-west-2" "eu-west-1")
for region in "${regions[@]}"; do
    export AWS_DEFAULT_REGION=$region
    ./aws-resource-scanner.sh --scan
done
```

---

## ✅ Verification After Cleanup

### 1. Run Scanner Again

```bash
./aws-resource-scanner.sh --scan
```

**Expected**: "No resources found"

### 2. Check Billing Dashboard

1. Go to: AWS Console → Billing Dashboard
2. Check current month charges
3. Verify no ongoing costs

### 3. Use Verification Script

```bash
# Run the billing verification script
./verify-no-billing.sh
```

**Expected**: "NO BILLABLE RESOURCES DETECTED"

---

## 📞 Support

### If Something Goes Wrong:

1. **Check AWS Console**
   - Verify resource states
   - Look for error messages

2. **AWS Support**
   - Open support ticket
   - Provide script output

3. **Manual Cleanup**
   - Use AWS Console
   - Delete resources manually

---

## ⚠️ Final Warning

**This script is POWERFUL and DANGEROUS!**

- ❌ Deletion is IRREVERSIBLE
- ❌ No backups are created
- ❌ No snapshots are taken
- ❌ All data will be LOST

**Always:**
- ✅ Scan first with --scan
- ✅ Verify you're in the correct region
- ✅ Backup important data
- ✅ Use --interactive for confirmation
- ✅ Double-check before proceeding

---

*Resource Scanner Guide Version: 1.0*  
*Last Updated: March 2026*  
*Use at your own risk!*
