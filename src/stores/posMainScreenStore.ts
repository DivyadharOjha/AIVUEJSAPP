import { ref } from 'vue'
import { defineStore } from 'pinia'
import { LineWiseField } from '../components/posDataStruct/posLinewiseFields'

export const useMainScreen = defineStore('mainScreen', () => {
  const DynamicLineWiseField = ref<LineWiseField[]>([])

  return {
    DynamicLineWiseField,
  }
})
