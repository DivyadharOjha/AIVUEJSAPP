import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import posBillSettlementGiftVoucher from '../components/posTemplate/posBillSettlementGiftVoucher.vue'
import { usePaymentStore } from '../stores/paymentStore'

describe('posBillSettlementGiftVoucher', () => {
  let pinia: ReturnType<typeof createPinia>
  let store: ReturnType<typeof usePaymentStore>

  beforeEach(() => {
    pinia = createPinia()
    setActivePinia(pinia)
    store = usePaymentStore()
    store.setOriginalAmountDue(125.5)
  })

  it('renders initial UI correctly', () => {
    const wrapper = mount(posBillSettlementGiftVoucher)

    expect(wrapper.find('.card-header h4').text()).toBe('Gift Voucher Payment')
    expect((wrapper.find('#amount').element as HTMLInputElement).value).toBe('125.5')
  })

  it('enables pay button when voucher code and amount are entered', async () => {
    const wrapper = mount(posBillSettlementGiftVoucher)

    const voucherCodeInput = wrapper.find('#voucherCode')
    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Initially button should be disabled
    expect(payButton.attributes('disabled')).toBeDefined()

    // Enter voucher code
    await voucherCodeInput.setValue('GV001')

    // Enter amount
    await amountInput.setValue(50)

    // Button should be enabled
    expect(payButton.attributes('disabled')).toBeUndefined()
  })

  it('disables pay button when no voucher code is entered', async () => {
    const wrapper = mount(posBillSettlementGiftVoucher)

    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Enter amount without voucher code
    await amountInput.setValue(50)

    // Button should still be disabled
    expect(payButton.attributes('disabled')).toBeDefined()
  })

  it('disables pay button when amount is zero', async () => {
    const wrapper = mount(posBillSettlementGiftVoucher)

    const voucherCodeInput = wrapper.find('#voucherCode')
    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Enter voucher code
    await voucherCodeInput.setValue('GV001')

    // Enter zero amount
    await amountInput.setValue(0)

    // Button should be disabled
    expect(payButton.attributes('disabled')).toBeDefined()
  })

  it('emits payment record when pay button is clicked', async () => {
    const wrapper = mount(posBillSettlementGiftVoucher)

    const voucherCodeInput = wrapper.find('#voucherCode')
    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Enter voucher code and amount
    await voucherCodeInput.setValue('GV001')
    await amountInput.setValue(50)

    // Click pay button
    await payButton.trigger('click')

    // Check if event was emitted
    expect(wrapper.emitted('payment-record-added')).toBeTruthy()
    const emittedRecord = wrapper.emitted('payment-record-added')?.[0]?.[0]
    expect(emittedRecord).toMatchObject({
      id: expect.any(String),
      type: 'giftVoucher',
      amount: 50,
      notes: '',
      timestamp: expect.any(String),
    })
  })

  it('shows table when payment records exist', async () => {
    const wrapper = mount(posBillSettlementGiftVoucher)

    // Initially table should not be visible
    expect(wrapper.find('table').exists()).toBe(false)

    // Add a payment record to store
    store.componentRecords.giftVoucher.push({
      id: 'test-1',
      type: 'giftVoucher',
      voucherCode: 'GV001',
      voucherActualAmount: 100,
      amountReceive: 50,
      remainingBalance: 50,
      issueDate: '2024-01-01',
      expiryDate: '2024-12-31',
      notes: 'Test gift voucher',
      timestamp: new Date().toISOString(),
      customerName: 'Ojha',
    })

    // Force component to re-render
    await wrapper.vm.$nextTick()

    // Table should be visible
    expect(wrapper.find('table').exists()).toBe(true)
  })

  it('calculates remaining balance correctly', async () => {
    const wrapper = mount(posBillSettlementGiftVoucher)

    const amountInput = wrapper.find('#amountReceive')

    // Enter amount
    await amountInput.setValue(30)

    // Check if remaining balance is calculated correctly
    const remainingBalanceElement = wrapper.find('#remainingBalance')
    expect((remainingBalanceElement.element as HTMLInputElement).value).toBe('70')
  })

  it('clears form after successful payment', async () => {
    const wrapper = mount(posBillSettlementGiftVoucher)

    const voucherCodeInput = wrapper.find('#voucherCode')
    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Enter voucher code, amount and pay
    await voucherCodeInput.setValue('GV001')
    await amountInput.setValue(50)
    await payButton.trigger('click')

    // Form should be cleared
    expect((amountInput.element as HTMLInputElement).value).toBe('0')
  })

  it('loads default values on mount', () => {
    const wrapper = mount(posBillSettlementGiftVoucher)

    // Check if default values are set
    const voucherAmountInput = wrapper.find('#voucherActualAmount')
    const issueDateInput = wrapper.find('#issueDate')
    const customerNameInput = wrapper.find('#customerName')

    expect((voucherAmountInput.element as HTMLInputElement).value).toBe('100')
    expect((issueDateInput.element as HTMLInputElement).value).toBe(
      new Date().toISOString().split('T')[0],
    )
    expect((customerNameInput.element as HTMLInputElement).value).toBe('Ojha')
  })

  it('loads voucher data when voucher code is entered', async () => {
    const wrapper = mount(posBillSettlementGiftVoucher)

    const voucherCodeInput = wrapper.find('#voucherCode')

    // Enter voucher code
    await voucherCodeInput.setValue('GV001')

    // Trigger blur event to load voucher data
    await voucherCodeInput.trigger('blur')

    // Check if voucher data is loaded
    const voucherAmountInput = wrapper.find('#voucherActualAmount')
    expect((voucherAmountInput.element as HTMLInputElement).value).toBe('100')
  })
})
