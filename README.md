# TransitGateway

AWS Transit Gateway Lab - Complete Implementation and Documentation

## 📋 Overview

This repository contains the complete implementation and documentation of an AWS Transit Gateway lab that connects two isolated VPCs to enable private communication between EC2 instances.

## 🎯 Lab Objective

Successfully connected two VPCs using AWS Transit Gateway with verified connectivity:
- **VPC1 (10.0.0.0/16)**: Public VPC with internet access
- **VPC2 (10.1.0.0/16)**: Private VPC with no internet access
- **Transit Gateway**: Central routing hub enabling inter-VPC communication

## ✅ Results

- **Connectivity**: 100% successful (0% packet loss)
- **Latency**: ~0.8ms average
- **Status**: All components operational

## 📁 Repository Contents

### Documentation
- `LAB-STEPS-VISUAL-GUIDE.md` - **Visual step-by-step lab guide** (START HERE!)
- `AWS-Transit-Gateway-Architecture.md` - Complete architecture documentation with detailed diagrams and explanations
- `Transit-Gateway-Lab-Summary.md` - Executive summary and quick reference
- `TransientGateway.jpg` - Lab output screenshot showing successful connectivity test

### Architecture Diagrams
- `aws_transit_gateway_exact_diagram.pdf` - Detailed architecture diagram (PDF format)
- `aws_transit_gateway_exact_diagram.txt` - Architecture diagram (text format)

### Cleanup Resources
- `HOW-TO-RUN-CLEANUP.md` - **Step-by-step guide to execute cleanup script** (READ THIS FIRST!)
- `CLEANUP-GUIDE.md` - Manual step-by-step cleanup guide (20-30 minutes)
- `CLEANUP-SCRIPTS-README.md` - Automated cleanup scripts documentation
- `cleanup-script.sh` - Bash script for Mac/Linux/CloudShell (15-20 minutes)
- `cleanup-script.ps1` - PowerShell script for Windows (15-20 minutes)

### Verification Resources
- `HOW-TO-VERIFY-NO-BILLING.md` - **Guide to verify no billable resources** (VERIFY CLEANUP!)
- `verify-no-billing.sh` - Bash verification script (2-3 minutes)
- `verify-no-billing.ps1` - PowerShell verification script (2-3 minutes)

## 🏗️ Architecture

```
Internet → VPC1 (Public) → Transit Gateway → VPC2 (Private)
```

### Components:
- 2 VPCs with different CIDR blocks
- 1 Transit Gateway with 2 VPC attachments
- 2 EC2 instances (1 public, 1 private)
- Security groups and route tables configured for inter-VPC communication

## 🚀 Key Features

- **Transitive Routing**: VPCs communicate through central Transit Gateway
- **Scalability**: Easy to add more VPCs (just create new attachments)
- **Security**: Multi-layer defense with network isolation and security groups
- **Cost-Effective**: ~$0.05/hour for lab environment

## 📚 Documentation

For detailed information, see:
- **[Visual Lab Guide](./LAB-STEPS-VISUAL-GUIDE.md)** - Step-by-step with diagrams (START HERE!)
- [Complete Architecture Guide](./AWS-Transit-Gateway-Architecture.md) - Deep dive into architecture
- [Quick Summary](./Transit-Gateway-Lab-Summary.md) - Executive overview

## 🎓 Skills Demonstrated

- VPC design and configuration
- Transit Gateway setup and management
- Route table configuration
- Security group implementation
- Network connectivity testing
- AWS resource management

## 💰 Cost

- **Lab Duration (1 hour)**: ~$0.05-$0.07
- **Monthly (if left running)**: ~$58/month ⚠️

## 🧹 Cleanup

**⚠️ CRITICAL**: Follow cleanup steps to avoid ~$58/month in charges!

### Quick Cleanup Options:

**Option 1: Automated Script (Recommended - 15-20 minutes)**

📖 **[Read the Execution Guide](./HOW-TO-RUN-CLEANUP.md)** for detailed step-by-step instructions

**Quick Start**:
```bash
# AWS CloudShell (no setup required)
curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/cleanup-script.sh
chmod +x cleanup-script.sh
./cleanup-script.sh
```

**Option 2: Manual Cleanup (20-30 minutes)**
Follow the detailed [Cleanup Guide](./CLEANUP-GUIDE.md)

See [Cleanup Scripts Documentation](./CLEANUP-SCRIPTS-README.md) for more options.

---

## ✅ Verify No Billing

**After cleanup, verify all resources are deleted:**

📖 **[Read the Verification Guide](./HOW-TO-VERIFY-NO-BILLING.md)** for complete instructions

**Quick Verification**:
```bash
# AWS CloudShell
curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/verify-no-billing.sh
chmod +x verify-no-billing.sh
./verify-no-billing.sh
```

**Success Message**:
```
╔════════════════════════════════════════════════════════════════╗
║              NO BILLABLE RESOURCES DETECTED                    ║
║  ✅ Monthly cost: $0.00                                        ║
╚════════════════════════════════════════════════════════════════╝
```

## 🏆 Status

**Lab Status**: ✅ COMPLETED SUCCESSFULLY

---

*Lab Completed: March 2026*
