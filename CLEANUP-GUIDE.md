# AWS Transit Gateway Lab - Resource Cleanup Guide

## ⚠️ CRITICAL WARNING

**Failing to clean up resources will result in ongoing AWS charges!**

- Transit Gateway: ~$36/month
- EC2 Instances: ~$17/month
- **Total if left running: ~$58/month**

**Follow these steps IN ORDER to avoid charges.**

---

## 🧹 Cleanup Checklist

```
□ Step 1: Terminate EC2 Instances
□ Step 2: Delete Transit Gateway Attachments
□ Step 3: Delete Transit Gateway
□ Step 4: Delete VPC2
□ Step 5: Delete VPC1
□ Step 6: Delete Key Pair (Optional)
□ Step 7: Final Verification
```

---

## STEP 1 — Terminate EC2 Instances

**Time Required**: 2-3 minutes

### Actions:

1. Navigate to: **EC2 Console → Instances**
2. Select **EC2-VPC1** (hold Ctrl/Cmd to multi-select)
3. Select **EC2-VPC2**
4. Click: **Instance state → Terminate instance**
5. Confirm: **Terminate**

### Wait for Completion:

```
Instance State Progression:
Running → Shutting-down → Terminated ✅
```

⏰ **Wait 1-2 minutes** until both instances show "Terminated"

### Verification:

```
✅ EC2-VPC1: Instance state = Terminated
✅ EC2-VPC2: Instance state = Terminated
```

### Why This Step First:

EC2 instances must be terminated before deleting network resources. Running instances prevent VPC deletion.

---

## STEP 2 — Delete Transit Gateway Attachments

**Time Required**: 2-3 minutes

### Actions:

1. Navigate to: **VPC Console → Transit Gateway Attachments**
2. Select **VPC1-TGW-Attachment**
3. Select **VPC2-TGW-Attachment** (hold Ctrl/Cmd)
4. Click: **Actions → Delete Transit Gateway Attachment**
5. Confirm: **Delete**

### Wait for Completion:

```
Attachment State Progression:
Available → Deleting → (Disappears from list) ✅
```

⏰ **Wait 2-3 minutes** for both attachments to be deleted

### Verification:

```
✅ No attachments listed (or only unrelated attachments remain)
✅ Refresh page to confirm deletion
```

### Troubleshooting:

**If deletion fails:**
- Ensure EC2 instances are terminated
- Wait 5 minutes and retry
- Check for any dependencies in the error message

### Why This Step Second:

Transit Gateway attachments must be deleted before the Transit Gateway itself can be removed.

---

## STEP 3 — Delete Transit Gateway

**Time Required**: 5-10 minutes (longest step)

### Actions:

1. Navigate to: **VPC Console → Transit Gateways**
2. Select **My-Transit-Gateway**
3. Click: **Actions → Delete Transit Gateway**
4. Type: **delete** (to confirm)
5. Click: **Delete**

### Wait for Completion:

```
Transit Gateway State Progression:
Available → Deleting → (Disappears from list) ✅
```

⏰ **Wait 5-10 minutes** - This is the longest deletion process

### Verification:

```
✅ Transit Gateway no longer appears in list
✅ Refresh page after 10 minutes to confirm
```

### Troubleshooting:

**If stuck in "Deleting" state:**
- This is normal - can take up to 15 minutes
- Do NOT try to delete again
- Wait patiently and refresh periodically

**If deletion fails:**
- Verify all attachments are deleted (Step 2)
- Check for any VPN or Direct Connect attachments
- Review error message for specific dependencies

### Why This Step Third:

Transit Gateway must be deleted before VPCs to avoid dependency conflicts.

---

## STEP 4 — Delete VPC2

**Time Required**: 1-2 minutes

### Actions:

1. Navigate to: **VPC Console → Your VPCs**
2. Select **VPC2**
3. Click: **Actions → Delete VPC**
4. Type: **delete** (to confirm)
5. Click: **Delete**

### What Gets Automatically Deleted:

```
✅ VPC2-Private-Subnet
✅ VPC2-Private-RT (route table)
✅ VPC2-Private-SG (security group)
✅ Network ACLs associated with VPC2
✅ Any other VPC2 resources
```

### Verification:

```
✅ VPC2 no longer appears in VPC list
✅ Associated subnets deleted
✅ Associated route tables deleted
✅ Associated security groups deleted
```

### Troubleshooting:

**If deletion fails with "has dependencies":**

Check for:
- ENIs (Elastic Network Interfaces) still attached
- NAT Gateways (if you added any)
- VPC Endpoints (if you created any)
- Load Balancers in the VPC

**To find dependencies:**
```
1. VPC Console → Select VPC2
2. Look at "Resource map" tab
3. Delete any remaining resources shown
4. Retry VPC deletion
```

---

## STEP 5 — Delete VPC1

**Time Required**: 1-2 minutes

### Actions:

1. Navigate to: **VPC Console → Your VPCs**
2. Select **VPC1**
3. Click: **Actions → Delete VPC**
4. Type: **delete**
5. Click: **Delete**

### What Gets Automatically Deleted:

```
✅ VPC1-Public-Subnet
✅ VPC1-Public-RT (route table)
✅ VPC1-IGW (Internet Gateway)
✅ VPC1-Public-SG (security group)
✅ Network ACLs associated with VPC1
✅ Any other VPC1 resources
```

### Verification:

```
✅ VPC1 no longer appears in VPC list
✅ Only default VPC remains (if you have one)
✅ Internet Gateway deleted
✅ All associated resources removed
```

### Troubleshooting:

**If Internet Gateway won't detach:**
```
1. VPC Console → Internet Gateways
2. Select VPC1-IGW
3. Actions → Detach from VPC
4. Wait 1 minute
5. Actions → Delete Internet Gateway
6. Retry VPC1 deletion
```

**If deletion fails:**
- Check for remaining ENIs
- Look for Elastic IPs still allocated
- Verify all EC2 instances are terminated
- Check for Lambda functions in the VPC

---

## STEP 6 — Delete Key Pair (Optional)

**Time Required**: 1 minute

### Actions in AWS Console:

1. Navigate to: **EC2 Console → Key Pairs**
2. Select **TransitGatewayKey**
3. Click: **Actions → Delete**
4. Confirm: **Delete**

### Delete Local Key File:

**For Mac/Linux:**
```bash
rm ~/.ssh/TransitGatewayKey.pem
```

**For Windows:**
```powershell
# Navigate to where you saved the key
del C:\Path\To\TransitGatewayKey.ppk
```

### Verification:

```
✅ Key pair deleted from AWS Console
✅ Local .pem or .ppk file deleted
```

### Note:

This step is optional but recommended for security. If you plan to run the lab again, you can keep the key pair.

---

## STEP 7 — Final Verification

**Time Required**: 5 minutes

### Complete Verification Checklist:

#### EC2 Service:

**Instances:**
```
Navigate to: EC2 → Instances
✅ No instances in "Running" state
✅ No instances in "Stopped" state
✅ Only "Terminated" instances (OK to remain)
```

**Key Pairs:**
```
Navigate to: EC2 → Key Pairs
✅ TransitGatewayKey deleted (if you chose to delete it)
```

**Security Groups:**
```
Navigate to: EC2 → Security Groups
✅ VPC1-Public-SG deleted
✅ VPC2-Private-SG deleted
✅ Only default security groups remain
```

#### VPC Service:

**Transit Gateways:**
```
Navigate to: VPC → Transit Gateways
✅ No transit gateways listed
✅ My-Transit-Gateway deleted
```

**Transit Gateway Attachments:**
```
Navigate to: VPC → Transit Gateway Attachments
✅ No attachments listed
✅ VPC1-TGW-Attachment deleted
✅ VPC2-TGW-Attachment deleted
```

**VPCs:**
```
Navigate to: VPC → Your VPCs
✅ VPC1 deleted
✅ VPC2 deleted
✅ Only default VPC remains (if applicable)
```

**Subnets:**
```
Navigate to: VPC → Subnets
✅ VPC1-Public-Subnet deleted
✅ VPC2-Private-Subnet deleted
✅ Only default VPC subnets remain
```

**Route Tables:**
```
Navigate to: VPC → Route Tables
✅ VPC1-Public-RT deleted
✅ VPC2-Private-RT deleted
✅ Only default route tables remain
```

**Internet Gateways:**
```
Navigate to: VPC → Internet Gateways
✅ VPC1-IGW deleted
✅ No custom IGWs remain
✅ Only default VPC IGW (if applicable)
```

---

## 💰 Cost Verification

### Check Your AWS Bill:

1. Navigate to: **AWS Console → Billing Dashboard**
2. Click: **Bills**
3. Select current month
4. Look for charges:

**Expected charges (if cleaned up within 1 hour):**
```
Transit Gateway: ~$0.05
EC2 (if outside free tier): ~$0.02
Data Transfer: ~$0.00
─────────────────────────────
Total: ~$0.05-$0.07 ✅
```

**If you see ongoing charges:**
- Review the verification checklist above
- Check for resources you may have missed
- Look in all AWS regions (resources may be in different regions)

### Set Up Billing Alerts (Recommended):

```
1. Billing Dashboard → Budgets
2. Create budget
3. Set threshold: $1.00
4. Add email notification
5. Save
```

This prevents surprise charges in the future!

---

## 🔍 Common Cleanup Issues

### Issue 1: "Resource has dependencies" Error

**Symptom:**
```
Cannot delete VPC: The vpc 'vpc-xxxxx' has dependencies and cannot be deleted
```

**Solution:**
```
1. Check Resource Map:
   VPC Console → Select VPC → Resource map tab

2. Common dependencies:
   - ENIs (Elastic Network Interfaces)
   - NAT Gateways
   - VPC Endpoints
   - Load Balancers
   - RDS instances
   - Lambda functions

3. Delete dependencies first, then retry VPC deletion
```

### Issue 2: Transit Gateway Stuck in "Deleting"

**Symptom:**
```
Transit Gateway shows "Deleting" for more than 15 minutes
```

**Solution:**
```
1. This is usually normal - can take up to 20 minutes
2. Do NOT try to delete again
3. Wait patiently
4. If still stuck after 30 minutes:
   - Contact AWS Support
   - Check AWS Service Health Dashboard
```

### Issue 3: Internet Gateway Won't Detach

**Symptom:**
```
Cannot detach Internet Gateway from VPC
```

**Solution:**
```
1. Ensure all EC2 instances are terminated
2. Wait 5 minutes for ENIs to be released
3. Try detaching again:
   VPC → Internet Gateways → Select IGW → Actions → Detach
4. If still fails, check for:
   - Elastic IPs still associated
   - NAT Gateways using the IGW
```

### Issue 4: Security Group Can't Be Deleted

**Symptom:**
```
Security group is in use and cannot be deleted
```

**Solution:**
```
1. Check if any instances are still running
2. Look for other security groups referencing it:
   EC2 → Security Groups → Select SG → Inbound/Outbound rules
3. Remove references from other security groups
4. Retry deletion
```

### Issue 5: Subnet Can't Be Deleted

**Symptom:**
```
Subnet has dependencies and cannot be deleted
```

**Solution:**
```
1. Check for ENIs in the subnet:
   VPC → Network Interfaces → Filter by subnet
2. Delete or detach ENIs
3. Check for:
   - Running EC2 instances
   - Lambda functions
   - RDS instances
   - Load Balancers
4. Retry subnet deletion
```

---

## 🚨 Emergency Cleanup Script

If you need to quickly identify remaining resources, use AWS CLI:

### Prerequisites:
```bash
# Install AWS CLI if not already installed
# Configure with: aws configure
```

### Check for Resources:

```bash
# Check EC2 Instances
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table

# Check Transit Gateways
aws ec2 describe-transit-gateways --query 'TransitGateways[*].[TransitGatewayId,State]' --output table

# Check VPCs
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value|[0],CidrBlock]' --output table

# Check Transit Gateway Attachments
aws ec2 describe-transit-gateway-attachments --query 'TransitGatewayAttachments[*].[TransitGatewayAttachmentId,State,ResourceId]' --output table
```

### Automated Cleanup (Use with Caution):

```bash
# Terminate all running instances (DANGEROUS - use carefully!)
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].InstanceId' --output text | xargs -n 1 aws ec2 terminate-instances --instance-ids

# Note: For other resources, manual deletion is recommended
# to avoid accidentally deleting important resources
```

---

## ✅ Cleanup Completion Certificate

Once all steps are verified, you can confirm cleanup is complete:

```
╔════════════════════════════════════════════════════════╗
║                                                        ║
║         ✅ CLEANUP COMPLETED SUCCESSFULLY ✅           ║
║                                                        ║
║  All AWS Transit Gateway Lab resources have been      ║
║  properly deleted and cleaned up.                     ║
║                                                        ║
║  Expected Final Cost: ~$0.05-$0.07                    ║
║  Ongoing Monthly Cost: $0.00 ✅                       ║
║                                                        ║
║  You will not incur any further charges from          ║
║  this lab.                                            ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
```

---

## 📋 Cleanup Time Summary

| Step | Resource | Time Required |
|------|----------|---------------|
| 1 | EC2 Instances | 2-3 minutes |
| 2 | TGW Attachments | 2-3 minutes |
| 3 | Transit Gateway | 5-10 minutes |
| 4 | VPC2 | 1-2 minutes |
| 5 | VPC1 | 1-2 minutes |
| 6 | Key Pair | 1 minute |
| 7 | Verification | 5 minutes |
| **Total** | **All Resources** | **~20-30 minutes** |

---

## 🎓 Best Practices for Future Labs

### Before Starting Any Lab:

1. **Set up billing alerts** ($1, $5, $10 thresholds)
2. **Note the start time** to track duration
3. **Create a cleanup checklist** specific to the lab
4. **Set a calendar reminder** to clean up resources

### During the Lab:

1. **Tag all resources** with lab name and date
2. **Document resource IDs** in a text file
3. **Take screenshots** of successful configurations
4. **Note any custom configurations** for future reference

### After the Lab:

1. **Follow cleanup steps immediately**
2. **Verify all resources deleted**
3. **Check billing dashboard** after 24 hours
4. **Document lessons learned**

### Use AWS Tags:

```
Tag all resources with:
- Name: TransitGatewayLab
- Environment: Lab
- Date: 2026-03-08
- AutoDelete: Yes
```

This makes it easy to identify and clean up lab resources later.

---

## 📞 Need Help?

### If Cleanup Fails:

1. **AWS Support**: Open a support ticket if resources won't delete
2. **AWS Documentation**: Check specific service cleanup guides
3. **AWS Forums**: Search for similar issues
4. **Stack Overflow**: Community help for common problems

### Useful AWS Documentation Links:

- [Deleting a Transit Gateway](https://docs.aws.amazon.com/vpc/latest/tgw/tgw-transit-gateways.html#delete-tgw)
- [Deleting a VPC](https://docs.aws.amazon.com/vpc/latest/userguide/working-with-vpcs.html#VPC_Deleting)
- [Terminating EC2 Instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html)

---

## ⚠️ Final Reminder

**DO NOT skip cleanup steps!**

Even small resources left running can accumulate significant charges over time. A Transit Gateway alone costs ~$36/month if left running.

**Always verify cleanup completion** by checking the billing dashboard 24 hours after cleanup.

---

*Cleanup Guide Version: 1.0*  
*Last Updated: March 2026*  
*Estimated Cleanup Time: 20-30 minutes*
