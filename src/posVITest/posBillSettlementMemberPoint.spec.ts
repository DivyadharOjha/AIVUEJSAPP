import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import posBillSettlementMemberPoint from '../components/posTemplate/posBillSettlementMemberPoint.vue'
import { usePaymentStore } from '../stores/paymentStore'

describe('posBillSettlementMemberPoint', () => {
  let pinia: ReturnType<typeof createPinia>
  let store: ReturnType<typeof usePaymentStore>

  beforeEach(() => {
    pinia = createPinia()
    setActivePinia(pinia)
    store = usePaymentStore()
    store.setOriginalAmountDue(125.5)
  })

  it('renders initial UI correctly', () => {
    const wrapper = mount(posBillSettlementMemberPoint)

    expect(wrapper.find('.card-header h4').text()).toBe('Member Point Payment')
    expect((wrapper.find('#amount').element as HTMLInputElement).value).toBe('125.5')
  })

  it('enables pay button when member ID and points are entered', async () => {
    const wrapper = mount(posBillSettlementMemberPoint)

    const memberIdInput = wrapper.find('#memberId')
    const pointsInput = wrapper.find('#pointsToRedeem')
    const payButton = wrapper.find('button.btn-success')

    // Initially button should be disabled
    expect(payButton.attributes('disabled')).toBeDefined()

    // Enter member ID
    await memberIdInput.setValue('M001')

    // Enter points
    await pointsInput.setValue(100)

    // Button should be enabled
    expect(payButton.attributes('disabled')).toBeUndefined()
  })

  it('disables pay button when no member ID is entered', async () => {
    const wrapper = mount(posBillSettlementMemberPoint)

    const pointsInput = wrapper.find('#pointsToRedeem')
    const payButton = wrapper.find('button.btn-success')

    // Enter points without member ID
    await pointsInput.setValue(100)

    // Button should still be disabled
    expect(payButton.attributes('disabled')).toBeDefined()
  })

  it('disables pay button when points are zero', async () => {
    const wrapper = mount(posBillSettlementMemberPoint)

    const memberIdInput = wrapper.find('#memberId')
    const pointsInput = wrapper.find('#pointsToRedeem')
    const payButton = wrapper.find('button.btn-success')

    // Enter member ID
    await memberIdInput.setValue('M001')

    // Enter zero points
    await pointsInput.setValue(0)

    // Button should be disabled
    expect(payButton.attributes('disabled')).toBeDefined()
  })

  it('emits payment record when pay button is clicked', async () => {
    const wrapper = mount(posBillSettlementMemberPoint)

    const memberIdInput = wrapper.find('#memberId')
    const pointsInput = wrapper.find('#pointsToRedeem')
    const payButton = wrapper.find('button.btn-success')

    // Enter member ID and points
    await memberIdInput.setValue('M001')
    await pointsInput.setValue(100)

    // Click pay button
    await payButton.trigger('click')

    // Check if event was emitted
    expect(wrapper.emitted('payment-record-added')).toBeTruthy()
    const emittedRecord = wrapper.emitted('payment-record-added')?.[0]?.[0]
    expect(emittedRecord).toMatchObject({
      id: expect.any(String),
      type: 'memberPoint',
      amount: 1, // Assuming point value is 0.01
      notes: '',
      timestamp: expect.any(String),
    })
  })

  it('shows table when payment records exist', async () => {
    const wrapper = mount(posBillSettlementMemberPoint)

    // Initially table should not be visible
    expect(wrapper.find('table').exists()).toBe(false)

    // Add a payment record to store
    store.componentRecords.memberPoint.push({
      id: 'test-1',
      type: 'memberPoint',
      memberId: 'M001',
      memberName: 'John Doe',
      pointsToRedeem: 100,
      redeemedAmount: 10,
      remainingAmount: 40,
      notes: 'Test member point payment',
      timestamp: new Date().toISOString(),
      availablePoints: 500,
      pointValue: 0.01,
    })

    // Force component to re-render
    await wrapper.vm.$nextTick()

    // Table should be visible
    expect(wrapper.find('table').exists()).toBe(true)
  })

  it('calculates redeemed amount correctly', async () => {
    const wrapper = mount(posBillSettlementMemberPoint)

    const pointsInput = wrapper.find('#pointsToRedeem')

    // Enter points
    await pointsInput.setValue(150)

    // Check if redeemed amount is calculated correctly
    const redeemedAmountElement = wrapper.find('#redeemedAmount')
    expect((redeemedAmountElement.element as HTMLInputElement).value).toBe('1.5')
  })

  it('calculates remaining amount correctly', async () => {
    const wrapper = mount(posBillSettlementMemberPoint)

    const pointsInput = wrapper.find('#pointsToRedeem')

    // Enter points
    await pointsInput.setValue(100)

    // Check if remaining amount is calculated correctly
    const remainingAmountElement = wrapper.find('#remainingAmount')
    expect((remainingAmountElement.element as HTMLInputElement).value).toBe('124')
  })

  it('clears form after successful payment', async () => {
    const wrapper = mount(posBillSettlementMemberPoint)

    const memberIdInput = wrapper.find('#memberId')
    const pointsInput = wrapper.find('#pointsToRedeem')
    const payButton = wrapper.find('button.btn-success')

    // Enter member ID, points and pay
    await memberIdInput.setValue('M001')
    await pointsInput.setValue(100)
    await payButton.trigger('click')

    // Form should be cleared
    expect((pointsInput.element as HTMLInputElement).value).toBe('0')
  })

  it('loads member data when member ID is entered', async () => {
    const wrapper = mount(posBillSettlementMemberPoint)

    const memberIdInput = wrapper.find('#memberId')

    // Enter member ID
    await memberIdInput.setValue('M001')

    // Check if member data is loaded
    const memberNameElement = wrapper.find('#memberName')
    expect((memberNameElement.element as HTMLInputElement).value).toBe('John Doe')

    const availablePointsElement = wrapper.find('#availablePoints')
    expect((availablePointsElement.element as HTMLInputElement).value).toBe('500')
  })
})
