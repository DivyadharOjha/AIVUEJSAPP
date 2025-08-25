import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import posBillSettlement from '../components/posTemplate/posBillSettlement.vue'
import { usePaymentStore } from '../stores/paymentStore'

describe('posBillSettlement', () => {
  let pinia: ReturnType<typeof createPinia>
  let store: ReturnType<typeof usePaymentStore>

  beforeEach(() => {
    pinia = createPinia()
    setActivePinia(pinia)
    store = usePaymentStore()
    store.setOriginalAmountDue(125.5)
  })

  it('renders initial UI correctly', () => {
    const wrapper = mount(posBillSettlement)

    expect(wrapper.find('h4').text()).toBe('Select a Payment Type')
    expect(wrapper.find('.fw-bold').text()).toContain('Amount Due: $125.50')
  })

  it('shows all payment type buttons', () => {
    const wrapper = mount(posBillSettlement)

    const paymentButtons = wrapper.findAll('.payment-type-btn')
    const buttonTexts = paymentButtons.map((btn) => btn.text())

    expect(buttonTexts).toContain('Cash')
    expect(buttonTexts).toContain('Credit Card')
    expect(buttonTexts).toContain('Debit Card')
    expect(buttonTexts).toContain('Credit Note')
    expect(buttonTexts).toContain('Member Point')
    expect(buttonTexts).toContain('Gift Voucher')
    expect(buttonTexts).toContain('Wallet')
    expect(buttonTexts).toContain('EPayment')
    expect(buttonTexts).toContain('Discount Voucher')
  })

  it('updates totals when child component emits payment record', async () => {
    const wrapper = mount(posBillSettlement)

    // Set up initial state
    store.setOriginalAmountDue(125.5)

    // Simulate child component emitting a payment record by emitting the event from the child component
    await wrapper.findComponent({ name: 'PosPaymentInput' }).vm.$emit('payment-record-added', {
      id: 'test-1',
      type: 'cash',
      amount: 50.0,
    })
    await wrapper.vm.$nextTick()

    // Check if totals are updated
    // Access the component's exposed properties using `wrapper.vm.$.exposed`
    expect(wrapper.vm.$.exposed?.totalAmountReceived).toBe(50.0)
    expect(wrapper.vm.$.exposed?.totalAmountDue).toBe(125.5)
  })

  it('handles payment record removal', async () => {
    const wrapper = mount(posBillSettlement)

    // Add a payment record first by emitting the event from the child component
    await wrapper.findComponent({ name: 'PosPaymentInput' }).vm.$emit('payment-record-added', {
      id: 'test-1',
      type: 'cash',
      amount: 50.0,
    })

    // Remove the payment record by emitting the event from the child component
    await wrapper
      .findComponent({ name: 'PosPaymentInput' })
      .vm.$emit('payment-record-removed', 'test-1')

    // Wait for the DOM and state to update
    await wrapper.vm.$nextTick()

    // Check if totals are reset
    // Access the component's exposed properties using `wrapper.vm.$.exposed`
    expect(wrapper.vm.$.exposed?.totalAmountReceived).toBe(0)
    expect(wrapper.vm.$.exposed?.totalAmountDue).toBe(125.5)
  })
})
