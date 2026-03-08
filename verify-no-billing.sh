#!/bin/bash

################################################################################
# AWS Resource Verification Script - Check for Billable Resources
################################################################################
# 
# This script checks your AWS account for any billable resources that might
# be incurring charges in the current region.
#
# USAGE:
#   bash verify-no-billing.sh
#
# ESTIMATED TIME: 2-3 minutes
#
################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Get current region
REGION=$(aws configure get region 2>/dev/null || echo "us-east-1")

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "\n${BLUE}${BOLD}========================================${NC}"
    echo -e "${BLUE}${BOLD}$1${NC}"
    echo -e "${BLUE}${BOLD}========================================${NC}\n"
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
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_checking() {
    echo -e "${BLUE}🔍 Checking $1...${NC}"
}

################################################################################
# Resource Checking Functions
################################################################################

check_ec2_instances() {
    print_checking "EC2 Instances"
    
    local instances=$(aws ec2 describe-instances \
        --region $REGION \
        --filters "Name=instance-state-name,Values=running,stopped,stopping,pending" \
        --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,Tags[?Key==`Name`].Value|[0]]' \
        --output text 2>/dev/null)
    
    if [ -z "$instances" ]; then
        print_success "No running or stopped EC2 instances"
        return 0
    else
        print_error "Found EC2 instances (BILLABLE):"
        echo "$instances" | while read line; do
            echo -e "   ${RED}→ $line${NC}"
        done
        return 1
    fi
}

check_transit_gateways() {
    print_checking "Transit Gateways"
    
    local tgws=$(aws ec2 describe-transit-gateways \
        --region $REGION \
        --filters "Name=state,Values=available,pending" \
        --query 'TransitGateways[*].[TransitGatewayId,State,Tags[?Key==`Name`].Value|[0]]' \
        --output text 2>/dev/null)
    
    if [ -z "$tgws" ]; then
        print_success "No Transit Gateways"
        return 0
    else
        print_error "Found Transit Gateways (BILLABLE ~\$36/month each):"
        echo "$tgws" | while read line; do
            echo -e "   ${RED}→ $line${NC}"
        done
        return 1
    fi
}

check_nat_gateways() {
    print_checking "NAT Gateways"
    
    local nats=$(aws ec2 describe-nat-gateways \
        --region $REGION \
        --filter "Name=state,Values=available,pending" \
        --query 'NatGateways[*].[NatGatewayId,State,VpcId]' \
        --output text 2>/dev/null)
    
    if [ -z "$nats" ]; then
        print_success "No NAT Gateways"
        return 0
    else
        print_error "Found NAT Gateways (BILLABLE ~\$32/month each):"
        echo "$nats" | while read line; do
            echo -e "   ${RED}→ $line${NC}"
        done
        return 1
    fi
}

check_elastic_ips() {
    print_checking "Elastic IPs (unattached)"
    
    local eips=$(aws ec2 describe-addresses \
        --region $REGION \
        --query 'Addresses[?AssociationId==null].[PublicIp,AllocationId]' \
        --output text 2>/dev/null)
    
    if [ -z "$eips" ]; then
        print_success "No unattached Elastic IPs"
        return 0
    else
        print_error "Found unattached Elastic IPs (BILLABLE ~\$3.60/month each):"
        echo "$eips" | while read line; do
            echo -e "   ${RED}→ $line${NC}"
        done
        return 1
    fi
}

check_ebs_volumes() {
    print_checking "EBS Volumes"
    
    local volumes=$(aws ec2 describe-volumes \
        --region $REGION \
        --filters "Name=status,Values=available" \
        --query 'Volumes[*].[VolumeId,Size,VolumeType,State]' \
        --output text 2>/dev/null)
    
    if [ -z "$volumes" ]; then
        print_success "No unattached EBS volumes"
        return 0
    else
        print_warning "Found unattached EBS volumes (BILLABLE ~\$0.10/GB/month):"
        echo "$volumes" | while read line; do
            echo -e "   ${YELLOW}→ $line${NC}"
        done
        return 1
    fi
}

check_load_balancers() {
    print_checking "Load Balancers"
    
    # Check ALB/NLB
    local lbs=$(aws elbv2 describe-load-balancers \
        --region $REGION \
        --query 'LoadBalancers[*].[LoadBalancerName,Type,State.Code]' \
        --output text 2>/dev/null)
    
    # Check Classic LB
    local classic_lbs=$(aws elb describe-load-balancers \
        --region $REGION \
        --query 'LoadBalancerDescriptions[*].LoadBalancerName' \
        --output text 2>/dev/null)
    
    if [ -z "$lbs" ] && [ -z "$classic_lbs" ]; then
        print_success "No Load Balancers"
        return 0
    else
        print_error "Found Load Balancers (BILLABLE ~\$16-22/month each):"
        if [ ! -z "$lbs" ]; then
            echo "$lbs" | while read line; do
                echo -e "   ${RED}→ $line${NC}"
            done
        fi
        if [ ! -z "$classic_lbs" ]; then
            echo "$classic_lbs" | while read line; do
                echo -e "   ${RED}→ Classic: $line${NC}"
            done
        fi
        return 1
    fi
}

check_rds_instances() {
    print_checking "RDS Instances"
    
    local rds=$(aws rds describe-db-instances \
        --region $REGION \
        --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceClass,DBInstanceStatus]' \
        --output text 2>/dev/null)
    
    if [ -z "$rds" ]; then
        print_success "No RDS instances"
        return 0
    else
        print_error "Found RDS instances (BILLABLE - varies by instance type):"
        echo "$rds" | while read line; do
            echo -e "   ${RED}→ $line${NC}"
        done
        return 1
    fi
}

check_lambda_functions() {
    print_checking "Lambda Functions"
    
    local lambdas=$(aws lambda list-functions \
        --region $REGION \
        --query 'Functions[*].FunctionName' \
        --output text 2>/dev/null)
    
    if [ -z "$lambdas" ]; then
        print_success "No Lambda functions"
        return 0
    else
        print_info "Found Lambda functions (billable only when invoked):"
        echo "$lambdas" | tr '\t' '\n' | while read line; do
            echo -e "   ${CYAN}→ $line${NC}"
        done
        return 0  # Lambda is pay-per-use, not always billable
    fi
}

check_s3_buckets() {
    print_checking "S3 Buckets"
    
    local buckets=$(aws s3api list-buckets \
        --query 'Buckets[*].Name' \
        --output text 2>/dev/null)
    
    if [ -z "$buckets" ]; then
        print_success "No S3 buckets"
        return 0
    else
        print_info "Found S3 buckets (billable based on storage and requests):"
        echo "$buckets" | tr '\t' '\n' | while read line; do
            echo -e "   ${CYAN}→ $line${NC}"
        done
        return 0  # S3 billing depends on usage
    fi
}

check_vpn_connections() {
    print_checking "VPN Connections"
    
    local vpns=$(aws ec2 describe-vpn-connections \
        --region $REGION \
        --filters "Name=state,Values=available,pending" \
        --query 'VpnConnections[*].[VpnConnectionId,State,Type]' \
        --output text 2>/dev/null)
    
    if [ -z "$vpns" ]; then
        print_success "No VPN connections"
        return 0
    else
        print_error "Found VPN connections (BILLABLE ~\$36/month each):"
        echo "$vpns" | while read line; do
            echo -e "   ${RED}→ $line${NC}"
        done
        return 1
    fi
}

check_vpc_endpoints() {
    print_checking "VPC Endpoints (Interface type)"
    
    local endpoints=$(aws ec2 describe-vpc-endpoints \
        --region $REGION \
        --filters "Name=vpc-endpoint-type,Values=Interface" "Name=state,Values=available,pending" \
        --query 'VpcEndpoints[*].[VpcEndpointId,ServiceName,State]' \
        --output text 2>/dev/null)
    
    if [ -z "$endpoints" ]; then
        print_success "No Interface VPC Endpoints"
        return 0
    else
        print_warning "Found Interface VPC Endpoints (BILLABLE ~\$7.20/month each):"
        echo "$endpoints" | while read line; do
            echo -e "   ${YELLOW}→ $line${NC}"
        done
        return 1
    fi
}

################################################################################
# Display Results
################################################################################

display_final_results() {
    local has_billable=$1
    
    echo ""
    echo ""
    
    if [ $has_billable -eq 0 ]; then
        # No billable resources - SUCCESS
        echo -e "${GREEN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                                                                ║"
        echo "║                    🎉 EXCELLENT NEWS! 🎉                       ║"
        echo "║                                                                ║"
        echo "║              NO BILLABLE RESOURCES DETECTED                    ║"
        echo "║                                                                ║"
        echo "╠════════════════════════════════════════════════════════════════╣"
        echo "║                                                                ║"
        echo "║  ✅ Your AWS account is clean in region: $REGION"
        printf "║  %-62s ║\n" ""
        echo "║  ✅ No resources are currently incurring charges               ║"
        echo "║  ✅ Monthly cost: \$0.00                                        ║"
        echo "║  ✅ You can safely close this verification                     ║"
        echo "║                                                                ║"
        echo "╠════════════════════════════════════════════════════════════════╣"
        echo "║                                                                ║"
        echo "║  📊 Recommendation:                                            ║"
        echo "║     • Check your AWS Billing Dashboard in 24 hours            ║"
        echo "║     • Verify charges are \$0.00 or minimal                     ║"
        echo "║     • Set up billing alerts for future labs                   ║"
        echo "║                                                                ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
        
        echo -e "\n${GREEN}${BOLD}🎊 Congratulations! Your cleanup was successful! 🎊${NC}\n"
        
    else
        # Found billable resources - WARNING
        echo -e "${RED}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                                                                ║"
        echo "║                    ⚠️  WARNING! ⚠️                             ║"
        echo "║                                                                ║"
        echo "║              BILLABLE RESOURCES DETECTED                       ║"
        echo "║                                                                ║"
        echo "╠════════════════════════════════════════════════════════════════╣"
        echo "║                                                                ║"
        echo "║  ❌ Your AWS account has resources incurring charges           ║"
        echo "║  ❌ Region: $REGION"
        printf "║  %-62s ║\n" ""
        echo "║  ❌ These resources are costing you money right now!           ║"
        echo "║                                                                ║"
        echo "╠════════════════════════════════════════════════════════════════╣"
        echo "║                                                                ║"
        echo "║  🔧 Action Required:                                           ║"
        echo "║     1. Review the resources listed above                      ║"
        echo "║     2. Delete unnecessary resources immediately               ║"
        echo "║     3. Run cleanup script if lab resources remain             ║"
        echo "║     4. Re-run this verification script after cleanup          ║"
        echo "║                                                                ║"
        echo "║  💰 Estimated Monthly Cost:                                    ║"
        echo "║     • Transit Gateway: ~\$36/month each                        ║"
        echo "║     • NAT Gateway: ~\$32/month each                            ║"
        echo "║     • EC2 Instance: ~\$8.50/month (t2.micro)                   ║"
        echo "║     • Load Balancer: ~\$16-22/month each                       ║"
        echo "║                                                                ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
        
        echo -e "\n${YELLOW}${BOLD}⚡ Take action now to avoid unnecessary charges! ⚡${NC}\n"
        
        echo -e "${CYAN}Quick Cleanup Command:${NC}"
        echo -e "${CYAN}curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/cleanup-script.sh${NC}"
        echo -e "${CYAN}chmod +x cleanup-script.sh && ./cleanup-script.sh${NC}\n"
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    echo -e "${BLUE}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║        AWS Billable Resources Verification Script              ║"
    echo "║                                                                ║"
    echo "║     Checking for resources that may incur charges              ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    print_info "Current AWS Region: ${BOLD}$REGION${NC}"
    print_info "Scan started at: $(date)"
    echo ""
    
    # Track if any billable resources found
    local has_billable=0
    
    # Run all checks
    print_header "Checking High-Cost Resources"
    check_ec2_instances || has_billable=1
    check_transit_gateways || has_billable=1
    check_nat_gateways || has_billable=1
    check_vpn_connections || has_billable=1
    check_load_balancers || has_billable=1
    check_rds_instances || has_billable=1
    
    print_header "Checking Medium-Cost Resources"
    check_vpc_endpoints || has_billable=1
    check_elastic_ips || has_billable=1
    check_ebs_volumes || has_billable=1
    
    print_header "Checking Low-Cost/Usage-Based Resources"
    check_lambda_functions
    check_s3_buckets
    
    # Display final results
    display_final_results $has_billable
    
    # Exit with appropriate code
    if [ $has_billable -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main
