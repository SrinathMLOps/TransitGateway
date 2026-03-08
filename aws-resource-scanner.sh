#!/bin/bash

################################################################################
# AWS Resource Scanner & Cleanup Script
################################################################################
# 
# This script scans ALL AWS resources in the current region and provides
# options to delete them. Use with EXTREME CAUTION!
#
# USAGE:
#   ./aws-resource-scanner.sh --scan          # Scan only (safe)
#   ./aws-resource-scanner.sh --delete        # Scan and delete (DANGEROUS!)
#   ./aws-resource-scanner.sh --interactive   # Interactive mode
#
# ESTIMATED TIME: 5-10 minutes (scan), 20-30 minutes (delete)
#
################################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Get current region
REGION=$(aws configure get region 2>/dev/null || echo "us-east-1")

# Mode selection
MODE="${1:---scan}"

# Resource tracking
declare -A RESOURCES_FOUND
TOTAL_RESOURCES=0

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

print_resource() {
    echo -e "${MAGENTA}   → $1${NC}"
    ((TOTAL_RESOURCES++))
}

confirm_action() {
    local prompt="$1"
    read -p "$(echo -e ${YELLOW}${prompt}${NC}) (yes/no): " -r
    echo
    [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]
}

################################################################################
# EC2 Resources
################################################################################

scan_ec2_instances() {
    print_info "Scanning EC2 Instances..."
    
    local instances=$(aws ec2 describe-instances \
        --region $REGION \
        --filters "Name=instance-state-name,Values=running,stopped,stopping,pending" \
        --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,Tags[?Key==`Name`].Value|[0]]' \
        --output text 2>/dev/null)
    
    if [ ! -z "$instances" ]; then
        RESOURCES_FOUND[ec2_instances]="$instances"
        echo "$instances" | while read line; do
            print_resource "EC2 Instance: $line"
        done
    fi
}

delete_ec2_instances() {
    if [ -z "${RESOURCES_FOUND[ec2_instances]}" ]; then
        return
    fi
    
    print_warning "Terminating EC2 Instances..."
    
    echo "${RESOURCES_FOUND[ec2_instances]}" | while read id state type name; do
        if [ ! -z "$id" ]; then
            print_info "Terminating: $id ($name)"
            aws ec2 terminate-instances --region $REGION --instance-ids $id >/dev/null 2>&1 || true
        fi
    done
    
    print_success "EC2 instances termination initiated"
}

################################################################################
# VPC Resources
################################################################################

scan_vpcs() {
    print_info "Scanning VPCs..."
    
    local vpcs=$(aws ec2 describe-vpcs \
        --region $REGION \
        --filters "Name=isDefault,Values=false" \
        --query 'Vpcs[*].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' \
        --output text 2>/dev/null)
    
    if [ ! -z "$vpcs" ]; then
        RESOURCES_FOUND[vpcs]="$vpcs"
        echo "$vpcs" | while read line; do
            print_resource "VPC: $line"
        done
    fi
}

delete_vpcs() {
    if [ -z "${RESOURCES_FOUND[vpcs]}" ]; then
        return
    fi
    
    print_warning "Deleting VPCs and associated resources..."
    
    echo "${RESOURCES_FOUND[vpcs]}" | while read vpc_id cidr name; do
        if [ ! -z "$vpc_id" ] && [ "$vpc_id" != "None" ]; then
            print_info "Cleaning VPC: $vpc_id ($name)"
            
            # Delete NAT Gateways
            local nats=$(aws ec2 describe-nat-gateways --region $REGION \
                --filter "Name=vpc-id,Values=$vpc_id" "Name=state,Values=available" \
                --query 'NatGateways[*].NatGatewayId' --output text 2>/dev/null)
            for nat in $nats; do
                aws ec2 delete-nat-gateway --region $REGION --nat-gateway-id $nat >/dev/null 2>&1 || true
            done
            
            # Detach and delete Internet Gateways
            local igws=$(aws ec2 describe-internet-gateways --region $REGION \
                --filters "Name=attachment.vpc-id,Values=$vpc_id" \
                --query 'InternetGateways[*].InternetGatewayId' --output text 2>/dev/null)
            for igw in $igws; do
                aws ec2 detach-internet-gateway --region $REGION --internet-gateway-id $igw --vpc-id $vpc_id >/dev/null 2>&1 || true
                aws ec2 delete-internet-gateway --region $REGION --internet-gateway-id $igw >/dev/null 2>&1 || true
            done
            
            # Delete subnets
            local subnets=$(aws ec2 describe-subnets --region $REGION \
                --filters "Name=vpc-id,Values=$vpc_id" \
                --query 'Subnets[*].SubnetId' --output text 2>/dev/null)
            for subnet in $subnets; do
                aws ec2 delete-subnet --region $REGION --subnet-id $subnet >/dev/null 2>&1 || true
            done
            
            # Delete route tables
            local rts=$(aws ec2 describe-route-tables --region $REGION \
                --filters "Name=vpc-id,Values=$vpc_id" \
                --query 'RouteTables[?Associations[0].Main==`false`].RouteTableId' \
                --output text 2>/dev/null)
            for rt in $rts; do
                aws ec2 delete-route-table --region $REGION --route-table-id $rt >/dev/null 2>&1 || true
            done
            
            # Delete security groups
            local sgs=$(aws ec2 describe-security-groups --region $REGION \
                --filters "Name=vpc-id,Values=$vpc_id" \
                --query 'SecurityGroups[?GroupName!=`default`].GroupId' \
                --output text 2>/dev/null)
            for sg in $sgs; do
                aws ec2 delete-security-group --region $REGION --group-id $sg >/dev/null 2>&1 || true
            done
            
            sleep 3
            
            # Delete VPC
            aws ec2 delete-vpc --region $REGION --vpc-id $vpc_id >/dev/null 2>&1 || true
            print_success "VPC deleted: $vpc_id"
        fi
    done
}

################################################################################
# Transit Gateway Resources
################################################################################

scan_transit_gateways() {
    print_info "Scanning Transit Gateways..."
    
    local tgws=$(aws ec2 describe-transit-gateways \
        --region $REGION \
        --filters "Name=state,Values=available,pending" \
        --query 'TransitGateways[*].[TransitGatewayId,State,Tags[?Key==`Name`].Value|[0]]' \
        --output text 2>/dev/null)
    
    if [ ! -z "$tgws" ]; then
        RESOURCES_FOUND[transit_gateways]="$tgws"
        echo "$tgws" | while read line; do
            print_resource "Transit Gateway: $line (~\$36/month)"
        done
    fi
}

delete_transit_gateways() {
    if [ -z "${RESOURCES_FOUND[transit_gateways]}" ]; then
        return
    fi
    
    print_warning "Deleting Transit Gateways..."
    
    echo "${RESOURCES_FOUND[transit_gateways]}" | while read tgw_id state name; do
        if [ ! -z "$tgw_id" ]; then
            # Delete attachments first
            local attachments=$(aws ec2 describe-transit-gateway-attachments \
                --region $REGION \
                --filters "Name=transit-gateway-id,Values=$tgw_id" "Name=state,Values=available" \
                --query 'TransitGatewayAttachments[*].TransitGatewayAttachmentId' \
                --output text 2>/dev/null)
            
            for att in $attachments; do
                aws ec2 delete-transit-gateway-vpc-attachment --region $REGION \
                    --transit-gateway-attachment-id $att >/dev/null 2>&1 || true
            done
            
            sleep 30
            
            # Delete Transit Gateway
            aws ec2 delete-transit-gateway --region $REGION --transit-gateway-id $tgw_id >/dev/null 2>&1 || true
            print_success "Transit Gateway deleted: $tgw_id"
        fi
    done
}

################################################################################
# Load Balancer Resources
################################################################################

scan_load_balancers() {
    print_info "Scanning Load Balancers..."
    
    # ALB/NLB
    local lbs=$(aws elbv2 describe-load-balancers \
        --region $REGION \
        --query 'LoadBalancers[*].[LoadBalancerArn,LoadBalancerName,Type]' \
        --output text 2>/dev/null)
    
    if [ ! -z "$lbs" ]; then
        RESOURCES_FOUND[load_balancers]="$lbs"
        echo "$lbs" | while read arn name type; do
            print_resource "Load Balancer: $name ($type) (~\$16-22/month)"
        done
    fi
    
    # Classic LB
    local classic=$(aws elb describe-load-balancers \
        --region $REGION \
        --query 'LoadBalancerDescriptions[*].LoadBalancerName' \
        --output text 2>/dev/null)
    
    if [ ! -z "$classic" ]; then
        RESOURCES_FOUND[classic_load_balancers]="$classic"
        echo "$classic" | tr '\t' '\n' | while read name; do
            print_resource "Classic Load Balancer: $name"
        done
    fi
}

delete_load_balancers() {
    # Delete ALB/NLB
    if [ ! -z "${RESOURCES_FOUND[load_balancers]}" ]; then
        echo "${RESOURCES_FOUND[load_balancers]}" | while read arn name type; do
            if [ ! -z "$arn" ]; then
                print_info "Deleting Load Balancer: $name"
                aws elbv2 delete-load-balancer --region $REGION --load-balancer-arn $arn >/dev/null 2>&1 || true
            fi
        done
    fi
    
    # Delete Classic LB
    if [ ! -z "${RESOURCES_FOUND[classic_load_balancers]}" ]; then
        echo "${RESOURCES_FOUND[classic_load_balancers]}" | tr '\t' '\n' | while read name; do
            if [ ! -z "$name" ]; then
                print_info "Deleting Classic Load Balancer: $name"
                aws elb delete-load-balancer --region $REGION --load-balancer-name $name >/dev/null 2>&1 || true
            fi
        done
    fi
    
    print_success "Load Balancers deleted"
}

################################################################################
# RDS Resources
################################################################################

scan_rds_instances() {
    print_info "Scanning RDS Instances..."
    
    local rds=$(aws rds describe-db-instances \
        --region $REGION \
        --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceClass,DBInstanceStatus,Engine]' \
        --output text 2>/dev/null)
    
    if [ ! -z "$rds" ]; then
        RESOURCES_FOUND[rds_instances]="$rds"
        echo "$rds" | while read line; do
            print_resource "RDS Instance: $line"
        done
    fi
}

delete_rds_instances() {
    if [ -z "${RESOURCES_FOUND[rds_instances]}" ]; then
        return
    fi
    
    print_warning "Deleting RDS Instances..."
    
    echo "${RESOURCES_FOUND[rds_instances]}" | while read id class status engine; do
        if [ ! -z "$id" ]; then
            print_info "Deleting RDS: $id"
            aws rds delete-db-instance --region $REGION \
                --db-instance-identifier $id \
                --skip-final-snapshot \
                --delete-automated-backups >/dev/null 2>&1 || true
        fi
    done
    
    print_success "RDS instances deletion initiated"
}

################################################################################
# S3 Buckets
################################################################################

scan_s3_buckets() {
    print_info "Scanning S3 Buckets..."
    
    local buckets=$(aws s3api list-buckets \
        --query 'Buckets[*].Name' \
        --output text 2>/dev/null)
    
    if [ ! -z "$buckets" ]; then
        # Filter by region
        local regional_buckets=""
        for bucket in $buckets; do
            local location=$(aws s3api get-bucket-location --bucket $bucket --query 'LocationConstraint' --output text 2>/dev/null || echo "us-east-1")
            if [ "$location" == "None" ]; then
                location="us-east-1"
            fi
            if [ "$location" == "$REGION" ]; then
                regional_buckets="$regional_buckets $bucket"
            fi
        done
        
        if [ ! -z "$regional_buckets" ]; then
            RESOURCES_FOUND[s3_buckets]="$regional_buckets"
            echo "$regional_buckets" | tr ' ' '\n' | while read bucket; do
                if [ ! -z "$bucket" ]; then
                    print_resource "S3 Bucket: $bucket"
                fi
            done
        fi
    fi
}

delete_s3_buckets() {
    if [ -z "${RESOURCES_FOUND[s3_buckets]}" ]; then
        return
    fi
    
    print_warning "Deleting S3 Buckets..."
    
    echo "${RESOURCES_FOUND[s3_buckets]}" | tr ' ' '\n' | while read bucket; do
        if [ ! -z "$bucket" ]; then
            print_info "Emptying and deleting S3 bucket: $bucket"
            aws s3 rm s3://$bucket --recursive >/dev/null 2>&1 || true
            aws s3 rb s3://$bucket --force >/dev/null 2>&1 || true
        fi
    done
    
    print_success "S3 buckets deleted"
}

################################################################################
# Lambda Functions
################################################################################

scan_lambda_functions() {
    print_info "Scanning Lambda Functions..."
    
    local lambdas=$(aws lambda list-functions \
        --region $REGION \
        --query 'Functions[*].[FunctionName,Runtime,LastModified]' \
        --output text 2>/dev/null)
    
    if [ ! -z "$lambdas" ]; then
        RESOURCES_FOUND[lambda_functions]="$lambdas"
        echo "$lambdas" | while read line; do
            print_resource "Lambda Function: $line"
        done
    fi
}

delete_lambda_functions() {
    if [ -z "${RESOURCES_FOUND[lambda_functions]}" ]; then
        return
    fi
    
    print_warning "Deleting Lambda Functions..."
    
    echo "${RESOURCES_FOUND[lambda_functions]}" | while read name runtime modified; do
        if [ ! -z "$name" ]; then
            print_info "Deleting Lambda: $name"
            aws lambda delete-function --region $REGION --function-name $name >/dev/null 2>&1 || true
        fi
    done
    
    print_success "Lambda functions deleted"
}

################################################################################
# EBS Volumes
################################################################################

scan_ebs_volumes() {
    print_info "Scanning EBS Volumes..."
    
    local volumes=$(aws ec2 describe-volumes \
        --region $REGION \
        --filters "Name=status,Values=available" \
        --query 'Volumes[*].[VolumeId,Size,VolumeType,State]' \
        --output text 2>/dev/null)
    
    if [ ! -z "$volumes" ]; then
        RESOURCES_FOUND[ebs_volumes]="$volumes"
        echo "$volumes" | while read line; do
            print_resource "EBS Volume: $line"
        done
    fi
}

delete_ebs_volumes() {
    if [ -z "${RESOURCES_FOUND[ebs_volumes]}" ]; then
        return
    fi
    
    print_warning "Deleting EBS Volumes..."
    
    echo "${RESOURCES_FOUND[ebs_volumes]}" | while read vol_id size type state; do
        if [ ! -z "$vol_id" ]; then
            print_info "Deleting EBS Volume: $vol_id"
            aws ec2 delete-volume --region $REGION --volume-id $vol_id >/dev/null 2>&1 || true
        fi
    done
    
    print_success "EBS volumes deleted"
}

################################################################################
# Elastic IPs
################################################################################

scan_elastic_ips() {
    print_info "Scanning Elastic IPs..."
    
    local eips=$(aws ec2 describe-addresses \
        --region $REGION \
        --query 'Addresses[*].[PublicIp,AllocationId,AssociationId]' \
        --output text 2>/dev/null)
    
    if [ ! -z "$eips" ]; then
        RESOURCES_FOUND[elastic_ips]="$eips"
        echo "$eips" | while read line; do
            print_resource "Elastic IP: $line"
        done
    fi
}

delete_elastic_ips() {
    if [ -z "${RESOURCES_FOUND[elastic_ips]}" ]; then
        return
    fi
    
    print_warning "Releasing Elastic IPs..."
    
    echo "${RESOURCES_FOUND[elastic_ips]}" | while read ip alloc_id assoc_id; do
        if [ ! -z "$alloc_id" ]; then
            print_info "Releasing Elastic IP: $ip"
            aws ec2 release-address --region $REGION --allocation-id $alloc_id >/dev/null 2>&1 || true
        fi
    done
    
    print_success "Elastic IPs released"
}

################################################################################
# Display Summary
################################################################################

display_summary() {
    echo ""
    echo -e "${BLUE}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║                    SCAN COMPLETE                               ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    if [ $TOTAL_RESOURCES -eq 0 ]; then
        print_success "No resources found in region: $REGION"
        echo -e "\n${GREEN}${BOLD}✅ Your AWS account is clean! ✅${NC}\n"
    else
        print_warning "Found $TOTAL_RESOURCES resources in region: $REGION"
        echo ""
        print_info "Run with --delete flag to remove all resources"
        print_error "WARNING: Deletion is IRREVERSIBLE!"
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    echo -e "${BLUE}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║           AWS Resource Scanner & Cleanup Tool                  ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    print_info "Region: ${BOLD}$REGION${NC}"
    print_info "Mode: ${BOLD}$MODE${NC}"
    print_info "Scan started: $(date)"
    echo ""
    
    # Scan all resources
    print_header "Scanning AWS Resources"
    
    scan_ec2_instances
    scan_rds_instances
    scan_transit_gateways
    scan_load_balancers
    scan_vpcs
    scan_lambda_functions
    scan_s3_buckets
    scan_ebs_volumes
    scan_elastic_ips
    
    # Display summary
    display_summary
    
    # Delete if requested
    if [ "$MODE" == "--delete" ] || [ "$MODE" == "--interactive" ]; then
        echo ""
        
        if [ $TOTAL_RESOURCES -eq 0 ]; then
            print_info "No resources to delete"
            exit 0
        fi
        
        if [ "$MODE" == "--interactive" ]; then
            if ! confirm_action "Do you want to DELETE all these resources?"; then
                print_info "Deletion cancelled"
                exit 0
            fi
        fi
        
        print_header "DELETING RESOURCES"
        print_error "This action is IRREVERSIBLE!"
        
        if [ "$MODE" == "--delete" ]; then
            sleep 3
        fi
        
        delete_ec2_instances
        sleep 10
        delete_rds_instances
        delete_load_balancers
        delete_lambda_functions
        delete_transit_gateways
        sleep 30
        delete_vpcs
        delete_ebs_volumes
        delete_elastic_ips
        delete_s3_buckets
        
        echo ""
        print_success "Resource deletion completed!"
        print_info "Some resources may take 10-15 minutes to fully delete"
        print_info "Run scan again in 15 minutes to verify"
    fi
}

# Run main
main
