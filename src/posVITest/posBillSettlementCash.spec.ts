import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import posBillSettlementCash from '../components/posTemplate/posBillSettlementCash.vue'
import { usePaymentStore } from '../stores/paymentStore'

describe('posBillSettlementCash', () => {
  let pinia: ReturnType<typeof createPinia>
  let store: ReturnType<typeof usePaymentStore>

  beforeEach(() => {
    pinia = createPinia()
    setActivePinia(pinia)
    store = usePaymentStore()
    store.setOriginalAmountDue(125.5)
  })

  it('renders initial UI correctly', () => {
    const wrapper = mount(posBillSettlementCash)

    expect(wrapper.find('.card-header h4').text()).toBe('Cash Payment')
    expect((wrapper.find('#cashReceived').element as HTMLInputElement).value).toBe('0')
    expect(wrapper.find('.pay-cash-btn').exists()).toBe(true)
  })

  it('enables pay button when valid amount is entered', async () => {
    const wrapper = mount(posBillSettlementCash)

    const amountInput = wrapper.find('#cashReceived')
    const payButton = wrapper.find('.pay-cash-btn')

    // Initially button should be disabled
    expect(payButton.attributes('disabled')).toBeDefined()

    // Enter valid amount
    await amountInput.setValue(50)

    // Button should be enabled
    expect(payButton.attributes('disabled')).toBeUndefined()
  })

  it('disables pay button when amount is zero', async () => {
    const wrapper = mount(posBillSettlementCash)

    const amountInput = wrapper.find('#cashReceived')
    const payButton = wrapper.find('.pay-cash-btn')

    // Enter zero amount
    await amountInput.setValue(0)

    // Button should be disabled
    expect(payButton.attributes('disabled')).toBeDefined()
  })

  it('emits payment record when pay button is clicked', async () => {
    const wrapper = mount(posBillSettlementCash)

    const amountInput = wrapper.find('#cashReceived')
    const payButton = wrapper.find('.pay-cash-btn')

    // Enter valid amount
    await amountInput.setValue(50)

    // Click pay button
    await payButton.trigger('click')

    // Check if event was emitted
    expect(wrapper.emitted('payment-record-added')).toBeTruthy()
    const emittedRecord = wrapper.emitted('payment-record-added')?.[0]?.[0]
    expect(emittedRecord).toMatchObject({
      id: expect.any(String),
      type: 'cash',
      cashReceived: 50,
      schemesDiscount: 0,
      notes: '',
      timestamp: expect.any(String)
    })
  })

  it('shows table when payment records exist', async () => {
    const wrapper = mount(posBillSettlementCash)

    // Initially table should not be visible
    expect(wrapper.find('table').exists()).toBe(false)

    // Add a payment record to store
    store.componentRecords.cash.push({
      id: 'test-1',
      type: 'cash',
      cashReceived: 50,
      schemesDiscount: 0,
      notes: 'Test payment',
      timestamp: new Date().toISOString(),
    })

    // Force component to re-render
    await wrapper.vm.$nextTick()

    // Table should be visible
    expect(wrapper.find('table').exists()).toBe(true)
  })

  it('clears form after successful payment', async () => {
    const wrapper = mount(posBillSettlementCash)

    const amountInput = wrapper.find('#cashReceived')
    const payButton = wrapper.find('.pay-cash-btn')

    // Enter amount and pay
    await amountInput.setValue(50)
    await payButton.trigger('click')

    // Form should be cleared (reset to 0)
    expect((amountInput.element as HTMLInputElement).value).toBe('0')
  })
})
