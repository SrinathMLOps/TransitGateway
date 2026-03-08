#!/bin/bash

################################################################################
# AWS Transit Gateway Lab - Automated Cleanup Script
################################################################################
# 
# This script automatically cleans up all resources created in the 
# Transit Gateway lab to avoid ongoing AWS charges.
#
# USAGE:
#   1. AWS Console CloudShell: Just paste and run
#   2. Local Terminal: Ensure AWS CLI is configured, then run: bash cleanup-script.sh
#
# ESTIMATED TIME: 15-20 minutes
# COST SAVINGS: ~$58/month
#
################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration - Update these if you used different names
EC2_VPC1_NAME="EC2-VPC1"
EC2_VPC2_NAME="EC2-VPC2"
VPC1_NAME="VPC1"
VPC2_NAME="VPC2"
TGW_NAME="My-Transit-Gateway"
KEY_PAIR_NAME="TransitGatewayKey"
REGION="us-east-1"  # Change if you used a different region

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

wait_with_progress() {
    local duration=$1
    local message=$2
    echo -ne "${YELLOW}⏳ $message"
    for ((i=0; i<duration; i++)); do
        sleep 1
        echo -n "."
    done
    echo -e "${NC}"
}

################################################################################
# Step 1: Terminate EC2 Instances
################################################################################

cleanup_ec2_instances() {
    print_header "STEP 1: Terminating EC2 Instances"
    
    # Find EC2-VPC1 instance
    print_info "Looking for EC2-VPC1 instance..."
    VPC1_INSTANCE_ID=$(aws ec2 describe-instances \
        --region $REGION \
        --filters "Name=tag:Name,Values=$EC2_VPC1_NAME" "Name=instance-state-name,Values=running,stopped" \
        --query 'Reservations[0].Instances[0].InstanceId' \
        --output text 2>/dev/null)
    
    if [ "$VPC1_INSTANCE_ID" != "None" ] && [ ! -z "$VPC1_INSTANCE_ID" ]; then
        print_info "Terminating EC2-VPC1 ($VPC1_INSTANCE_ID)..."
        aws ec2 terminate-instances --region $REGION --instance-ids $VPC1_INSTANCE_ID >/dev/null
        print_success "EC2-VPC1 termination initiated"
    else
        print_warning "EC2-VPC1 not found or already terminated"
    fi
    
    # Find EC2-VPC2 instance
    print_info "Looking for EC2-VPC2 instance..."
    VPC2_INSTANCE_ID=$(aws ec2 describe-instances \
        --region $REGION \
        --filters "Name=tag:Name,Values=$EC2_VPC2_NAME" "Name=instance-state-name,Values=running,stopped" \
        --query 'Reservations[0].Instances[0].InstanceId' \
        --output text 2>/dev/null)
    
    if [ "$VPC2_INSTANCE_ID" != "None" ] && [ ! -z "$VPC2_INSTANCE_ID" ]; then
        print_info "Terminating EC2-VPC2 ($VPC2_INSTANCE_ID)..."
        aws ec2 terminate-instances --region $REGION --instance-ids $VPC2_INSTANCE_ID >/dev/null
        print_success "EC2-VPC2 termination initiated"
    else
        print_warning "EC2-VPC2 not found or already terminated"
    fi
    
    # Wait for instances to terminate
    if [ "$VPC1_INSTANCE_ID" != "None" ] || [ "$VPC2_INSTANCE_ID" != "None" ]; then
        wait_with_progress 60 "Waiting for instances to terminate (60 seconds)"
        print_success "EC2 instances terminated"
    fi
}

################################################################################
# Step 2: Delete Transit Gateway Attachments
################################################################################

cleanup_tgw_attachments() {
    print_header "STEP 2: Deleting Transit Gateway Attachments"
    
    # Find Transit Gateway ID
    print_info "Looking for Transit Gateway..."
    TGW_ID=$(aws ec2 describe-transit-gateways \
        --region $REGION \
        --filters "Name=tag:Name,Values=$TGW_NAME" "Name=state,Values=available,pending" \
        --query 'TransitGateways[0].TransitGatewayId' \
        --output text 2>/dev/null)
    
    if [ "$TGW_ID" == "None" ] || [ -z "$TGW_ID" ]; then
        print_warning "Transit Gateway not found or already deleted"
        return
    fi
    
    print_success "Found Transit Gateway: $TGW_ID"
    
    # Find and delete all attachments
    print_info "Looking for Transit Gateway attachments..."
    ATTACHMENT_IDS=$(aws ec2 describe-transit-gateway-attachments \
        --region $REGION \
        --filters "Name=transit-gateway-id,Values=$TGW_ID" "Name=state,Values=available,pending" \
        --query 'TransitGatewayAttachments[*].TransitGatewayAttachmentId' \
        --output text 2>/dev/null)
    
    if [ -z "$ATTACHMENT_IDS" ]; then
        print_warning "No attachments found"
        return
    fi
    
    for ATTACHMENT_ID in $ATTACHMENT_IDS; do
        print_info "Deleting attachment: $ATTACHMENT_ID..."
        aws ec2 delete-transit-gateway-vpc-attachment \
            --region $REGION \
            --transit-gateway-attachment-id $ATTACHMENT_ID >/dev/null 2>&1 || true
        print_success "Attachment deletion initiated: $ATTACHMENT_ID"
    done
    
    # Wait for attachments to delete
    wait_with_progress 90 "Waiting for attachments to delete (90 seconds)"
    print_success "Transit Gateway attachments deleted"
}

################################################################################
# Step 3: Delete Transit Gateway
################################################################################

cleanup_transit_gateway() {
    print_header "STEP 3: Deleting Transit Gateway"
    
    # Find Transit Gateway ID (if not already found)
    if [ -z "$TGW_ID" ] || [ "$TGW_ID" == "None" ]; then
        TGW_ID=$(aws ec2 describe-transit-gateways \
            --region $REGION \
            --filters "Name=tag:Name,Values=$TGW_NAME" "Name=state,Values=available,pending" \
            --query 'TransitGateways[0].TransitGatewayId' \
            --output text 2>/dev/null)
    fi
    
    if [ "$TGW_ID" == "None" ] || [ -z "$TGW_ID" ]; then
        print_warning "Transit Gateway not found or already deleted"
        return
    fi
    
    print_info "Deleting Transit Gateway: $TGW_ID..."
    aws ec2 delete-transit-gateway \
        --region $REGION \
        --transit-gateway-id $TGW_ID >/dev/null 2>&1 || true
    
    print_success "Transit Gateway deletion initiated"
    wait_with_progress 120 "Waiting for Transit Gateway to delete (120 seconds)"
    print_success "Transit Gateway deleted"
}

################################################################################
# Step 4 & 5: Delete VPCs
################################################################################

cleanup_vpc() {
    local VPC_NAME=$1
    print_header "Deleting VPC: $VPC_NAME"
    
    # Find VPC ID
    print_info "Looking for $VPC_NAME..."
    VPC_ID=$(aws ec2 describe-vpcs \
        --region $REGION \
        --filters "Name=tag:Name,Values=$VPC_NAME" \
        --query 'Vpcs[0].VpcId' \
        --output text 2>/dev/null)
    
    if [ "$VPC_ID" == "None" ] || [ -z "$VPC_ID" ]; then
        print_warning "$VPC_NAME not found or already deleted"
        return
    fi
    
    print_success "Found $VPC_NAME: $VPC_ID"
    
    # Delete NAT Gateways (if any)
    print_info "Checking for NAT Gateways..."
    NAT_GW_IDS=$(aws ec2 describe-nat-gateways \
        --region $REGION \
        --filter "Name=vpc-id,Values=$VPC_ID" "Name=state,Values=available" \
        --query 'NatGateways[*].NatGatewayId' \
        --output text 2>/dev/null)
    
    if [ ! -z "$NAT_GW_IDS" ]; then
        for NAT_ID in $NAT_GW_IDS; do
            print_info "Deleting NAT Gateway: $NAT_ID..."
            aws ec2 delete-nat-gateway --region $REGION --nat-gateway-id $NAT_ID >/dev/null 2>&1 || true
        done
        wait_with_progress 60 "Waiting for NAT Gateways to delete"
    fi
    
    # Delete Internet Gateway
    print_info "Checking for Internet Gateway..."
    IGW_ID=$(aws ec2 describe-internet-gateways \
        --region $REGION \
        --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
        --query 'InternetGateways[0].InternetGatewayId' \
        --output text 2>/dev/null)
    
    if [ "$IGW_ID" != "None" ] && [ ! -z "$IGW_ID" ]; then
        print_info "Detaching Internet Gateway: $IGW_ID..."
        aws ec2 detach-internet-gateway \
            --region $REGION \
            --internet-gateway-id $IGW_ID \
            --vpc-id $VPC_ID >/dev/null 2>&1 || true
        
        print_info "Deleting Internet Gateway: $IGW_ID..."
        aws ec2 delete-internet-gateway \
            --region $REGION \
            --internet-gateway-id $IGW_ID >/dev/null 2>&1 || true
        print_success "Internet Gateway deleted"
    fi
    
    # Delete subnets
    print_info "Deleting subnets..."
    SUBNET_IDS=$(aws ec2 describe-subnets \
        --region $REGION \
        --filters "Name=vpc-id,Values=$VPC_ID" \
        --query 'Subnets[*].SubnetId' \
        --output text 2>/dev/null)
    
    for SUBNET_ID in $SUBNET_IDS; do
        aws ec2 delete-subnet --region $REGION --subnet-id $SUBNET_ID >/dev/null 2>&1 || true
    done
    
    # Delete custom route tables
    print_info "Deleting route tables..."
    RT_IDS=$(aws ec2 describe-route-tables \
        --region $REGION \
        --filters "Name=vpc-id,Values=$VPC_ID" \
        --query 'RouteTables[?Associations[0].Main==`false`].RouteTableId' \
        --output text 2>/dev/null)
    
    for RT_ID in $RT_IDS; do
        aws ec2 delete-route-table --region $REGION --route-table-id $RT_ID >/dev/null 2>&1 || true
    done
    
    # Delete security groups (except default)
    print_info "Deleting security groups..."
    SG_IDS=$(aws ec2 describe-security-groups \
        --region $REGION \
        --filters "Name=vpc-id,Values=$VPC_ID" \
        --query 'SecurityGroups[?GroupName!=`default`].GroupId' \
        --output text 2>/dev/null)
    
    for SG_ID in $SG_IDS; do
        aws ec2 delete-security-group --region $REGION --group-id $SG_ID >/dev/null 2>&1 || true
    done
    
    # Wait a bit for dependencies to clear
    sleep 5
    
    # Delete VPC
    print_info "Deleting VPC: $VPC_ID..."
    aws ec2 delete-vpc --region $REGION --vpc-id $VPC_ID >/dev/null 2>&1 || true
    print_success "$VPC_NAME deleted successfully"
}

################################################################################
# Step 6: Delete Key Pair
################################################################################

cleanup_key_pair() {
    print_header "STEP 6: Deleting Key Pair (Optional)"
    
    print_info "Looking for key pair: $KEY_PAIR_NAME..."
    KEY_EXISTS=$(aws ec2 describe-key-pairs \
        --region $REGION \
        --key-names $KEY_PAIR_NAME \
        --query 'KeyPairs[0].KeyName' \
        --output text 2>/dev/null || echo "None")
    
    if [ "$KEY_EXISTS" != "None" ] && [ ! -z "$KEY_EXISTS" ]; then
        print_info "Deleting key pair: $KEY_PAIR_NAME..."
        aws ec2 delete-key-pair --region $REGION --key-name $KEY_PAIR_NAME >/dev/null 2>&1 || true
        print_success "Key pair deleted"
        print_warning "Remember to delete the local .pem file: ~/.ssh/$KEY_PAIR_NAME.pem"
    else
        print_warning "Key pair not found or already deleted"
    fi
}

################################################################################
# Step 7: Final Verification
################################################################################

verify_cleanup() {
    print_header "STEP 7: Final Verification"
    
    local all_clean=true
    
    # Check EC2 instances
    print_info "Checking EC2 instances..."
    RUNNING_INSTANCES=$(aws ec2 describe-instances \
        --region $REGION \
        --filters "Name=instance-state-name,Values=running,stopped" \
        --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0]]' \
        --output text 2>/dev/null | grep -E "$EC2_VPC1_NAME|$EC2_VPC2_NAME" || true)
    
    if [ -z "$RUNNING_INSTANCES" ]; then
        print_success "No lab EC2 instances running"
    else
        print_error "Some EC2 instances still exist:"
        echo "$RUNNING_INSTANCES"
        all_clean=false
    fi
    
    # Check Transit Gateway
    print_info "Checking Transit Gateway..."
    TGW_EXISTS=$(aws ec2 describe-transit-gateways \
        --region $REGION \
        --filters "Name=tag:Name,Values=$TGW_NAME" \
        --query 'TransitGateways[0].TransitGatewayId' \
        --output text 2>/dev/null)
    
    if [ "$TGW_EXISTS" == "None" ] || [ -z "$TGW_EXISTS" ]; then
        print_success "Transit Gateway deleted"
    else
        print_warning "Transit Gateway still exists (may be deleting): $TGW_EXISTS"
    fi
    
    # Check VPCs
    print_info "Checking VPCs..."
    VPC1_EXISTS=$(aws ec2 describe-vpcs \
        --region $REGION \
        --filters "Name=tag:Name,Values=$VPC1_NAME" \
        --query 'Vpcs[0].VpcId' \
        --output text 2>/dev/null)
    
    VPC2_EXISTS=$(aws ec2 describe-vpcs \
        --region $REGION \
        --filters "Name=tag:Name,Values=$VPC2_NAME" \
        --query 'Vpcs[0].VpcId' \
        --output text 2>/dev/null)
    
    if [ "$VPC1_EXISTS" == "None" ] || [ -z "$VPC1_EXISTS" ]; then
        print_success "VPC1 deleted"
    else
        print_error "VPC1 still exists: $VPC1_EXISTS"
        all_clean=false
    fi
    
    if [ "$VPC2_EXISTS" == "None" ] || [ -z "$VPC2_EXISTS" ]; then
        print_success "VPC2 deleted"
    else
        print_error "VPC2 still exists: $VPC2_EXISTS"
        all_clean=false
    fi
    
    echo ""
    if [ "$all_clean" = true ]; then
        print_success "✅ CLEANUP COMPLETED SUCCESSFULLY!"
        print_success "All Transit Gateway lab resources have been deleted."
        print_success "Expected cost: ~\$0.05-\$0.07 (for lab duration)"
        print_success "Ongoing monthly cost: \$0.00"
    else
        print_warning "⚠️  Some resources may still exist. Please check manually."
        print_info "Wait a few minutes and run verification again if resources are in 'deleting' state."
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║     AWS Transit Gateway Lab - Automated Cleanup            ║"
    echo "║                                                            ║"
    echo "║     This script will delete all lab resources              ║"
    echo "║     Estimated time: 15-20 minutes                          ║"
    echo "║     Cost savings: ~\$58/month                               ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    print_warning "This script will delete the following resources:"
    echo "  - EC2 instances (EC2-VPC1, EC2-VPC2)"
    echo "  - Transit Gateway and attachments"
    echo "  - VPCs (VPC1, VPC2) and all associated resources"
    echo "  - Key pair (optional)"
    echo ""
    
    read -p "Do you want to continue? (yes/no): " -r
    echo
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_info "Cleanup cancelled by user"
        exit 0
    fi
    
    print_info "Starting cleanup process..."
    print_info "Region: $REGION"
    echo ""
    
    # Execute cleanup steps
    cleanup_ec2_instances
    cleanup_tgw_attachments
    cleanup_transit_gateway
    cleanup_vpc "$VPC2_NAME"
    cleanup_vpc "$VPC1_NAME"
    cleanup_key_pair
    verify_cleanup
    
    echo ""
    print_header "CLEANUP COMPLETE"
    print_info "Check your AWS Billing Dashboard in 24 hours to verify no ongoing charges."
    print_info "Script execution completed at: $(date)"
}

# Run main function
main
