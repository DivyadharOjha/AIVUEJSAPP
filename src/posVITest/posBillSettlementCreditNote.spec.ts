import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import posBillSettlementCreditNote from '../components/posTemplate/posBillSettlementCreditNote.vue'
import { usePaymentStore } from '../stores/paymentStore'

describe('posBillSettlementCreditNote', () => {
  let pinia: ReturnType<typeof createPinia>
  let store: ReturnType<typeof usePaymentStore>

  beforeEach(() => {
    pinia = createPinia()
    setActivePinia(pinia)
    store = usePaymentStore()
    store.setOriginalAmountDue(125.5)
  })

  it('renders initial UI correctly', () => {
    const wrapper = mount(posBillSettlementCreditNote)

    expect(wrapper.find('.card-header h4').text()).toBe('Credit Note Payment')
    expect((wrapper.find('#amount').element as HTMLInputElement).value).toBe('125.5')
  })

  it('enables pay button when amount is entered', async () => {
    const wrapper = mount(posBillSettlementCreditNote)

    const amountInput = wrapper.find('#creditNoteAmount')
    const payButton = wrapper.find('button.btn-success')

    // Initially button should be disabled
    expect(payButton.attributes('disabled')).toBeDefined()

    // Enter valid amount
    await amountInput.setValue(50)

    // Button should be enabled
    expect(payButton.attributes('disabled')).toBeUndefined()
  })

  it('disables pay button when amount is zero', async () => {
    const wrapper = mount(posBillSettlementCreditNote)

    const amountInput = wrapper.find('#creditNoteAmount')
    const payButton = wrapper.find('button.btn-success')

    // Enter zero amount
    await amountInput.setValue(0)

    // Button should be disabled
    expect(payButton.attributes('disabled')).toBeDefined()
  })

  it('emits payment record when pay button is clicked', async () => {
    const wrapper = mount(posBillSettlementCreditNote)

    const amountInput = wrapper.find('#creditNoteAmount')
    const payButton = wrapper.find('button.btn-success')

    // Enter amount
    await amountInput.setValue(50)

    // Click pay button
    await payButton.trigger('click')

    // Check if event was emitted
    expect(wrapper.emitted('payment-record-added')).toBeTruthy()
    const emittedRecord = wrapper.emitted('payment-record-added')?.[0]?.[0]
    expect(emittedRecord).toMatchObject({
      id: expect.any(String),
      type: 'creditNote',
      amount: 50,
      notes: '',
      timestamp: expect.any(String),
    })
  })

  it('shows table when payment records exist', async () => {
    const wrapper = mount(posBillSettlementCreditNote)

    // Initially table should not be visible
    expect(wrapper.find('table').exists()).toBe(false)

    // Add a payment record to store
    store.componentRecords.creditNote.push({
      id: 'test-1',
      type: 'creditNote',
      creditNoteNumber: 'CN-001',
      expiryDate: '2024-12-31',
      notes: 'Test credit note',
      timestamp: new Date().toISOString(),
      creditNoteAmount: 50,
      appliedAmount: 50,
      remainingBalance: 95.5,
      customerName: 'Ojha',
      issueDate: new Date().toISOString().split('T')[0],
    })

    // Force component to re-render
    await wrapper.vm.$nextTick()

    // Table should be visible
    expect(wrapper.find('table').exists()).toBe(true)
  })

  it('calculates remaining balance correctly', async () => {
    const wrapper = mount(posBillSettlementCreditNote)

    const amountInput = wrapper.find('#creditNoteAmount')

    // Enter amount
    await amountInput.setValue(30)

    // Check if remaining balance is calculated correctly
    const remainingBalanceElement = wrapper.find('#remainingBalance')
    expect((remainingBalanceElement.element as HTMLInputElement).value).toBe('95.5')
  })

  it('clears form after successful payment', async () => {
    const wrapper = mount(posBillSettlementCreditNote)

    const amountInput = wrapper.find('#creditNoteAmount')
    const payButton = wrapper.find('button.btn-success')

    // Enter amount and pay
    await amountInput.setValue(50)
    await payButton.trigger('click')

    // Form should be cleared
    expect((amountInput.element as HTMLInputElement).value).toBe('0')
  })

  it('loads default values on mount', () => {
    const wrapper = mount(posBillSettlementCreditNote)

    // Check if default values are set
    const issueDateInput = wrapper.find('#issueDate')
    const customerNameInput = wrapper.find('#customerName')

    expect((issueDateInput.element as HTMLInputElement).value).toBe(
      new Date().toISOString().split('T')[0],
    )
    expect((customerNameInput.element as HTMLInputElement).value).toBe('Ojha')
  })
})
