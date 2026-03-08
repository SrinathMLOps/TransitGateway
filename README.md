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

- `AWS-Transit-Gateway-Architecture.md` - Complete architecture documentation with detailed diagrams and explanations
- `Transit-Gateway-Lab-Summary.md` - Executive summary and quick reference
- `CLEANUP-GUIDE.md` - Comprehensive resource cleanup guide (20-30 minutes)
- `TransientGateway.jpg` - Lab output screenshot showing successful connectivity test

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
- [Complete Architecture Guide](./AWS-Transit-Gateway-Architecture.md)
- [Quick Summary](./Transit-Gateway-Lab-Summary.md)

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

See the complete [Cleanup Guide](./CLEANUP-GUIDE.md) for detailed step-by-step instructions.

## 🏆 Status

**Lab Status**: ✅ COMPLETED SUCCESSFULLY

---

*Lab Completed: March 2026*
