# Cleanup Script Execution - Quick Reference

## 🚀 Fastest Way to Clean Up (Copy & Paste)

### AWS CloudShell (Recommended)

1. **Open CloudShell** in AWS Console (click >_ icon)

2. **Copy and paste these commands**:

```bash
# Download script
curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/cleanup-script.sh

# Make executable
chmod +x cleanup-script.sh

# Run script
./cleanup-script.sh
```

3. **Type `yes`** when prompted

4. **Wait 15-20 minutes** for completion

---

## ✅ Expected Output

```
╔════════════════════════════════════════════════════════════╗
║     AWS Transit Gateway Lab - Automated Cleanup            ║
║     Estimated time: 15-20 minutes                          ║
║     Cost savings: ~$58/month                               ║
╚════════════════════════════════════════════════════════════╝

Do you want to continue? (yes/no): yes

========================================
STEP 1: Terminating EC2 Instances
========================================
✅ EC2 instances terminated

========================================
STEP 2: Deleting Transit Gateway Attachments
========================================
✅ Transit Gateway attachments deleted

========================================
STEP 3: Deleting Transit Gateway
========================================
✅ Transit Gateway deleted

========================================
STEP 4: Deleting VPC2
========================================
✅ VPC2 deleted successfully

========================================
STEP 5: Deleting VPC1
========================================
✅ VPC1 deleted successfully

========================================
STEP 6: Deleting Key Pair
========================================
✅ Key pair deleted

========================================
STEP 7: Final Verification
========================================
✅ No lab EC2 instances running
✅ Transit Gateway deleted
✅ VPC1 deleted
✅ VPC2 deleted

✅ CLEANUP COMPLETED SUCCESSFULLY!
```

---

## 📋 Verification Checklist

After script completes, verify in AWS Console:

- [ ] EC2 → Instances: Only "Terminated" instances
- [ ] VPC → Transit Gateways: Empty
- [ ] VPC → Your VPCs: Only default VPC
- [ ] EC2 → Security Groups: Only default groups

---

## 🐛 Quick Troubleshooting

**Problem**: "Permission denied"  
**Solution**: Run `chmod +x cleanup-script.sh`

**Problem**: "Command not found: aws"  
**Solution**: Use CloudShell (AWS CLI pre-installed)

**Problem**: Script fails midway  
**Solution**: Run the script again (it skips deleted resources)

**Problem**: Resources still exist  
**Solution**: Wait 5 minutes (Transit Gateway takes time to delete)

---

## 💰 Cost Check

24 hours after cleanup:
1. Go to: AWS Console → Billing Dashboard
2. Expected charge: ~$0.05-$0.07 (lab duration only)
3. Ongoing monthly cost: $0.00 ✅

---

## 📚 Detailed Guides

- **Full Execution Guide**: [HOW-TO-RUN-CLEANUP.md](./HOW-TO-RUN-CLEANUP.md)
- **Manual Cleanup**: [CLEANUP-GUIDE.md](./CLEANUP-GUIDE.md)
- **Script Documentation**: [CLEANUP-SCRIPTS-README.md](./CLEANUP-SCRIPTS-README.md)

---

## ⚠️ Important

- **Don't interrupt** the script while running
- **Verify cleanup** in AWS Console after completion
- **Check billing** 24 hours later
- **Delete local key file**: `rm ~/.ssh/TransitGatewayKey.pem`

---

*Quick Reference Version: 1.0*  
*Execution Time: 15-20 minutes*  
*Cost Savings: ~$58/month*
