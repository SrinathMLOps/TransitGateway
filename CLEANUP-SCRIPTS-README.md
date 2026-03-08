# AWS Transit Gateway Lab - Cleanup Scripts

## 📋 Overview

Automated scripts to clean up all AWS Transit Gateway lab resources in 15-20 minutes, saving ~$58/month in ongoing charges.

---

## 🚀 Quick Start

### Option 1: AWS CloudShell (Recommended - No Setup Required)

**Best for**: Quick cleanup directly in AWS Console

1. **Open AWS CloudShell**
   - Log into AWS Console
   - Click the CloudShell icon (>_) in the top navigation bar
   - Wait for CloudShell to initialize

2. **Upload the script**
   ```bash
   # Copy the cleanup-script.sh content
   # In CloudShell, click Actions → Upload file
   # Or paste the script directly
   ```

3. **Run the script**
   ```bash
   chmod +x cleanup-script.sh
   ./cleanup-script.sh
   ```

4. **Confirm when prompted**
   - Type `yes` and press Enter
   - Wait 15-20 minutes for completion

---

### Option 2: Local Terminal (Mac/Linux)

**Prerequisites**: AWS CLI installed and configured

1. **Download the script**
   ```bash
   # Clone the repository or download cleanup-script.sh
   wget https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/cleanup-script.sh
   ```

2. **Make it executable**
   ```bash
   chmod +x cleanup-script.sh
   ```

3. **Run the script**
   ```bash
   ./cleanup-script.sh
   ```

4. **Confirm when prompted**
   - Type `yes` and press Enter

---

### Option 3: Windows PowerShell

**Prerequisites**: AWS CLI installed and configured

1. **Download the script**
   ```powershell
   # Download cleanup-script.ps1 from the repository
   ```

2. **Run PowerShell as Administrator**

3. **Execute the script**
   ```powershell
   .\cleanup-script.ps1
   ```

4. **Confirm when prompted**
   - Type `yes` and press Enter

---

## 📝 What Gets Deleted

The script automatically removes:

1. ✅ **EC2 Instances**
   - EC2-VPC1 (public instance)
   - EC2-VPC2 (private instance)

2. ✅ **Transit Gateway Resources**
   - Transit Gateway attachments (VPC1 and VPC2)
   - Transit Gateway itself

3. ✅ **VPC1 Resources**
   - VPC1 (10.0.0.0/16)
   - Public subnet
   - Internet Gateway
   - Route tables
   - Security groups

4. ✅ **VPC2 Resources**
   - VPC2 (10.1.0.0/16)
   - Private subnet
   - Route tables
   - Security groups

5. ✅ **Key Pair** (optional)
   - TransitGatewayKey

---

## ⏱️ Execution Timeline

| Step | Action | Time |
|------|--------|------|
| 1 | Terminate EC2 instances | 2-3 min |
| 2 | Delete TGW attachments | 2-3 min |
| 3 | Delete Transit Gateway | 5-10 min |
| 4 | Delete VPC2 | 1-2 min |
| 5 | Delete VPC1 | 1-2 min |
| 6 | Delete key pair | 1 min |
| 7 | Verify cleanup | 1 min |
| **Total** | **Complete cleanup** | **15-20 min** |

---

## 🔧 Configuration

If you used different names for resources, edit these variables at the top of the script:

**Bash (cleanup-script.sh):**
```bash
EC2_VPC1_NAME="EC2-VPC1"
EC2_VPC2_NAME="EC2-VPC2"
VPC1_NAME="VPC1"
VPC2_NAME="VPC2"
TGW_NAME="My-Transit-Gateway"
KEY_PAIR_NAME="TransitGatewayKey"
REGION="us-east-1"
```

**PowerShell (cleanup-script.ps1):**
```powershell
$EC2_VPC1_NAME = "EC2-VPC1"
$EC2_VPC2_NAME = "EC2-VPC2"
$VPC1_NAME = "VPC1"
$VPC2_NAME = "VPC2"
$TGW_NAME = "My-Transit-Gateway"
$KEY_PAIR_NAME = "TransitGatewayKey"
$REGION = "us-east-1"
```

---

## 📊 Script Output

The script provides color-coded output:

- 🔵 **Blue**: Section headers
- ✅ **Green**: Success messages
- ⚠️ **Yellow**: Warnings (non-critical)
- ❌ **Red**: Errors (requires attention)
- ℹ️ **Cyan**: Information

**Example output:**
```
========================================
STEP 1: Terminating EC2 Instances
========================================

ℹ️  Looking for EC2-VPC1 instance...
ℹ️  Terminating EC2-VPC1 (i-0abc123def456789)...
✅ EC2-VPC1 termination initiated
⏳ Waiting for instances to terminate (60 seconds)...
✅ EC2 instances terminated
```

---

## ✅ Verification

After script completion, verify cleanup:

### Automated Verification
The script automatically checks:
- EC2 instances terminated
- Transit Gateway deleted
- VPCs deleted
- All associated resources removed

### Manual Verification (Optional)

**Check AWS Console:**
1. **EC2 → Instances**: Only "Terminated" instances
2. **VPC → Transit Gateways**: No transit gateways
3. **VPC → Your VPCs**: Only default VPC remains
4. **Billing Dashboard**: Check for ongoing charges

**Using AWS CLI:**
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

---

## 🐛 Troubleshooting

### Issue 1: "Command not found: aws"

**Solution**: Install AWS CLI
```bash
# Mac
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Windows
# Download from: https://aws.amazon.com/cli/
```

### Issue 2: "Unable to locate credentials"

**Solution**: Configure AWS CLI
```bash
aws configure
# Enter your:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (us-east-1)
# - Default output format (json)
```

### Issue 3: Script fails with "Resource has dependencies"

**Solution**: 
- Wait 5 minutes for resources to fully terminate
- Run the script again
- Some resources (like Transit Gateway) take longer to delete

### Issue 4: "Permission denied" (Mac/Linux)

**Solution**: Make script executable
```bash
chmod +x cleanup-script.sh
```

### Issue 5: PowerShell execution policy error

**Solution**: Allow script execution
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 💰 Cost Impact

### Before Cleanup (Monthly):
- Transit Gateway: ~$36/month
- 2x EC2 t2.micro: ~$17/month
- Data transfer: ~$5/month
- **Total: ~$58/month** ⚠️

### After Cleanup:
- **Total: $0.00/month** ✅

### Lab Cost (1 hour):
- **Total: ~$0.05-$0.07** ✅

---

## 🔒 Safety Features

The script includes:

1. **Confirmation prompt**: Requires explicit "yes" to proceed
2. **Error handling**: Continues even if some resources don't exist
3. **Progress indicators**: Shows what's happening at each step
4. **Final verification**: Confirms all resources deleted
5. **Non-destructive**: Only deletes resources with specific names/tags

---

## 📞 Support

### If Cleanup Fails:

1. **Check the error message** - Script provides detailed error info
2. **Wait and retry** - Some resources take time to delete
3. **Manual cleanup** - Follow the [CLEANUP-GUIDE.md](./CLEANUP-GUIDE.md)
4. **AWS Support** - Open a support ticket if resources won't delete

### Useful Commands:

**Check what's still running:**
```bash
# List all resources in region
aws resourcegroupstaggingapi get-resources --region us-east-1

# Check specific services
aws ec2 describe-instances --region us-east-1
aws ec2 describe-transit-gateways --region us-east-1
aws ec2 describe-vpcs --region us-east-1
```

---

## 🎯 Best Practices

### Before Running:
1. ✅ Backup any important data
2. ✅ Take screenshots of configurations
3. ✅ Note down any custom settings
4. ✅ Verify you're in the correct AWS region

### After Running:
1. ✅ Check billing dashboard after 24 hours
2. ✅ Verify no ongoing charges
3. ✅ Delete local key files (.pem/.ppk)
4. ✅ Document lessons learned

---

## 📚 Additional Resources

- [Complete Architecture Guide](./AWS-Transit-Gateway-Architecture.md)
- [Manual Cleanup Guide](./CLEANUP-GUIDE.md)
- [Lab Summary](./Transit-Gateway-Lab-Summary.md)
- [AWS Transit Gateway Documentation](https://docs.aws.amazon.com/vpc/latest/tgw/)

---

## ⚠️ Important Notes

1. **Region**: Script defaults to `us-east-1`. Change if you used a different region.
2. **Resource Names**: Script looks for exact names. Update variables if you used different names.
3. **Execution Time**: Allow 15-20 minutes for complete cleanup.
4. **Verification**: Always verify cleanup in AWS Console after script completes.
5. **Billing**: Check billing dashboard 24 hours after cleanup to confirm no charges.

---

## 🎉 Success Criteria

Cleanup is successful when:

✅ All EC2 instances show "Terminated" status  
✅ Transit Gateway no longer appears in console  
✅ VPC1 and VPC2 are deleted  
✅ Only default VPC remains  
✅ No ongoing charges in billing dashboard  

---

*Script Version: 1.0*  
*Last Updated: March 2026*  
*Estimated Execution Time: 15-20 minutes*
