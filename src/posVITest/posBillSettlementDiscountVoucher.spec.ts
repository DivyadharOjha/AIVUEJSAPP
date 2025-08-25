import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import posBillSettlementDiscountVoucher from '../components/posTemplate/posBillSettlementDiscountVoucher.vue'
import { usePaymentStore } from '../stores/paymentStore'

describe('posBillSettlementDiscountVoucher', () => {
  let pinia: ReturnType<typeof createPinia>
  let store: ReturnType<typeof usePaymentStore>

  beforeEach(() => {
    pinia = createPinia()
    setActivePinia(pinia)
    store = usePaymentStore()
    store.setOriginalAmountDue(125.5)
  })

  it('renders initial UI correctly', () => {
    const wrapper = mount(posBillSettlementDiscountVoucher)

    expect(wrapper.find('.card-header h4').text()).toBe('Discount Voucher Payment')
    expect((wrapper.find('#amount').element as HTMLInputElement).value).toBe('125.5')
    expect((wrapper.find('#voucherCode').element as HTMLInputElement).value).toBe('')
    expect((wrapper.find('#discountValue').element as HTMLInputElement).value).toBe('0')
  })

  it('enables pay button when voucher code and amount are entered', async () => {
    const wrapper = mount(posBillSettlementDiscountVoucher)

    const voucherCodeInput = wrapper.find('#voucherCode')
    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Initially button should be disabled
    expect(payButton.attributes('disabled')).toBeDefined()

    // Enter voucher code and wait for voucher data to load (simulate user input and reactivity)
    await voucherCodeInput.setValue('SAVE20')
    await wrapper.vm.$nextTick()

    // Enter amount
    await amountInput.setValue(50)

    // Button should be enabled (component requires voucher code, discount value > 0, and amount > 0)
    expect(payButton.attributes('disabled')).toBeUndefined()
  })

  it('disables pay button when no voucher code is entered', async () => {
    const wrapper = mount(posBillSettlementDiscountVoucher)

    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Enter amount without voucher code
    await amountInput.setValue(50)

    // Button should still be disabled
    expect(payButton.attributes('disabled')).toBeDefined()
  })

  it('disables pay button when amount is zero', async () => {
    const wrapper = mount(posBillSettlementDiscountVoucher)

    const voucherCodeInput = wrapper.find('#voucherCode')
    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Enter voucher code but zero amount
    await voucherCodeInput.setValue('SAVE20')
    await wrapper.vm.$nextTick()
    await amountInput.setValue(0)

    // Button should be disabled
    expect(payButton.attributes('disabled')).toBeDefined()
  })

  it('emits payment record when pay button is clicked', async () => {
    const wrapper = mount(posBillSettlementDiscountVoucher)

    const voucherCodeInput = wrapper.find('#voucherCode')
    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Enter voucher code and wait for voucher data to load
    await voucherCodeInput.setValue('SAVE20')
    await wrapper.vm.$nextTick()
    await amountInput.setValue(50)
    await payButton.trigger('click')

    // Check if event was emitted
    expect(wrapper.emitted('payment-record-added')).toBeTruthy()
    const emittedRecord = wrapper.emitted('payment-record-added')?.[0]?.[0]
    expect(emittedRecord).toMatchObject({
      id: expect.any(String),
      type: 'discountVoucher',
      amount: 50,
      notes: '',
      timestamp: expect.any(String),
      discountVoucherNumber: 'SAVE20',
      discountVoucherValue: 20,
      amountReceive: 50,
      validTill: '2024-12-31',
    })
  })

  it('shows table when payment records exist', async () => {
    const wrapper = mount(posBillSettlementDiscountVoucher)

    // Initially table should not be visible
    expect(wrapper.find('table').exists()).toBe(false)

    // Add a payment record to store
    store.componentRecords.discountVoucher.push({
      id: 'test-1',
      type: 'discountVoucher',
      discountVoucherNumber: 'SAVE20',
      discountVoucherValue: 20,
      amountReceive: 50,
      validTill: '2024-12-31',
      notes: 'Test payment',
      timestamp: new Date().toISOString(),
    })

    // Force component to re-render
    await wrapper.vm.$nextTick()

    // Table should be visible
    expect(wrapper.find('table').exists()).toBe(true)
  })

  it('loads voucher data when voucher code is entered', async () => {
    const wrapper = mount(posBillSettlementDiscountVoucher)

    const voucherCodeInput = wrapper.find('#voucherCode')

    // Enter known voucher code
    await voucherCodeInput.setValue('SAVE20')

    // Simulate user action to trigger voucher data loading if needed
    // If the component loads voucher data on input, just wait for DOM update
    await wrapper.vm.$nextTick()

    // Check if voucher data is loaded
    const discountValueInput = wrapper.find('#discountValue')
    const validUntilInput = wrapper.find('#validUntil')
    expect((discountValueInput.element as HTMLInputElement).value).toBe('20')
    expect((validUntilInput.element as HTMLInputElement).value).toBe('2024-12-31')
  })

  it('clears form after successful payment', async () => {
    const wrapper = mount(posBillSettlementDiscountVoucher)

    const voucherCodeInput = wrapper.find('#voucherCode')
    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Enter voucher code, wait for voucher data to load, enter amount and pay
    await voucherCodeInput.setValue('SAVE20')
    await wrapper.vm.$nextTick()
    await amountInput.setValue(50)
    await payButton.trigger('click')

    // Wait for the component to update after payment
    await wrapper.vm.$nextTick()

    // Amount should be cleared but voucher code should remain
    expect((amountInput.element as HTMLInputElement).value).toBe('0')
    expect((voucherCodeInput.element as HTMLInputElement).value).toBe('SAVE20')
  })

  it('calculates discount amount correctly', async () => {
    const wrapper = mount(posBillSettlementDiscountVoucher)

    const voucherCodeInput = wrapper.find('#voucherCode')
    const amountInput = wrapper.find('#amountReceive')

    // Enter voucher code and wait for voucher data to load
    await voucherCodeInput.setValue('SAVE20')
    await wrapper.vm.$nextTick()

    // Enter amount
    await amountInput.setValue(30)

    // The component should calculate discount correctly
    // For SAVE20 voucher with 30 amount, discount should be 20 (min of voucher value and amount)
    const discountValueInput = wrapper.find('#discountValue')
    expect((discountValueInput.element as HTMLInputElement).value).toBe('20')
  })

  it('validates amount against discount value', async () => {
    const wrapper = mount(posBillSettlementDiscountVoucher)

    const voucherCodeInput = wrapper.find('#voucherCode')
    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Enter voucher code and wait for voucher data to load
    await voucherCodeInput.setValue('SAVE20')
    await wrapper.vm.$nextTick()

    // Enter amount higher than discount value
    await amountInput.setValue(50)

    // Button should be enabled (component allows amount > discount value)
    expect(payButton.attributes('disabled')).toBeUndefined()
  })
})
