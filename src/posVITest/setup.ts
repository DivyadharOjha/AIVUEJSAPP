import { config } from '@vue/test-utils'

// Stub <i> tags to prevent Vue warnings
config.global.stubs = { i: true }
