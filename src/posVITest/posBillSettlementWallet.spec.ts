import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import posBillSettlementWallet from '../components/posTemplate/posBillSettlementWallet.vue'
import { usePaymentStore } from '../stores/paymentStore'

describe('posBillSettlementWallet', () => {
  let pinia: ReturnType<typeof createPinia>
  let store: ReturnType<typeof usePaymentStore>

  beforeEach(() => {
    pinia = createPinia()
    setActivePinia(pinia)
    store = usePaymentStore()
    store.setOriginalAmountDue(125.5)
  })

  it('renders initial UI correctly', () => {
    const wrapper = mount(posBillSettlementWallet)

    expect(wrapper.find('.card-header h4').text()).toBe('Digital Wallet Payment')
    expect((wrapper.find('#amount').element as HTMLInputElement).value).toBe('125.5')
  })

  it('enables pay button when member ID and amount are entered', async () => {
    const wrapper = mount(posBillSettlementWallet)

    const memberIdInput = wrapper.find('#memberId')
    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Initially button should be disabled
    expect(payButton.attributes('disabled')).toBeDefined()

    // Enter member ID (this will load wallet data with balance 500)
    await memberIdInput.setValue('M001')
    await wrapper.vm.$nextTick()

    // Enter valid amount
    await amountInput.setValue(50)

    // Button should be enabled
    expect(payButton.attributes('disabled')).toBeUndefined()
  })

  it('disables pay button when no member ID is entered', async () => {
    const wrapper = mount(posBillSettlementWallet)

    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Enter amount without member ID
    await amountInput.setValue(50)

    // Button should still be disabled
    expect(payButton.attributes('disabled')).toBeDefined()
  })

  it('disables pay button when amount is zero', async () => {
    const wrapper = mount(posBillSettlementWallet)

    const memberIdInput = wrapper.find('#memberId')
    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Enter member ID but zero amount
    await memberIdInput.setValue('M001')
    await amountInput.setValue(0)

    // Button should be disabled
    expect(payButton.attributes('disabled')).toBeDefined()
  })

  it('emits payment record when pay button is clicked', async () => {
    const wrapper = mount(posBillSettlementWallet)

    const memberIdInput = wrapper.find('#memberId')
    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Enter member ID and amount
    await memberIdInput.setValue('M001')
    await wrapper.vm.$nextTick()
    await amountInput.setValue(50)

    // Click pay button
    await payButton.trigger('click')

    // Check if event was emitted
    expect(wrapper.emitted('payment-record-added')).toBeTruthy()
    const emittedRecord = wrapper.emitted('payment-record-added')?.[0]?.[0]
    expect(emittedRecord).toMatchObject({
      id: expect.any(String),
      type: 'wallet',
      amount: 50,
    })
  })

  it('shows table when payment records exist', async () => {
    const wrapper = mount(posBillSettlementWallet)

    // Initially table should not be visible
    expect(wrapper.find('table').exists()).toBe(false)

    // Add a payment record to store
    store.componentRecords.wallet.push({
      id: 'test-1',
      type: 'wallet',
      memberId: 'M001',
      memberName: 'John Doe',
      walletAvailableBalance: 500,
      amountReceive: 50,
      transactionId: 'WALLET-123',
      notes: 'Test payment',
      timestamp: new Date().toISOString(),
    })

    // Force component to re-render
    await wrapper.vm.$nextTick()

    // Table should be visible
    expect(wrapper.find('table').exists()).toBe(true)
  })

  it('loads wallet data when member ID is entered', async () => {
    const wrapper = mount(posBillSettlementWallet)

    const memberIdInput = wrapper.find('#memberId')

    // Enter known member ID
    await memberIdInput.setValue('M001')
    await wrapper.vm.$nextTick()

    // Check if member data is loaded
    const memberNameInput = wrapper.find('#memberName')
    const walletBalanceInput = wrapper.find('#walletBalance')
    expect((memberNameInput.element as HTMLInputElement).value).toBe('John Doe')
    expect((walletBalanceInput.element as HTMLInputElement).value).toBe('500')
  })

  it('clears form after successful payment', async () => {
    const wrapper = mount(posBillSettlementWallet)

    const memberIdInput = wrapper.find('#memberId')
    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Enter member ID, amount and pay
    await memberIdInput.setValue('M001')
    await wrapper.vm.$nextTick()
    await amountInput.setValue(50)
    await payButton.trigger('click')

    // Amount should be cleared but member ID should remain
    expect((amountInput.element as HTMLInputElement).value).toBe('0')
    expect((memberIdInput.element as HTMLInputElement).value).toBe('M001')
  })

  it('validates amount against wallet balance', async () => {
    const wrapper = mount(posBillSettlementWallet)

    const memberIdInput = wrapper.find('#memberId')
    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Enter member ID (loads balance of 500)
    await memberIdInput.setValue('M001')
    await wrapper.vm.$nextTick()

    // Enter amount higher than wallet balance
    await amountInput.setValue(600)

    // Button should be disabled
    expect(payButton.attributes('disabled')).toBeDefined()
  })

  it('validates amount against amount due', async () => {
    const wrapper = mount(posBillSettlementWallet)

    const memberIdInput = wrapper.find('#memberId')
    const amountInput = wrapper.find('#amountReceive')
    const payButton = wrapper.find('button.btn-success')

    // Enter member ID
    await memberIdInput.setValue('M001')
    await wrapper.vm.$nextTick()

    // Enter amount higher than amount due
    await amountInput.setValue(200)

    // Button should be disabled
    expect(payButton.attributes('disabled')).toBeDefined()
  })
})
