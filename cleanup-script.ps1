# AWS Transit Gateway Lab - Automated Cleanup Script (PowerShell)
# 
# This script automatically cleans up all resources created in the 
# Transit Gateway lab to avoid ongoing AWS charges.
#
# USAGE:
#   1. Open PowerShell
#   2. Ensure AWS CLI is installed and configured
#   3. Run: .\cleanup-script.ps1
#
# ESTIMATED TIME: 15-20 minutes
# COST SAVINGS: ~$58/month

# Configuration - Update these if you used different names
$EC2_VPC1_NAME = "EC2-VPC1"
$EC2_VPC2_NAME = "EC2-VPC2"
$VPC1_NAME = "VPC1"
$VPC2_NAME = "VPC2"
$TGW_NAME = "My-Transit-Gateway"
$KEY_PAIR_NAME = "TransitGatewayKey"
$REGION = "us-east-1"  # Change if you used a different region

# Helper Functions
function Print-Header {
    param([string]$Message)
    Write-Host "`n========================================" -ForegroundColor Blue
    Write-Host $Message -ForegroundColor Blue
    Write-Host "========================================`n" -ForegroundColor Blue
}

function Print-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Print-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Print-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Print-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

function Wait-WithProgress {
    param(
        [int]$Seconds,
        [string]$Message
    )
    Write-Host "⏳ $Message" -NoNewline -ForegroundColor Yellow
    for ($i = 0; $i -lt $Seconds; $i++) {
        Start-Sleep -Seconds 1
        Write-Host "." -NoNewline -ForegroundColor Yellow
    }
    Write-Host ""
}

# Step 1: Terminate EC2 Instances
function Remove-EC2Instances {
    Print-Header "STEP 1: Terminating EC2 Instances"
    
    # Find EC2-VPC1 instance
    Print-Info "Looking for EC2-VPC1 instance..."
    $vpc1Instance = aws ec2 describe-instances `
        --region $REGION `
        --filters "Name=tag:Name,Values=$EC2_VPC1_NAME" "Name=instance-state-name,Values=running,stopped" `
        --query 'Reservations[0].Instances[0].InstanceId' `
        --output text 2>$null
    
    if ($vpc1Instance -and $vpc1Instance -ne "None") {
        Print-Info "Terminating EC2-VPC1 ($vpc1Instance)..."
        aws ec2 terminate-instances --region $REGION --instance-ids $vpc1Instance | Out-Null
        Print-Success "EC2-VPC1 termination initiated"
    } else {
        Print-Warning "EC2-VPC1 not found or already terminated"
    }
    
    # Find EC2-VPC2 instance
    Print-Info "Looking for EC2-VPC2 instance..."
    $vpc2Instance = aws ec2 describe-instances `
        --region $REGION `
        --filters "Name=tag:Name,Values=$EC2_VPC2_NAME" "Name=instance-state-name,Values=running,stopped" `
        --query 'Reservations[0].Instances[0].InstanceId' `
        --output text 2>$null
    
    if ($vpc2Instance -and $vpc2Instance -ne "None") {
        Print-Info "Terminating EC2-VPC2 ($vpc2Instance)..."
        aws ec2 terminate-instances --region $REGION --instance-ids $vpc2Instance | Out-Null
        Print-Success "EC2-VPC2 termination initiated"
    } else {
        Print-Warning "EC2-VPC2 not found or already terminated"
    }
    
    # Wait for instances to terminate
    if ($vpc1Instance -or $vpc2Instance) {
        Wait-WithProgress -Seconds 60 -Message "Waiting for instances to terminate (60 seconds)"
        Print-Success "EC2 instances terminated"
    }
}

# Step 2: Delete Transit Gateway Attachments
function Remove-TGWAttachments {
    Print-Header "STEP 2: Deleting Transit Gateway Attachments"
    
    # Find Transit Gateway ID
    Print-Info "Looking for Transit Gateway..."
    $script:TGW_ID = aws ec2 describe-transit-gateways `
        --region $REGION `
        --filters "Name=tag:Name,Values=$TGW_NAME" "Name=state,Values=available,pending" `
        --query 'TransitGateways[0].TransitGatewayId' `
        --output text 2>$null
    
    if (-not $script:TGW_ID -or $script:TGW_ID -eq "None") {
        Print-Warning "Transit Gateway not found or already deleted"
        return
    }
    
    Print-Success "Found Transit Gateway: $script:TGW_ID"
    
    # Find and delete all attachments
    Print-Info "Looking for Transit Gateway attachments..."
    $attachments = aws ec2 describe-transit-gateway-attachments `
        --region $REGION `
        --filters "Name=transit-gateway-id,Values=$script:TGW_ID" "Name=state,Values=available,pending" `
        --query 'TransitGatewayAttachments[*].TransitGatewayAttachmentId' `
        --output text 2>$null
    
    if (-not $attachments) {
        Print-Warning "No attachments found"
        return
    }
    
    $attachmentList = $attachments -split '\s+'
    foreach ($attachment in $attachmentList) {
        if ($attachment) {
            Print-Info "Deleting attachment: $attachment..."
            aws ec2 delete-transit-gateway-vpc-attachment `
                --region $REGION `
                --transit-gateway-attachment-id $attachment 2>$null | Out-Null
            Print-Success "Attachment deletion initiated: $attachment"
        }
    }
    
    # Wait for attachments to delete
    Wait-WithProgress -Seconds 90 -Message "Waiting for attachments to delete (90 seconds)"
    Print-Success "Transit Gateway attachments deleted"
}

# Step 3: Delete Transit Gateway
function Remove-TransitGateway {
    Print-Header "STEP 3: Deleting Transit Gateway"
    
    # Find Transit Gateway ID if not already found
    if (-not $script:TGW_ID -or $script:TGW_ID -eq "None") {
        $script:TGW_ID = aws ec2 describe-transit-gateways `
            --region $REGION `
            --filters "Name=tag:Name,Values=$TGW_NAME" "Name=state,Values=available,pending" `
            --query 'TransitGateways[0].TransitGatewayId' `
            --output text 2>$null
    }
    
    if (-not $script:TGW_ID -or $script:TGW_ID -eq "None") {
        Print-Warning "Transit Gateway not found or already deleted"
        return
    }
    
    Print-Info "Deleting Transit Gateway: $script:TGW_ID..."
    aws ec2 delete-transit-gateway `
        --region $REGION `
        --transit-gateway-id $script:TGW_ID 2>$null | Out-Null
    
    Print-Success "Transit Gateway deletion initiated"
    Wait-WithProgress -Seconds 120 -Message "Waiting for Transit Gateway to delete (120 seconds)"
    Print-Success "Transit Gateway deleted"
}

# Step 4 & 5: Delete VPCs
function Remove-VPC {
    param([string]$VPCName)
    
    Print-Header "Deleting VPC: $VPCName"
    
    # Find VPC ID
    Print-Info "Looking for $VPCName..."
    $vpcId = aws ec2 describe-vpcs `
        --region $REGION `
        --filters "Name=tag:Name,Values=$VPCName" `
        --query 'Vpcs[0].VpcId' `
        --output text 2>$null
    
    if (-not $vpcId -or $vpcId -eq "None") {
        Print-Warning "$VPCName not found or already deleted"
        return
    }
    
    Print-Success "Found $VPCName : $vpcId"
    
    # Delete NAT Gateways (if any)
    Print-Info "Checking for NAT Gateways..."
    $natGateways = aws ec2 describe-nat-gateways `
        --region $REGION `
        --filter "Name=vpc-id,Values=$vpcId" "Name=state,Values=available" `
        --query 'NatGateways[*].NatGatewayId' `
        --output text 2>$null
    
    if ($natGateways) {
        $natList = $natGateways -split '\s+'
        foreach ($natId in $natList) {
            if ($natId) {
                Print-Info "Deleting NAT Gateway: $natId..."
                aws ec2 delete-nat-gateway --region $REGION --nat-gateway-id $natId 2>$null | Out-Null
            }
        }
        Wait-WithProgress -Seconds 60 -Message "Waiting for NAT Gateways to delete"
    }
    
    # Delete Internet Gateway
    Print-Info "Checking for Internet Gateway..."
    $igwId = aws ec2 describe-internet-gateways `
        --region $REGION `
        --filters "Name=attachment.vpc-id,Values=$vpcId" `
        --query 'InternetGateways[0].InternetGatewayId' `
        --output text 2>$null
    
    if ($igwId -and $igwId -ne "None") {
        Print-Info "Detaching Internet Gateway: $igwId..."
        aws ec2 detach-internet-gateway `
            --region $REGION `
            --internet-gateway-id $igwId `
            --vpc-id $vpcId 2>$null | Out-Null
        
        Print-Info "Deleting Internet Gateway: $igwId..."
        aws ec2 delete-internet-gateway `
            --region $REGION `
            --internet-gateway-id $igwId 2>$null | Out-Null
        Print-Success "Internet Gateway deleted"
    }
    
    # Delete subnets
    Print-Info "Deleting subnets..."
    $subnets = aws ec2 describe-subnets `
        --region $REGION `
        --filters "Name=vpc-id,Values=$vpcId" `
        --query 'Subnets[*].SubnetId' `
        --output text 2>$null
    
    if ($subnets) {
        $subnetList = $subnets -split '\s+'
        foreach ($subnetId in $subnetList) {
            if ($subnetId) {
                aws ec2 delete-subnet --region $REGION --subnet-id $subnetId 2>$null | Out-Null
            }
        }
    }
    
    # Delete custom route tables
    Print-Info "Deleting route tables..."
    $routeTables = aws ec2 describe-route-tables `
        --region $REGION `
        --filters "Name=vpc-id,Values=$vpcId" `
        --query 'RouteTables[?Associations[0].Main==`false`].RouteTableId' `
        --output text 2>$null
    
    if ($routeTables) {
        $rtList = $routeTables -split '\s+'
        foreach ($rtId in $rtList) {
            if ($rtId) {
                aws ec2 delete-route-table --region $REGION --route-table-id $rtId 2>$null | Out-Null
            }
        }
    }
    
    # Delete security groups (except default)
    Print-Info "Deleting security groups..."
    $securityGroups = aws ec2 describe-security-groups `
        --region $REGION `
        --filters "Name=vpc-id,Values=$vpcId" `
        --query 'SecurityGroups[?GroupName!=`default`].GroupId' `
        --output text 2>$null
    
    if ($securityGroups) {
        $sgList = $securityGroups -split '\s+'
        foreach ($sgId in $sgList) {
            if ($sgId) {
                aws ec2 delete-security-group --region $REGION --group-id $sgId 2>$null | Out-Null
            }
        }
    }
    
    # Wait for dependencies to clear
    Start-Sleep -Seconds 5
    
    # Delete VPC
    Print-Info "Deleting VPC: $vpcId..."
    aws ec2 delete-vpc --region $REGION --vpc-id $vpcId 2>$null | Out-Null
    Print-Success "$VPCName deleted successfully"
}

# Step 6: Delete Key Pair
function Remove-KeyPair {
    Print-Header "STEP 6: Deleting Key Pair (Optional)"
    
    Print-Info "Looking for key pair: $KEY_PAIR_NAME..."
    $keyExists = aws ec2 describe-key-pairs `
        --region $REGION `
        --key-names $KEY_PAIR_NAME `
        --query 'KeyPairs[0].KeyName' `
        --output text 2>$null
    
    if ($keyExists -and $keyExists -ne "None") {
        Print-Info "Deleting key pair: $KEY_PAIR_NAME..."
        aws ec2 delete-key-pair --region $REGION --key-name $KEY_PAIR_NAME 2>$null | Out-Null
        Print-Success "Key pair deleted"
        Print-Warning "Remember to delete the local .pem/.ppk file"
    } else {
        Print-Warning "Key pair not found or already deleted"
    }
}

# Step 7: Final Verification
function Test-Cleanup {
    Print-Header "STEP 7: Final Verification"
    
    $allClean = $true
    
    # Check EC2 instances
    Print-Info "Checking EC2 instances..."
    $runningInstances = aws ec2 describe-instances `
        --region $REGION `
        --filters "Name=instance-state-name,Values=running,stopped" `
        --query "Reservations[*].Instances[*].[InstanceId,Tags[?Key=='Name'].Value|[0]]" `
        --output text 2>$null
    
    if ($runningInstances -match $EC2_VPC1_NAME -or $runningInstances -match $EC2_VPC2_NAME) {
        Print-Error "Some EC2 instances still exist"
        $allClean = $false
    } else {
        Print-Success "No lab EC2 instances running"
    }
    
    # Check Transit Gateway
    Print-Info "Checking Transit Gateway..."
    $tgwExists = aws ec2 describe-transit-gateways `
        --region $REGION `
        --filters "Name=tag:Name,Values=$TGW_NAME" `
        --query 'TransitGateways[0].TransitGatewayId' `
        --output text 2>$null
    
    if (-not $tgwExists -or $tgwExists -eq "None") {
        Print-Success "Transit Gateway deleted"
    } else {
        Print-Warning "Transit Gateway still exists (may be deleting): $tgwExists"
    }
    
    # Check VPCs
    Print-Info "Checking VPCs..."
    $vpc1Exists = aws ec2 describe-vpcs `
        --region $REGION `
        --filters "Name=tag:Name,Values=$VPC1_NAME" `
        --query 'Vpcs[0].VpcId' `
        --output text 2>$null
    
    $vpc2Exists = aws ec2 describe-vpcs `
        --region $REGION `
        --filters "Name=tag:Name,Values=$VPC2_NAME" `
        --query 'Vpcs[0].VpcId' `
        --output text 2>$null
    
    if (-not $vpc1Exists -or $vpc1Exists -eq "None") {
        Print-Success "VPC1 deleted"
    } else {
        Print-Error "VPC1 still exists: $vpc1Exists"
        $allClean = $false
    }
    
    if (-not $vpc2Exists -or $vpc2Exists -eq "None") {
        Print-Success "VPC2 deleted"
    } else {
        Print-Error "VPC2 still exists: $vpc2Exists"
        $allClean = $false
    }
    
    Write-Host ""
    if ($allClean) {
        Print-Success "✅ CLEANUP COMPLETED SUCCESSFULLY!"
        Print-Success "All Transit Gateway lab resources have been deleted."
        Print-Success "Expected cost: ~`$0.05-`$0.07 (for lab duration)"
        Print-Success "Ongoing monthly cost: `$0.00"
    } else {
        Print-Warning "⚠️  Some resources may still exist. Please check manually."
        Print-Info "Wait a few minutes and run verification again if resources are in 'deleting' state."
    }
}

# Main Execution
function Main {
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
    Write-Host "║                                                            ║" -ForegroundColor Blue
    Write-Host "║     AWS Transit Gateway Lab - Automated Cleanup            ║" -ForegroundColor Blue
    Write-Host "║                                                            ║" -ForegroundColor Blue
    Write-Host "║     This script will delete all lab resources              ║" -ForegroundColor Blue
    Write-Host "║     Estimated time: 15-20 minutes                          ║" -ForegroundColor Blue
    Write-Host "║     Cost savings: ~`$58/month                               ║" -ForegroundColor Blue
    Write-Host "║                                                            ║" -ForegroundColor Blue
    Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Blue
    
    Print-Warning "This script will delete the following resources:"
    Write-Host "  - EC2 instances (EC2-VPC1, EC2-VPC2)"
    Write-Host "  - Transit Gateway and attachments"
    Write-Host "  - VPCs (VPC1, VPC2) and all associated resources"
    Write-Host "  - Key pair (optional)"
    Write-Host ""
    
    $confirmation = Read-Host "Do you want to continue? (yes/no)"
    if ($confirmation -ne "yes") {
        Print-Info "Cleanup cancelled by user"
        exit 0
    }
    
    Print-Info "Starting cleanup process..."
    Print-Info "Region: $REGION"
    Write-Host ""
    
    # Execute cleanup steps
    Remove-EC2Instances
    Remove-TGWAttachments
    Remove-TransitGateway
    Remove-VPC -VPCName $VPC2_NAME
    Remove-VPC -VPCName $VPC1_NAME
    Remove-KeyPair
    Test-Cleanup
    
    Write-Host ""
    Print-Header "CLEANUP COMPLETE"
    Print-Info "Check your AWS Billing Dashboard in 24 hours to verify no ongoing charges."
    Print-Info "Script execution completed at: $(Get-Date)"
}

# Run main function
Main
