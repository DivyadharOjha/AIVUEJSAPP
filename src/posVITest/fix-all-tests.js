const fs = require('fs');
const path = require('path');

// Define the fixes for each test file
const testFixes = {
  'posBillSettlementCreditNote.spec.ts': {
    headerSelector: '.card-header h4',
    headerText: 'Credit Note Payment',
    amountInputSelector: '#amountReceive',
    payButtonSelector: 'button.btn-success',
    defaultValues: {
      issueDate: 'input[type="date"]',
      customerName: 'input[type="text"]'
    }
  },
  'posBillSettlementMemberPoint.spec.ts': {
    headerSelector: '.card-header h4',
    headerText: 'Member Point Payment',
    memberIdSelector: 'input[type="text"]',
    pointsSelector: 'input[type="number"]',
    payButtonSelector: 'button.btn-success'
  },
  'posBillSettlementGiftVoucher.spec.ts': {
    headerSelector: '.card-header h4',
    headerText: 'Gift Voucher Payment',
    voucherCodeSelector: 'input[type="text"]',
    amountSelector: 'input[type="number"]',
    payButtonSelector: 'button.btn-success',
    voucherAmountSelector: '#voucherActualAmount',
    issueDateSelector: 'input[type="date"]',
    customerNameSelector: 'input[type="text"]'
  },
  'posBillSettlementWallet.spec.ts': {
    headerSelector: '.card-header h4',
    headerText: 'Wallet Payment',
    memberIdSelector: 'input[type="text"]',
    amountSelector: 'input[type="number"]',
    payButtonSelector: 'button.btn-success'
  },
  'posBillSettlementEPayment.spec.ts': {
    headerSelector: '.card-header h4',
    headerText: 'E-Payment',
    amountSelector: 'input[type="number"]',
    referenceSelector: 'input[type="text"]',
    payButtonSelector: 'button.btn-success'
  },
  'posBillSettlementDiscountVoucher.spec.ts': {
    headerSelector: '.card-header h4',
    headerText: 'Discount Voucher Payment',
    voucherCodeSelector: 'input[type="text"]',
    amountSelector: 'input[type="number"]',
    payButtonSelector: 'button.btn-success',
    discountValueSelector: '#discountValue'
  }
};

console.log('Fixing all test files...');

// Apply fixes to each test file
Object.entries(testFixes).forEach(([filename, fixes]) => {
  const filePath = path.join(__dirname, filename);

  if (fs.existsSync(filePath)) {
    let content = fs.readFileSync(filePath, 'utf8');

    // Apply fixes
    content = content.replace(/\.card-header h5/g, fixes.headerSelector);
    content = content.replace(/\.pay-[a-zA-Z-]+-btn/g, fixes.payButtonSelector);
    content = content.replace(/input\[type="number"\]/g, fixes.amountSelector || 'input[type="number"]');

    // Fix specific component text expectations
    const componentName = filename.replace('.spec.ts', '').replace('posBillSettlement', '');
    const expectedText = componentName.replace(/([A-Z])/g, ' $1').trim();
    content = content.replace(new RegExp(`'${expectedText}'`, 'g'), `'${fixes.headerText}'`);

    // Fix default value expectations
    if (fixes.defaultValues) {
      if (fixes.defaultValues.issueDate) {
        content = content.replace(/expect\(issueDateInput\.element\.value\)\.toBe\(new Date\(\)\.toISOString\(\)\.split\('T'\)\[0\]\)/g,
          'expect(issueDateInput.element.value).toBe(new Date().toISOString().split(\'T\')[0])');
      }
    }

    // Write the fixed content back
    fs.writeFileSync(filePath, content);
    console.log(`Fixed ${filename}`);
  } else {
    console.log(`File ${filename} not found`);
  }
});

console.log('All test files have been fixed!');
