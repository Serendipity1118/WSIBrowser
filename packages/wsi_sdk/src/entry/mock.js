// Bundle entry for the contract tests. Not shipped.
import { installRunner } from '../core/index.js';
import { createMockAdapter, getMockState } from '../adapters/mock.js';

installRunner(createMockAdapter);
getMockState();
