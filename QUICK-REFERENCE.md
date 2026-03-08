# AWS Transit Gateway Lab - Quick Reference Card

## 🚀 Quick Commands

### Run Cleanup Script
```bash
curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/cleanup-script.sh
chmod +x cleanup-script.sh
./cleanup-script.sh
```

### Verify No Billing
```bash
curl -O https://raw.githubusercontent.com/SrinathMLOps/TransitGateway/main/verify-no-billing.sh
chmod +x verify-no-billing.sh
./verify-no-billing.sh
```

---

## 📖 Documentation Links

| Document | Purpose | Time |
|----------|---------|------|
| [LAB-STEPS-VISUAL-GUIDE.md](./LAB-STEPS-VISUAL-GUIDE.md) | Complete lab setup | 45-60 min |
| [HOW-TO-RUN-CLEANUP.md](./HOW-TO-RUN-CLEANUP.md) | Execute cleanup | 15-20 min |
| [HOW-TO-VERIFY-NO-BILLING.md](./HOW-TO-VERIFY-NO-BILLING.md) | Verify no charges | 2-3 min |
| [AWS-Transit-Gateway-Architecture.md](./AWS-Transit-Gateway-Architecture.md) | Architecture details | Reference |
| [Transit-Gateway-Lab-Summary.md](./Transit-Gateway-Lab-Summary.md) | Executive summary | 5 min read |

---

## ✅ Success Messages

### Cleanup Complete
```
✅ CLEANUP COMPLETED SUCCESSFULLY!
✅ Expected cost: ~$0.05-$0.07 (for lab duration)
✅ Ongoing monthly cost: $0.00
```

### No Billing Detected
```
╔════════════════════════════════════════════════════════════════╗
║              NO BILLABLE RESOURCES DETECTED                    ║
║  ✅ Monthly cost: $0.00                                        ║
╚════════════════════════════════════════════════════════════════╝
```

---

## 💰 Cost Summary

| Resource | Monthly Cost | Lab Cost (1hr) |
|----------|--------------|----------------|
| Transit Gateway | ~$36 | ~$0.05 |
| EC2 t2.micro (2x) | ~$17 | ~$0.02 |
| **Total if not cleaned** | **~$58** | **~$0.07** |
| **After cleanup** | **$0.00** | **$0.07** ✅ |

---

## 🔄 Complete Workflow

```
1. Complete Lab
   ↓
2. Run Cleanup Script (15-20 min)
   ↓
3. Verify No Billing (2-3 min)
   ↓
4. Check Billing Dashboard (24 hours later)
   ↓
5. Confirm $0.00 charges ✅
```

---

## 🐛 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Permission denied | `chmod +x script.sh` |
| Command not found: aws | Use AWS CloudShell |
| Unable to locate credentials | `aws configure` |
| Resources still exist | Wait 5 min, run again |

---

## 📞 Support

- **GitHub**: https://github.com/SrinathMLOps/TransitGateway
- **AWS Support**: Open support ticket
- **Billing**: https://console.aws.amazon.com/billing/

---

*Quick Reference Version: 1.0*
