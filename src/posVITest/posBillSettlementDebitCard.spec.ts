import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import posBillSettlementDebitCard from '../components/posTemplate/posBillSettlementDebitCard.vue'
import { usePaymentStore } from '../stores/paymentStore'

describe('posBillSettlementDebitCard', () => {
  let pinia: ReturnType<typeof createPinia>
  let store: ReturnType<typeof usePaymentStore>

  beforeEach(() => {
    pinia = createPinia()
    setActivePinia(pinia)
    store = usePaymentStore()
    store.setOriginalAmountDue(125.5)
  })

  it('renders initial UI correctly', () => {
    const wrapper = mount(posBillSettlementDebitCard)

    expect(wrapper.find('.card-header h4').text()).toBe('Debit Card Payment')
    expect((wrapper.find('#amount').element as HTMLInputElement).value).toBe('125.5')
  })

  it('enables pay button when card type is selected and amount is entered', async () => {
    const wrapper = mount(posBillSettlementDebitCard)

    const visaRadio = wrapper.find('input#visa-debit')
    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Initially button should be disabled
    expect(payButton.attributes('disabled')).toBeDefined()

    // Select card type
    await visaRadio.setValue(true)

    // Enter amount
    await amountInput.setValue(50)

    // Button should be enabled
    expect(payButton.attributes('disabled')).toBeUndefined()
  })

  it('disables pay button when no card type is selected', async () => {
    const wrapper = mount(posBillSettlementDebitCard)

    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Enter amount without selecting card type
    await amountInput.setValue(50)

    // Button should still be disabled
    expect(payButton.attributes('disabled')).toBeDefined()
  })

  it('disables pay button when amount is zero', async () => {
    const wrapper = mount(posBillSettlementDebitCard)

    const visaRadio = wrapper.find('input#visa-debit')
    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Select card type
    await visaRadio.setValue(true)

    // Enter zero amount
    await amountInput.setValue(0)

    // Button should be disabled
    expect(payButton.attributes('disabled')).toBeDefined()
  })

  it('emits payment record when pay button is clicked', async () => {
    const wrapper = mount(posBillSettlementDebitCard)

    const visaRadio = wrapper.find('input#visa-debit')
    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Select card type and enter amount
    await visaRadio.setValue(true)
    await amountInput.setValue(50)

    // Click pay button
    await payButton.trigger('click')

    // Check if event was emitted
    expect(wrapper.emitted('payment-record-added')).toBeTruthy()
    const emittedRecord = wrapper.emitted('payment-record-added')?.[0]?.[0]
    expect(emittedRecord).toMatchObject({
      id: expect.any(String),
      type: 'debitCard',
      cardType: 'visa',
      amount: 50,
      notes: '',
      timestamp: expect.any(String),
    })
  })

  it('shows table when payment records exist', async () => {
    const wrapper = mount(posBillSettlementDebitCard)

    // Initially table should not be visible
    expect(wrapper.find('table').exists()).toBe(false)

    // Add a payment record to store (include all required fields for DebitCardPaymentRecord)
    store.componentRecords.debitCard.push({
      id: 'test-1',
      type: 'debitCard',
      cardType: 'visa',
      amount: 50,
      notes: 'Test payment',
      timestamp: new Date().toISOString(),
      cardNumber: '4111111111111111',
      expiryDate: '12/25',
      cvv: '123',
      cardholderName: 'Test User',
      transactionId: 'txn-1',
    })

    // Force component to re-render
    await wrapper.vm.$nextTick()

    // Table should be visible
    expect(wrapper.find('table').exists()).toBe(true)
  })

  it('filters out records with empty card type', async () => {
    const wrapper = mount(posBillSettlementDebitCard)

    // Add valid record
    store.componentRecords.debitCard.push({
      id: 'test-1',
      type: 'debitCard',
      cardType: 'visa',
      amount: 50,
      notes: 'Test payment',
      timestamp: new Date().toISOString(),
      cardNumber: '4111111111111111',
      expiryDate: '12/25',
      cvv: '123',
      cardholderName: 'Test User',
      transactionId: 'txn-1',
    })

    // Add invalid record with empty card type (fill required fields to match DebitCardPaymentRecord type)
    store.componentRecords.debitCard.push({
      id: 'test-2',
      type: 'debitCard',
      cardType: '',
      amount: 30,
      notes: 'Invalid payment',
      timestamp: new Date().toISOString(),
      cardNumber: '',
      expiryDate: '',
      cvv: '',
      cardholderName: '',
      transactionId: '',
    })

    // Force component to re-render
    await wrapper.vm.$nextTick()

    // Only valid record should be displayed
    const tableRows = wrapper.findAll('tbody tr')
    expect(tableRows.length).toBe(1)
  })

  it('clears form after successful payment', async () => {
    const wrapper = mount(posBillSettlementDebitCard)

    const visaRadio = wrapper.find('input#visa-debit')
    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Select card type, enter amount and pay
    await visaRadio.setValue(true)
    await amountInput.setValue(50)
    await payButton.trigger('click')

    // Form should be cleared
    expect((amountInput.element as HTMLInputElement).value).toBe('0')
  })
})
