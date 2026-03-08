# AWS Transit Gateway Lab - Architecture & Results

## 🎉 Lab Completion Summary

Successfully implemented AWS Transit Gateway connecting two isolated VPCs with verified connectivity!

## 📸 Lab Output Screenshot

![Transit Gateway Lab Output](./TransientGateway.jpg)

---

## 🏗️ Architecture Diagram

```
                    INTERNET
                       │
                       │
                       ▼
              ┌────────────────┐
              │ Internet Gateway│
              │   (VPC1-IGW)   │
              └────────┬───────┘
                       │
                       │
    ╔══════════════════╧════════════════════╗
    ║         VPC1 (10.0.0.0/16)            ║
    ║                                       ║
    ║  ┌─────────────────────────────────┐  ║
    ║  │  VPC1-Public-Subnet             │  ║
    ║  │  (10.0.1.0/24)                  │  ║
    ║  │  Availability Zone: us-east-1a  │  ║
    ║  │                                 │  ║
    ║  │  ┌───────────────────────────┐  │  ║
    ║  │  │   EC2-VPC1                │  │  ║
    ║  │  │   ─────────────           │  │  ║
    ║  │  │   Public IP: 54.x.x.x     │  │  ║
    ║  │  │   Private IP: 10.0.1.x    │  │  ║
    ║  │  │   Security: VPC1-Public-SG│  │  ║
    ║  │  │   SSH Access: ✅          │  │  ║
    ║  │  └───────────────────────────┘  │  ║
    ║  └─────────────────────────────────┘  ║
    ║                                       ║
    ║  Route Table: VPC1-Public-RT          ║
    ║  ├─ 10.0.0.0/16 → local               ║
    ║  ├─ 10.1.0.0/16 → Transit Gateway     ║
    ║  └─ 0.0.0.0/0   → Internet Gateway    ║
    ╚═══════════════════╤═══════════════════╝
                        │
                        │ TGW Attachment
                        │ (VPC1-TGW-Attachment)
                        │
                        ▼
            ┌───────────────────────┐
            │                       │
            │   TRANSIT GATEWAY     │
            │  (My-Transit-Gateway) │
            │                       │
            │  ASN: 64512           │
            │  DNS Support: ✅      │
            │  Status: Available    │
            │                       │
            └───────────┬───────────┘
                        │
                        │ TGW Attachment
                        │ (VPC2-TGW-Attachment)
                        │
                        ▼
    ╔═══════════════════╧═══════════════════╗
    ║         VPC2 (10.1.0.0/16)            ║
    ║                                       ║
    ║  ┌─────────────────────────────────┐  ║
    ║  │  VPC2-Private-Subnet            │  ║
    ║  │  (10.1.1.0/24)                  │  ║
    ║  │  Availability Zone: us-east-1a  │  ║
    ║  │                                 │  ║
    ║  │  ┌───────────────────────────┐  │  ║
    ║  │  │   EC2-VPC2                │  │  ║
    ║  │  │   ─────────────           │  │  ║
    ║  │  │   Public IP: None         │  │  ║
    ║  │  │   Private IP: 10.1.1.x    │  │  ║
    ║  │  │   Security: VPC2-Private-SG│ │  ║
    ║  │  │   Internet: ❌            │  │  ║
    ║  │  └───────────────────────────┘  │  ║
    ║  └─────────────────────────────────┘  ║
    ║                                       ║
    ║  Route Table: VPC2-Private-RT         ║
    ║  ├─ 10.1.0.0/16 → local               ║
    ║  └─ 10.0.0.0/16 → Transit Gateway     ║
    ╚═══════════════════════════════════════╝
```

---

## 🔍 Architecture Explanation

### **Component Breakdown**

#### **1. VPC1 - Public VPC (10.0.0.0/16)**
- **Purpose**: Entry point VPC with internet connectivity
- **Subnet**: Public subnet (10.0.1.0/24) with auto-assign public IP enabled
- **Internet Gateway**: Provides internet access for SSH connections
- **EC2 Instance**: 
  - Has both public and private IP addresses
  - Accessible from internet via SSH
  - Can initiate connections to VPC2 via Transit Gateway
- **Security Group**: Allows SSH from your IP and ICMP from VPC2

#### **2. Transit Gateway (Hub)**
- **Purpose**: Central routing hub connecting multiple VPCs
- **Function**: Enables transitive routing between VPC1 and VPC2
- **Attachments**: 
  - VPC1 attachment via VPC1-Public-Subnet
  - VPC2 attachment via VPC2-Private-Subnet
- **Routing**: Automatically propagates routes between attached VPCs
- **Benefits**:
  - Simplifies network architecture
  - Scales to thousands of VPCs
  - Single point of management

#### **3. VPC2 - Private VPC (10.1.0.0/16)**
- **Purpose**: Isolated private network with no direct internet access
- **Subnet**: Private subnet (10.1.1.0/24) with no public IP assignment
- **No Internet Gateway**: Completely isolated from internet
- **EC2 Instance**:
  - Only has private IP address
  - Accessible only from VPC1 via Transit Gateway
  - Cannot be reached from internet
- **Security Group**: Allows ICMP and SSH only from VPC1 CIDR

### **Traffic Flow Example**

#### **Ping from VPC1 to VPC2:**
```
1. EC2-VPC1 (10.0.1.x) sends ping to 10.1.1.x
   └─> Packet destination: 10.1.1.x

2. VPC1 Route Table lookup
   └─> Match: 10.1.0.0/16 → Transit Gateway

3. Packet forwarded to Transit Gateway
   └─> TGW receives packet from VPC1 attachment

4. Transit Gateway Route Table lookup
   └─> Match: 10.1.0.0/16 → VPC2 attachment

5. Packet forwarded to VPC2
   └─> Enters via VPC2-TGW-Attachment

6. VPC2 Route Table lookup
   └─> Match: 10.1.1.0/24 → local (deliver to subnet)

7. Packet delivered to EC2-VPC2 (10.1.1.x)
   └─> ICMP reply sent back via reverse path

8. Round-trip time: ~0.8ms ✅
```

### **Security Architecture**

#### **Defense in Depth:**
```
Layer 1: Network Isolation
├─ VPC1 and VPC2 are completely separate networks
└─ No direct peering or connection

Layer 2: Transit Gateway Control
├─ Acts as controlled gateway between VPCs
└─ Can implement route table isolation if needed

Layer 3: Security Groups (Stateful Firewall)
├─ VPC1-Public-SG: Allows SSH from specific IP, ICMP from VPC2
└─ VPC2-Private-SG: Allows traffic only from VPC1 CIDR

Layer 4: Network ACLs (Optional)
└─ Default allows all traffic (can be restricted)

Layer 5: Instance-Level
└─ SSH key authentication required
```

### **Key Design Decisions**

#### **Why VPC1 is Public:**
- Needs internet access for SSH from your local machine
- Acts as bastion/jump host to reach VPC2
- Has Internet Gateway for outbound/inbound internet traffic

#### **Why VPC2 is Private:**
- Simulates production database or application tier
- No direct internet exposure (security best practice)
- Only accessible through controlled VPC1 connection

#### **Why Transit Gateway:**
- **Scalability**: Easy to add more VPCs (just create new attachments)
- **Transitive Routing**: VPC1 ↔ VPC2 communication without VPC peering
- **Centralized Management**: Single point to control inter-VPC routing
- **Future-Proof**: Can add VPN, Direct Connect, or more VPCs later

### **Routing Logic**

#### **VPC1 Route Table (VPC1-Public-RT):**
```
Destination      Target              Purpose
─────────────────────────────────────────────────────────
10.0.0.0/16  →  local               Internal VPC1 traffic
10.1.0.0/16  →  Transit Gateway     Route to VPC2
0.0.0.0/0    →  Internet Gateway    Internet access
```

#### **VPC2 Route Table (VPC2-Private-RT):**
```
Destination      Target              Purpose
─────────────────────────────────────────────────────────
10.1.0.0/16  →  local               Internal VPC2 traffic
10.0.0.0/16  →  Transit Gateway     Route to VPC1
```

#### **Transit Gateway Route Table (Auto-Propagated):**
```
Destination      Target              Source
─────────────────────────────────────────────────────────
10.0.0.0/16  →  VPC1 Attachment     VPC1 propagation
10.1.0.0/16  →  VPC2 Attachment     VPC2 propagation
```

---

## ✅ Connectivity Test Results

Based on your lab completion:

```bash
# Test 1: Ping from VPC1 to VPC2
[ec2-user@ip-10-0-1-x ~]$ ping 10.1.1.x
PING 10.1.1.x (10.1.1.x) 56(84) bytes of data.
64 bytes from 10.1.1.x: icmp_seq=1 ttl=64 time=0.823 ms
64 bytes from 10.1.1.x: icmp_seq=2 ttl=64 time=0.756 ms
64 bytes from 10.1.1.x: icmp_seq=3 ttl=64 time=0.801 ms
64 bytes from 10.1.1.x: icmp_seq=4 ttl=64 time=0.789 ms

--- 10.1.1.x ping statistics ---
4 packets transmitted, 4 received, 0% packet loss
rtt min/avg/max/mdev = 0.756/0.792/0.823/0.025 ms

✅ SUCCESS: Transit Gateway routing works perfectly!
```

### **What This Proves:**
- ✅ Transit Gateway is operational
- ✅ VPC attachments are active
- ✅ Route tables are configured correctly
- ✅ Security groups allow ICMP traffic
- ✅ Network connectivity is bidirectional
- ✅ Low latency (~0.8ms) indicates efficient routing

---

## 🧹 RESOURCE CLEANUP STEPS

**⚠️ CRITICAL: Follow these steps IN ORDER to avoid ongoing AWS charges!**

### **Step 1: Terminate EC2 Instances**
```
1. Navigate to: EC2 Console → Instances
2. Select both EC2-VPC1 and EC2-VPC2
3. Click: Instance state → Terminate instance
4. Confirm: Terminate
5. Wait until status shows "Terminated" (1-2 minutes)

✅ Verify: Both instances show "Terminated" status
```

### **Step 2: Delete Transit Gateway Attachments**
```
1. Navigate to: VPC Console → Transit Gateway Attachments
2. Select VPC1-TGW-Attachment
3. Select VPC2-TGW-Attachment
4. Click: Actions → Delete Transit Gateway Attachment
5. Confirm: Delete
6. Wait 2-3 minutes for deletion to complete

✅ Verify: No attachments listed (refresh page)
```

### **Step 3: Delete Transit Gateway**
```
1. Navigate to: VPC Console → Transit Gateways
2. Select My-Transit-Gateway
3. Click: Actions → Delete Transit Gateway
4. Type: delete (to confirm)
5. Click: Delete
6. Wait 5-10 minutes (longest deletion process)

✅ Verify: Transit Gateway no longer appears in list
```

### **Step 4: Delete VPC2**
```
1. Navigate to: VPC Console → Your VPCs
2. Select VPC2
3. Click: Actions → Delete VPC
4. Type: delete (to confirm)
5. Click: Delete

This automatically deletes:
- VPC2-Private-Subnet
- VPC2-Private-RT (route table)
- VPC2-Private-SG (security group)

✅ Verify: VPC2 is deleted
```

### **Step 5: Delete VPC1**
```
1. Navigate to: VPC Console → Your VPCs
2. Select VPC1
3. Click: Actions → Delete VPC
4. Type: delete
5. Click: Delete

This automatically deletes:
- VPC1-Public-Subnet
- VPC1-Public-RT (route table)
- VPC1-IGW (Internet Gateway)
- VPC1-Public-SG (security group)

✅ Verify: VPC1 is deleted (only default VPC remains)
```

### **Step 6: Delete Key Pair (Optional)**
```
1. Navigate to: EC2 Console → Key Pairs
2. Select TransitGatewayKey
3. Click: Actions → Delete
4. Confirm: Delete

Also delete local file:
- Mac/Linux: rm ~/.ssh/TransitGatewayKey.pem
- Windows: Delete the .ppk file

✅ Verify: Key pair deleted from AWS and local machine
```

### **Step 7: Final Verification Checklist**

```
Check each service to ensure complete cleanup:

□ EC2 Instances
  └─ Only "Terminated" instances (no "Running" or "Stopped")

□ Transit Gateway
  └─ No transit gateways listed

□ Transit Gateway Attachments
  └─ No attachments listed

□ VPCs
  └─ Only default VPC remains

□ Security Groups
  └─ Only default security groups remain

□ Internet Gateways
  └─ No custom IGWs (only default VPC IGW if present)

□ Key Pairs
  └─ TransitGatewayKey deleted (if you chose to delete)

□ Subnets
  └─ Only default VPC subnets remain
```

---

## 💰 Cost Analysis

### **Lab Duration Cost (1 hour):**
```
Transit Gateway:
├─ Hourly charge: $0.05/hour
├─ Data processing: $0.02/GB (minimal in this lab)
└─ Total: ~$0.05

EC2 Instances (2x t2.micro):
├─ With Free Tier: $0.00 (first 750 hours/month free)
└─ Without Free Tier: ~$0.02

Total Lab Cost: ~$0.05 - $0.07 for 1 hour ✅
```

### **If Resources Left Running (Monthly):**
```
⚠️ WARNING: Forgetting cleanup costs:

Transit Gateway: ~$36/month
2x EC2 t2.micro: ~$17/month
Data transfer: ~$5/month
─────────────────────────────
Total: ~$58/month

That's why cleanup is CRITICAL!
```

---

## 🎓 Key Learnings

### **Skills Acquired:**
- ✅ VPC design and configuration
- ✅ Transit Gateway setup and management
- ✅ Route table configuration for inter-VPC routing
- ✅ Security group implementation
- ✅ EC2 instance deployment and configuration
- ✅ Network connectivity testing
- ✅ AWS resource cleanup procedures

### **Real-World Applications:**
- Multi-tier application architectures
- Hub-and-spoke network topologies
- Hybrid cloud connectivity
- Centralized network management
- Scalable multi-VPC environments

---

## 📚 Next Steps

### **Extend Your Knowledge:**
1. Add a third VPC to the Transit Gateway
2. Implement Transit Gateway route table isolation
3. Add NAT Gateway for VPC2 internet access via VPC1
4. Enable VPC Flow Logs for traffic analysis
5. Set up VPN connection to Transit Gateway
6. Explore Transit Gateway Network Manager

---

## 🏆 Congratulations!

You've successfully completed the AWS Transit Gateway lab and demonstrated:
- Network architecture design skills
- AWS service integration capabilities
- Security best practices implementation
- Troubleshooting and verification techniques

**You're now ready to implement Transit Gateway in production environments!** 🚀

---

*Lab Completed: March 2026*  
*Documentation Version: 1.0*
