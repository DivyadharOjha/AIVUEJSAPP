import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import posBillSettlementEPayment from '../components/posTemplate/posBillSettlementEPayment.vue'
import { usePaymentStore } from '../stores/paymentStore'

describe('posBillSettlementEPayment', () => {
  let pinia: ReturnType<typeof createPinia>
  let store: ReturnType<typeof usePaymentStore>

  beforeEach(() => {
    pinia = createPinia()
    setActivePinia(pinia)
    store = usePaymentStore()
    store.setOriginalAmountDue(125.5)
  })

  it('renders initial UI correctly', () => {
    const wrapper = mount(posBillSettlementEPayment)

    expect(wrapper.find('.card-header h4').text()).toBe('E-Payment')
    expect((wrapper.find('#amount').element as HTMLInputElement).value).toBe('125.5')
    expect((wrapper.find('#amountReceive').element as HTMLInputElement).value).toBe('0')
  })

  it('enables pay button when amount and reference number are entered', async () => {
    const wrapper = mount(posBillSettlementEPayment)

    const amountInput = wrapper.find('#amountReceive')
    const referenceInput = wrapper.find('#referenceNumber')
    const payButton = wrapper.find('button.btn-success')

    // Initially button should be disabled
    expect(payButton.attributes('disabled')).toBeDefined()

    // Enter amount and reference number
    await amountInput.setValue(50)
    await referenceInput.setValue('REF123')

    // Button should be enabled
    expect(payButton.attributes('disabled')).toBeUndefined()
  })

  it('disables pay button when no amount is entered', async () => {
    const wrapper = mount(posBillSettlementEPayment)

    const referenceInput = wrapper.find('#referenceNumber')
    const payButton = wrapper.find('button.btn-success')

    // Enter reference number without amount
    await referenceInput.setValue('REF123')

    // Button should still be disabled
    expect(payButton.attributes('disabled')).toBeDefined()
  })

  it('disables pay button when amount is zero', async () => {
    const wrapper = mount(posBillSettlementEPayment)

    const amountInput = wrapper.find('#amountReceive')
    const referenceInput = wrapper.find('#referenceNumber')
    const payButton = wrapper.find('button.btn-success')

    // Enter reference number but zero amount
    await referenceInput.setValue('REF123')
    await amountInput.setValue(0)

    // Button should be disabled
    expect(payButton.attributes('disabled')).toBeDefined()
  })

  it('emits payment record when pay button is clicked', async () => {
    const wrapper = mount(posBillSettlementEPayment)

    const amountInput = wrapper.find('#amountReceive')
    const referenceInput = wrapper.find('#referenceNumber')
    const payButton = wrapper.find('button.btn-success')

    // Enter amount and reference number
    await amountInput.setValue(50)
    await referenceInput.setValue('REF123')

    // Click pay button
    await payButton.trigger('click')

    // Check if event was emitted
    expect(wrapper.emitted('payment-record-added')).toBeTruthy()
    const emittedRecord = wrapper.emitted('payment-record-added')?.[0]?.[0]
    expect(emittedRecord).toMatchObject({
      id: expect.any(String),
      type: 'ePayment',
      amount: 50,
    })
  })

  it('shows table when payment records exist', async () => {
    const wrapper = mount(posBillSettlementEPayment)

    // Initially table should not be visible
    expect(wrapper.find('table').exists()).toBe(false)

    // Add a payment record to store
    store.componentRecords.ePayment.push({
      id: 'test-1',
      type: 'ePayment',
      amountReceive: 50,
      transactionId: 'TXN-123',
      referenceNumber: 'REF123',
      notes: 'Test payment',
      timestamp: new Date().toISOString(),
    })

    // Force component to re-render
    await wrapper.vm.$nextTick()

    // Table should be visible
    expect(wrapper.find('table').exists()).toBe(true)
  })

  it('clears form after successful payment', async () => {
    const wrapper = mount(posBillSettlementEPayment)

    const amountInput = wrapper.find('#amountReceive')
    const referenceInput = wrapper.find('#referenceNumber')
    const payButton = wrapper.find('button.btn-success')

    // Enter amount, reference and pay
    await amountInput.setValue(50)
    await referenceInput.setValue('REF123')
    await payButton.trigger('click')

    // Amount should be cleared but reference can remain
    expect((amountInput.element as HTMLInputElement).value).toBe('0')
  })

  it('generates transaction ID automatically', async () => {
    const wrapper = mount(posBillSettlementEPayment)

    // Wait for component to mount and generate transaction ID
    await wrapper.vm.$nextTick()

    const transactionIdInput = wrapper.find('#transactionId')

    // Transaction ID should be auto-generated and not empty
    expect((transactionIdInput.element as HTMLInputElement).value).not.toBe('')
    expect((transactionIdInput.element as HTMLInputElement).value).toMatch(/EPAY-\d+-\d+/)
  })

  it('validates amount against amount due', async () => {
    const wrapper = mount(posBillSettlementEPayment)

    const amountInput = wrapper.find('#amountReceive')
    const referenceInput = wrapper.find('#referenceNumber')
    const payButton = wrapper.find('button.btn-success')

    // Enter valid reference
    await referenceInput.setValue('REF123')

    // Enter amount higher than amount due (125.5)
    await amountInput.setValue(200)

    // Button should still be enabled (component doesn't validate against amount due)
    expect(payButton.attributes('disabled')).toBeUndefined()
  })
})
