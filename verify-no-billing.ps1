# AWS Resource Verification Script - Check for Billable Resources (PowerShell)
# 
# This script checks your AWS account for any billable resources that might
# be incurring charges in the current region.
#
# USAGE: .\verify-no-billing.ps1

# Get current region
$REGION = (aws configure get region 2>$null)
if (-not $REGION) { $REGION = "us-east-1" }

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

function Print-Checking {
    param([string]$Message)
    Write-Host "🔍 Checking $Message..." -ForegroundColor Blue
}

# Resource Checking Functions
function Check-EC2Instances {
    Print-Checking "EC2 Instances"
    
    $instances = aws ec2 describe-instances `
        --region $REGION `
        --filters "Name=instance-state-name,Values=running,stopped,stopping,pending" `
        --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType]' `
        --output text 2>$null
    
    if (-not $instances) {
        Print-Success "No running or stopped EC2 instances"
        return $true
    } else {
        Print-Error "Found EC2 instances (BILLABLE):"
        $instances -split "`n" | ForEach-Object {
            Write-Host "   → $_" -ForegroundColor Red
        }
        return $false
    }
}

function Check-TransitGateways {
    Print-Checking "Transit Gateways"
    
    $tgws = aws ec2 describe-transit-gateways `
        --region $REGION `
        --filters "Name=state,Values=available,pending" `
        --query 'TransitGateways[*].[TransitGatewayId,State]' `
        --output text 2>$null
    
    if (-not $tgws) {
        Print-Success "No Transit Gateways"
        return $true
    } else {
        Print-Error "Found Transit Gateways (BILLABLE ~`$36/month each):"
        $tgws -split "`n" | ForEach-Object {
            Write-Host "   → $_" -ForegroundColor Red
        }
        return $false
    }
}

function Check-NATGateways {
    Print-Checking "NAT Gateways"
    
    $nats = aws ec2 describe-nat-gateways `
        --region $REGION `
        --filter "Name=state,Values=available,pending" `
        --query 'NatGateways[*].[NatGatewayId,State]' `
        --output text 2>$null
    
    if (-not $nats) {
        Print-Success "No NAT Gateways"
        return $true
    } else {
        Print-Error "Found NAT Gateways (BILLABLE ~`$32/month each):"
        $nats -split "`n" | ForEach-Object {
            Write-Host "   → $_" -ForegroundColor Red
        }
        return $false
    }
}

function Check-LoadBalancers {
    Print-Checking "Load Balancers"
    
    $lbs = aws elbv2 describe-load-balancers `
        --region $REGION `
        --query 'LoadBalancers[*].[LoadBalancerName,Type]' `
        --output text 2>$null
    
    if (-not $lbs) {
        Print-Success "No Load Balancers"
        return $true
    } else {
        Print-Error "Found Load Balancers (BILLABLE ~`$16-22/month each):"
        $lbs -split "`n" | ForEach-Object {
            Write-Host "   → $_" -ForegroundColor Red
        }
        return $false
    }
}

function Check-RDSInstances {
    Print-Checking "RDS Instances"
    
    $rds = aws rds describe-db-instances `
        --region $REGION `
        --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceClass]' `
        --output text 2>$null
    
    if (-not $rds) {
        Print-Success "No RDS instances"
        return $true
    } else {
        Print-Error "Found RDS instances (BILLABLE):"
        $rds -split "`n" | ForEach-Object {
            Write-Host "   → $_" -ForegroundColor Red
        }
        return $false
    }
}

function Display-FinalResults {
    param([bool]$HasBillable)
    
    Write-Host "`n"
    
    if (-not $HasBillable) {
        # No billable resources - SUCCESS
        Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║                                                                ║" -ForegroundColor Green
        Write-Host "║                    🎉 EXCELLENT NEWS! 🎉                       ║" -ForegroundColor Green
        Write-Host "║                                                                ║" -ForegroundColor Green
        Write-Host "║              NO BILLABLE RESOURCES DETECTED                    ║" -ForegroundColor Green
        Write-Host "║                                                                ║" -ForegroundColor Green
        Write-Host "╠════════════════════════════════════════════════════════════════╣" -ForegroundColor Green
        Write-Host "║                                                                ║" -ForegroundColor Green
        Write-Host "║  ✅ Your AWS account is clean in region: $REGION              " -ForegroundColor Green
        Write-Host "║  ✅ No resources are currently incurring charges               ║" -ForegroundColor Green
        Write-Host "║  ✅ Monthly cost: `$0.00                                        ║" -ForegroundColor Green
        Write-Host "║  ✅ You can safely close this verification                     ║" -ForegroundColor Green
        Write-Host "║                                                                ║" -ForegroundColor Green
        Write-Host "╠════════════════════════════════════════════════════════════════╣" -ForegroundColor Green
        Write-Host "║                                                                ║" -ForegroundColor Green
        Write-Host "║  📊 Recommendation:                                            ║" -ForegroundColor Green
        Write-Host "║     • Check your AWS Billing Dashboard in 24 hours            ║" -ForegroundColor Green
        Write-Host "║     • Verify charges are `$0.00 or minimal                     ║" -ForegroundColor Green
        Write-Host "║     • Set up billing alerts for future labs                   ║" -ForegroundColor Green
        Write-Host "║                                                                ║" -ForegroundColor Green
        Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
        
        Write-Host "`n🎊 Congratulations! Your cleanup was successful! 🎊`n" -ForegroundColor Green
        
    } else {
        # Found billable resources - WARNING
        Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "║                                                                ║" -ForegroundColor Red
        Write-Host "║                    ⚠️  WARNING! ⚠️                             ║" -ForegroundColor Red
        Write-Host "║                                                                ║" -ForegroundColor Red
        Write-Host "║              BILLABLE RESOURCES DETECTED                       ║" -ForegroundColor Red
        Write-Host "║                                                                ║" -ForegroundColor Red
        Write-Host "╠════════════════════════════════════════════════════════════════╣" -ForegroundColor Red
        Write-Host "║                                                                ║" -ForegroundColor Red
        Write-Host "║  ❌ Your AWS account has resources incurring charges           ║" -ForegroundColor Red
        Write-Host "║  ❌ Region: $REGION                                            " -ForegroundColor Red
        Write-Host "║  ❌ These resources are costing you money right now!           ║" -ForegroundColor Red
        Write-Host "║                                                                ║" -ForegroundColor Red
        Write-Host "╠════════════════════════════════════════════════════════════════╣" -ForegroundColor Red
        Write-Host "║                                                                ║" -ForegroundColor Red
        Write-Host "║  🔧 Action Required:                                           ║" -ForegroundColor Red
        Write-Host "║     1. Review the resources listed above                      ║" -ForegroundColor Red
        Write-Host "║     2. Delete unnecessary resources immediately               ║" -ForegroundColor Red
        Write-Host "║     3. Run cleanup script if lab resources remain             ║" -ForegroundColor Red
        Write-Host "║     4. Re-run this verification script after cleanup          ║" -ForegroundColor Red
        Write-Host "║                                                                ║" -ForegroundColor Red
        Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
        
        Write-Host "`n⚡ Take action now to avoid unnecessary charges! ⚡`n" -ForegroundColor Yellow
    }
}

# Main Execution
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║                                                                ║" -ForegroundColor Blue
Write-Host "║        AWS Billable Resources Verification Script              ║" -ForegroundColor Blue
Write-Host "║                                                                ║" -ForegroundColor Blue
Write-Host "║     Checking for resources that may incur charges              ║" -ForegroundColor Blue
Write-Host "║                                                                ║" -ForegroundColor Blue
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Blue

Print-Info "Current AWS Region: $REGION"
Print-Info "Scan started at: $(Get-Date)"
Write-Host ""

# Track if any billable resources found
$hasBillable = $false

# Run all checks
Print-Header "Checking High-Cost Resources"
if (-not (Check-EC2Instances)) { $hasBillable = $true }
if (-not (Check-TransitGateways)) { $hasBillable = $true }
if (-not (Check-NATGateways)) { $hasBillable = $true }
if (-not (Check-LoadBalancers)) { $hasBillable = $true }
if (-not (Check-RDSInstances)) { $hasBillable = $true }

# Display final results
Display-FinalResults -HasBillable $hasBillable

# Exit with appropriate code
if (-not $hasBillable) {
    exit 0
} else {
    exit 1
}
