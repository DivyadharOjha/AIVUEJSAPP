import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import posBillSettlement from '../components/posTemplate/posBillSettlement.vue'
import posBillSettlementCash from '../components/posTemplate/posBillSettlementCash.vue'
import posBillSettlementCreditCard from '../components/posTemplate/posBillSettlementCreditCard.vue'
import posBillSettlementDebitCard from '../components/posTemplate/posBillSettlementDebitCard.vue'
import posBillSettlementCreditNote from '../components/posTemplate/posBillSettlementCreditNote.vue'
import posBillSettlementMemberPoint from '../components/posTemplate/posBillSettlementMemberPoint.vue'
import posBillSettlementGiftVoucher from '../components/posTemplate/posBillSettlementGiftVoucher.vue'
import posBillSettlementWallet from '../components/posTemplate/posBillSettlementWallet.vue'
import posBillSettlementEPayment from '../components/posTemplate/posBillSettlementEPayment.vue'
import posBillSettlementDiscountVoucher from '../components/posTemplate/posBillSettlementDiscountVoucher.vue'
import { usePaymentStore } from '../stores/paymentStore'

describe('Basic Component Tests', () => {
  let pinia: ReturnType<typeof createPinia>
  let store: ReturnType<typeof usePaymentStore>

  beforeEach(() => {
    pinia = createPinia()
    setActivePinia(pinia)
    store = usePaymentStore()
    store.setOriginalAmountDue(125.5)
  })

  it('renders main bill settlement component', () => {
    const wrapper = mount(posBillSettlement)
    expect(wrapper.exists()).toBe(true)
    expect(wrapper.find('h4').text()).toBe('Select a Payment Type')
  })

  it('renders cash payment component', () => {
    const wrapper = mount(posBillSettlementCash)
    expect(wrapper.exists()).toBe(true)
    expect(wrapper.find('.card-header h4').text()).toBe('Cash Payment')
  })

  it('renders credit card payment component', () => {
    const wrapper = mount(posBillSettlementCreditCard)
    expect(wrapper.exists()).toBe(true)
    expect(wrapper.find('.card-header h4').text()).toBe('Credit Card Payment')
  })

  it('renders debit card payment component', () => {
    const wrapper = mount(posBillSettlementDebitCard)
    expect(wrapper.exists()).toBe(true)
    expect(wrapper.find('.card-header h4').text()).toBe('Debit Card Payment')
  })

  it('renders credit note payment component', () => {
    const wrapper = mount(posBillSettlementCreditNote)
    expect(wrapper.exists()).toBe(true)
    expect(wrapper.find('.card-header h4').text()).toBe('Credit Note Payment')
  })

  it('renders member point payment component', () => {
    const wrapper = mount(posBillSettlementMemberPoint)
    expect(wrapper.exists()).toBe(true)
    expect(wrapper.find('.card-header h4').text()).toBe('Member Point Payment')
  })

  it('renders gift voucher payment component', () => {
    const wrapper = mount(posBillSettlementGiftVoucher)
    expect(wrapper.exists()).toBe(true)
    expect(wrapper.find('.card-header h4').text()).toBe('Gift Voucher Payment')
  })

  it('renders wallet payment component', () => {
    const wrapper = mount(posBillSettlementWallet)
    expect(wrapper.exists()).toBe(true)
    expect(wrapper.find('.card-header h4').text()).toBe('Digital Wallet Payment')
  })

  it('renders e-payment component', () => {
    const wrapper = mount(posBillSettlementEPayment)
    expect(wrapper.exists()).toBe(true)
    expect(wrapper.find('.card-header h4').text()).toBe('E-Payment')
  })

  it('renders discount voucher payment component', () => {
    const wrapper = mount(posBillSettlementDiscountVoucher)
    expect(wrapper.exists()).toBe(true)
    expect(wrapper.find('.card-header h4').text()).toBe('Discount Voucher Payment')
  })
})
